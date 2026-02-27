;;; nixos/editors/.doom.d/package_configuration/gptel/aider_search.el -*- lexical-binding: t; -*-

;;; Aider Search/Replace clipboard parsing + Ediff -*- lexical-binding: t; -*-

(defun my-aider--parse-sr-blocks (text)
  "Parse multiple Aider SEARCH/REPLACE blocks from TEXT.
The filename must be on the line immediately preceding the SEARCH marker.
Works whether or not backticks were included in the copy."
  (let (blocks)
    (with-temp-buffer
      (insert text)
      (goto-char (point-min))
      ;; Search for every instance of the SEARCH marker
      (while (re-search-forward "^<<<<<<< SEARCH$" nil t)
        (let ((hunk-marker-start (match-beginning 0))
              (search-start (point)) ; Start of content after SEARCH line
              filename search-content replace-content)
          
          ;; 1. Identify filename: look at the line immediately above the marker
          (save-excursion
            (goto-char hunk-marker-start)
            (forward-line -1)
            (setq filename (string-trim (buffer-substring-no-properties 
                                         (line-beginning-position) 
                                         (line-end-position)))))

          ;; 2. Find the Divider
          (when (re-search-forward "^=======$" nil t)
            (setq search-content (buffer-substring-no-properties search-start (match-beginning 0)))
            (let ((replace-start (point)))
              ;; 3. Find the End marker
              (when (re-search-forward "^>>>>>>> REPLACE$" nil t)
                (setq replace-content (buffer-substring-no-properties replace-start (match-beginning 0)))
                
                (when (and filename (not (string-empty-p filename)))
                  (push (list filename search-content replace-content) blocks))))))))
    (nreverse blocks)))

(defvar my-aider-sr-queue nil "Queue for Search/Replace Ediff.")
(defvar my-aider-sr-temp-buffers nil "Buffers to clean up after Ediff.")

(defun my-aider--apply-sr-to-string (original-text search-text replace-text)
  "Replace SEARCH-TEXT with REPLACE-TEXT in ORIGINAL-TEXT, handling '...' fuzzy matching."
  (let ((regex (regexp-quote search-text)))
    ;; Convert '...' in search block to a non-greedy catch-all regex
    (setq regex (replace-regexp-in-string (regexp-quote "...") ".*?" regex nil t))
    ;; Replace exactly once
    (replace-regexp-in-string regex replace-text original-text t t)))

(defun my-aider-sr-chain-handler ()
  "Cleanup and move to next file in the Search/Replace queue."
  (remove-hook 'ediff-quit-hook #'my-aider-sr-chain-handler)
  (when my-aider-sr-temp-buffers
    (mapc (lambda (buf) (when (buffer-live-p buf) (kill-buffer buf))) 
          my-aider-sr-temp-buffers)
    (setq my-aider-sr-temp-buffers nil))
  (run-at-time 0.1 nil #'my-aider-sr-process-next))

(defun my-aider--make-fuzzy-regex (text)
  "Convert Search block TEXT into a flexible regex.
Handles '...' as a wildcard and makes whitespace/newlines flexible."
  (let ((re (regexp-quote (string-trim text))))
    ;; 1. Convert the quoted "..." (which is "\\.\\.\\.") into a multi-line wildcard
    (setq re (replace-regexp-in-string (regexp-quote "\\.\\.\\.") "[[:ascii:][:nonascii:]]*?" re t t))
    ;; 2. Make all whitespace (including newlines) flexible.
    ;; This handles differences in indentation or empty lines.
    (setq re (replace-regexp-in-string "[ \t\n\r]+" "[ \t\n\r]+" re t t))
    re))

(defun my-aider-sr-process-next ()
  "Pop the next hunk from the queue, apply patch to the WHOLE file, and Ediff."
  (if (null my-aider-sr-queue)
      (message "All Search/Replace hunks processed!")
    (let* ((hunk (pop my-aider-sr-queue))
           (filename (nth 0 hunk))
           (search-text (nth 1 hunk))
           (replace-text (nth 2 hunk))
           (project-root (or (and (fboundp 'doom-project-root) (doom-project-root)) default-directory))
           (target-path (expand-file-name filename project-root))
           (target-buf (find-file-noselect target-path))
           (patch-buf (get-buffer-create (format "*aider-patch-%s*" filename)))
           (fuzzy-re (my-aider--make-fuzzy-regex search-text)))

      ;; Copy original file to patch buffer
      (with-current-buffer patch-buf
        (erase-buffer)
        (insert-buffer-substring target-buf)
        (goto-char (point-min))
        
        ;; Apply the fuzzy patch
        (if (re-search-forward fuzzy-re nil t)
            (replace-match replace-text t t)
          (message "Error: Could not find match for %s. Check SEARCH block." filename))
        
        (funcall (buffer-local-value 'major-mode target-buf)))

      (setq my-aider-sr-temp-buffers (list patch-buf))
      (add-hook 'ediff-quit-hook #'my-aider-sr-chain-handler)
      
      (message "Ediffing %s..." filename)
      ;; Ensure we start at the top so Ediff can find the diff
      (ediff-buffers target-buf patch-buf))))

(defun my-aider-ediff-sr-from-clipboard ()
  "Parse clipboard and start sequential Ediff for Search/Replace blocks."
  (interactive)
  (let* ((text (current-kill 0))
         (blocks (my-aider--parse-sr-blocks text))) ; Using the parser we built earlier
    (if (null blocks)
        (user-error "No Aider SEARCH/REPLACE blocks found in clipboard.")
      (setq my-aider-sr-queue blocks)
      (my-aider-sr-process-next))))
