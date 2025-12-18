;;; nixos/editors/.doom.d/package_configuration/gptel/aider.el -*- lexical-binding: t; -*-

(defun my-apply-custom-diff-from-clipboard ()
  "Apply a custom SEARCH/REPLACE diff from the clipboard to the current buffer.

The expected format is:
<<<<<<< SEARCH
[original text]
=======
[replacement text]
>>>>>>> REPLACE"
  (interactive)
  (let* ((clipboard-text (current-kill 0))
         (search-marker "<<<<<<< SEARCH\n")
         (divider-marker "=======\n")
         (replace-marker ">>>>>>> REPLACE")
         (search-start (string-match (regexp-quote search-marker) clipboard-text))
         (divider-start (string-match (regexp-quote divider-marker) clipboard-text))
         (replace-end (string-match (regexp-quote replace-marker) clipboard-text)))

    (if (and search-start divider-start replace-end)
        (let* ((search-content (substring clipboard-text 
                                          (+ search-start (length search-marker)) 
                                          divider-start))
               (replace-content (substring clipboard-text 
                                           (+ divider-start (length divider-marker)) 
                                           replace-end)))
          
          (save-excursion
            (goto-char (point-min))
            (if (search-forward search-content nil t)
                (progn
                  (replace-match replace-content t t)
                  (message "Applied diff successfully."))
              (message "Error: Could not find the SEARCH block in the current buffer."))))
      (message "Error: Clipboard content does not match the expected diff format."))))

(defun my-ediff-aider-udiff-from-clipboard ()
  "Apply an Aider/Unified diff from clipboard to a temp buffer and run Ediff.

This function ignores line numbers in '@@ ... @@' headers and relies
on context matching (lines starting with space) to find the insertion point.
It handles standard udiff headers (-, +) to construct the new content."
  (interactive)
  (let* ((diff-text (current-kill 0))
         (current-buf (current-buffer))
         (patch-buf-name (format "*aider-patch-%s*" (buffer-name)))
         (patch-buf (get-buffer-create patch-buf-name)))

    ;; 1. Prepare the Proposed Buffer (Clone current)
    (with-current-buffer patch-buf
      (erase-buffer)
      (insert-buffer-substring current-buf)
      (funcall (buffer-local-value 'major-mode current-buf)))

    ;; 2. Parse and Apply Hunks
    (with-temp-buffer
      (insert diff-text)
      (goto-char (point-min))
      
      ;; Iterate over hunks (starting with @@)
      (while (re-search-forward "^@@.*@@" nil t)
        (let ((search-str "")
              (replace-str "")
              (hunk-end (save-excursion 
                          (if (re-search-forward "^@@.*@@" nil t)
                              (match-beginning 0)
                            (point-max)))))
          
          ;; Process lines inside this hunk
          (forward-line 1)
          (while (< (point) hunk-end)
            (let ((line (thing-at-point 'line t)))
              (when line
                (cond
                 ;; Context line (starts with space): Add to both
                 ((string-prefix-p " " line)
                  (let ((content (substring line 1)))
                    (setq search-str (concat search-str content))
                    (setq replace-str (concat replace-str content))))
                 ;; Deletion (starts with -): Add to search only
                 ((string-prefix-p "-" line)
                  (unless (string-prefix-p "---" line) ;; Ignore file header
                    (setq search-str (concat search-str (substring line 1)))))
                 ;; Addition (starts with +): Add to replace only
                 ((string-prefix-p "+" line)
                  (unless (string-prefix-p "+++" line) ;; Ignore file header
                    (setq replace-str (concat replace-str (substring line 1))))))))
            (forward-line 1))

          ;; Apply this hunk to the patch buffer
          (with-current-buffer patch-buf
            (goto-char (point-min))
            (if (search-forward search-str nil t)
                (replace-match replace-str t t)
              (message "Warning: Could not apply a hunk. Context not found."))))))

    ;; 3. Launch Ediff
    (ediff-buffers current-buf patch-buf)))

(defun my-apply-hunks-to-buffer (diff-text target-buf)
  "Helper: Apply context-based hunks from DIFF-TEXT to TARGET-BUF."
  (with-current-buffer target-buf
    (let ((hunk-regexp "^@@.*@@"))
      (with-temp-buffer
        (insert diff-text)
        (goto-char (point-min))
        
        (while (re-search-forward hunk-regexp nil t)
          (let ((search-str "")
                (replace-str "")
                (hunk-end (save-excursion 
                            (if (re-search-forward hunk-regexp nil t)
                                (match-beginning 0)
                              (point-max)))))
            
            (forward-line 1)
            (while (< (point) hunk-end)
              (let ((line (thing-at-point 'line t)))
                (when line
                  (cond
                   ;; Context
                   ((string-prefix-p " " line)
                    (let ((content (substring line 1)))
                      (setq search-str (concat search-str content))
                      (setq replace-str (concat replace-str content))))
                   ;; Delete
                   ((string-prefix-p "-" line)
                    (setq search-str (concat search-str (substring line 1))))
                   ;; Add
                   ((string-prefix-p "+" line)
                    (setq replace-str (concat replace-str (substring line 1)))))))
              (forward-line 1))

            ;; Apply to target
            (with-current-buffer target-buf
              (goto-char (point-min))
              (if (search-forward search-str nil t)
                  (replace-match replace-str t t)
                (message "Warning: Hunk context not found for this block.")))))))))

(defun my-ediff-multifile-aider-from-clipboard ()
  "Parse multi-file Aider diffs, prompt for a file, and Ediff it."
  (interactive)
  (let* ((full-diff (current-kill 0))
         (file-header-regex "^\\+\\+\\+ \\(?:b/\\)?\\(.*\\)$")
         (files '()))

    ;; 1. Scan clipboard to find all files involved
    (with-temp-buffer
      (insert full-diff)
      (goto-char (point-min))
      (while (re-search-forward file-header-regex nil t)
        (push (match-string 1) files)))
    
    (when (null files)
      (user-error "No file headers (+++ filename) found in clipboard."))

    ;; 2. Prompt user to select which file to patch
    (let* ((selected-file (completing-read "Select file to patch: " (reverse files)))
           (file-diff "")
           (start-pos 0)
           (end-pos 0))

      ;; 3. Extract the chunk specific to that file
      (with-temp-buffer
        (insert full-diff)
        (goto-char (point-min))
        ;; Find the header for the selected file
        (search-forward (concat "+++ " (if (string-match-p "/" selected-file) "b/" "") selected-file))
        (forward-line 1) ;; Move past the +++ header
        (setq start-pos (point))
        
        ;; Find the NEXT header (or end of file)
        (if (re-search-forward "^--- " nil t)
            (setq end-pos (match-beginning 0))
          (setq end-pos (point-max)))
        
        (setq file-diff (buffer-substring start-pos end-pos)))

      ;; 4. Find/Open the actual file and create a patch buffer
      (let* ((target-file-path (expand-file-name selected-file (or (doom-project-root) default-directory)))
             (target-buf (find-file-noselect target-file-path))
             (patch-buf-name (format "*patch-%s*" selected-file))
             (patch-buf (get-buffer-create patch-buf-name)))
        
        (with-current-buffer patch-buf
          (erase-buffer)
          (insert-buffer-substring target-buf)
          (funcall (buffer-local-value 'major-mode target-buf)))

        ;; 5. Apply changes to the temp patch buffer
        (my-apply-hunks-to-buffer file-diff patch-buf)

        ;; 6. Launch Ediff
        (ediff-buffers target-buf patch-buf)))))

(defvar my-ediff-patch-queue nil
  "Queue of files to process for multi-file patching.")

(defun my-process-next-patch-in-queue ()
  "Pop the next patch from the queue and run Ediff."
  (if (null my-ediff-patch-queue)
      (message "All patches processed!")
    (let* ((patch-data (pop my-ediff-patch-queue))
           (filename (nth 0 patch-data))
           (diff-content (nth 1 patch-data))
           (project-root (if (project-current)
                             (project-root (project-current))
                           default-directory))
           (target-file-path (expand-file-name filename project-root)))

      (if (not (file-exists-p target-file-path))
          (progn
            (message "Skipping %s (file not found)" filename)
            (my-process-next-patch-in-queue))
        
        (let* ((target-buf (find-file-noselect target-file-path))
               (patch-buf-name (format "*patch-temp-%s*" filename))
               (patch-buf (get-buffer-create patch-buf-name)))
          
          ;; Prepare the patch buffer
          (with-current-buffer patch-buf
            (erase-buffer)
            (insert-buffer-substring target-buf)
            (funcall (buffer-local-value 'major-mode target-buf)))

          ;; Apply the context-based hunk application (reuse helper from before)
          (my-apply-hunks-to-buffer diff-content patch-buf)

          ;; Set up the hook to continue the chain when Ediff quits
          (add-hook 'ediff-quit-hook 'my-ediff-chain-handler)
          
          ;; Store buffers for cleanup in the hook
          (setq my-current-patch-buffers (list target-buf patch-buf))

          ;; Start Ediff
          (message "Ediffing %s..." filename)
          (ediff-buffers target-buf patch-buf))))))

(defvar my-current-patch-buffers nil)

(defun my-ediff-chain-handler ()
  "Cleanup current Ediff and trigger the next one."
  (remove-hook 'ediff-quit-hook 'my-ediff-chain-handler)
  
  ;; Optional: Kill the temporary patch buffer to keep things clean
  (when (and my-current-patch-buffers (get-buffer (cadr my-current-patch-buffers)))
    (kill-buffer (cadr my-current-patch-buffers)))
  
  ;; Run the next one after a short delay to let Ediff clean itself up
  (run-at-time 0.1 nil #'my-process-next-patch-in-queue))

(defun my-ediff-multifile-sequential ()
  "Parse clipboard for multiple files and Ediff them one by one."
  (interactive)
  (let* ((full-diff (current-kill 0))
         (file-header-regex "^\\+\\+\\+ \\(?:b/\\)?\\(.*\\)$")
         (start-pos 0))
    
    (setq my-ediff-patch-queue nil)

    ;; Parse the clipboard into a list of (filename, diff-content)
    (with-temp-buffer
      (insert full-diff)
      (goto-char (point-min))
      
      (while (re-search-forward file-header-regex nil t)
        (let* ((filename (match-string 1))
               (hunk-start (point))
               (hunk-end (save-excursion 
                           (if (re-search-forward file-header-regex nil t)
                               (match-beginning 0)
                             (point-max))))
               (diff-content (buffer-substring hunk-start hunk-end)))
          
          ;; Normalize filename (strip whitespace)
          (setq filename (string-trim filename))
          (push (list filename diff-content) my-ediff-patch-queue)
          (goto-char hunk-end))))
    
    (setq my-ediff-patch-queue (nreverse my-ediff-patch-queue))

    (if my-ediff-patch-queue
        (my-process-next-patch-in-queue)
      (user-error "No valid diffs found in clipboard."))))

(map! (:leader "aa" #'my-ediff-multifile-sequential))
(map! (:leader "ak" #'my-ediff-aider-udiff-from-clipboard))
