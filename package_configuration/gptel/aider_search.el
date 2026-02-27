;;; nixos/editors/.doom.d/package_configuration/gptel/aider_search.el -*- lexical-binding: t; -*-

;;; Aider Search/Replace clipboard parsing + Ediff -*- lexical-binding: t; -*-

(defun my-aider--parse-sr-blocks (text)
  "Parse Search/Replace blocks, grouping multiple hunks by filename."
  (let (files-alist current-file)
    (with-temp-buffer
      (insert text)
      (goto-char (point-min))
      (while (not (eobp))
        (let ((line (string-trim (buffer-substring-no-properties (line-beginning-position) (line-end-position)))))
          (cond
           ;; 1. Detect Search Marker
           ((string-prefix-p "<<<<<<< SEARCH" line)
            (let ((search-start (progn (forward-line 1) (point))))
              (if (re-search-forward "^=======\n" nil t)
                  (let ((search-content (buffer-substring-no-properties search-start (match-beginning 0)))
                        (replace-start (point)))
                    (if (re-search-forward "^>>>>>>> REPLACE\n?" nil t)
                        (let ((replace-content (buffer-substring-no-properties replace-start (match-beginning 0))))
                          (if (not current-file)
                              (message "Warning: Found hunk without filename context.")
                            (let ((existing (assoc current-file files-alist)))
                              (if existing
                                  (setcdr existing (append (cdr existing) (list (list search-content replace-content))))
                                (push (list current-file (list search-content replace-content)) files-alist))))))))))
           
           ;; 2. Detect Filename (not a marker, not empty, looks like a path/file)
           ((and (not (string-empty-p line))
                 (not (string-prefix-p ">" line))
                 (not (string-prefix-p "=" line))
                 (not (string-prefix-p "<" line))
                 (or (string-match-p "/" line) (string-match-p "\\." line)))
            (setq current-file line)
            (forward-line 1))
           
           (t (forward-line 1))))))
    (nreverse files-alist)))

(defvar my-aider-sr-queue nil "Queue of files to process.")
(defvar my-aider-sr-temp-buffers nil)

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
  "Convert SEARCH block into a regex that is fuzzy about indentation but strict about newlines."
  (let ((re (regexp-quote text)))
    ;; 1. Handle "..." as a multi-line wildcard
    (setq re (replace-regexp-in-string (regexp-quote "\\.\\.\\.") "[[:ascii:][:nonascii:]]*?" re t t))
    ;; 2. Make horizontal whitespace (spaces/tabs) fuzzy
    ;; This allows matching even if the AI uses different indentation levels.
    (setq re (replace-regexp-in-string "[ \t]+" "[ \t]*" re t t))
    re))

(defun my-aider-sr-process-next ()
  "Process the next file in the queue, applying all its hunks at once."
  (if (null my-aider-sr-queue)
      (message "All files processed!")
    (let* ((file-entry (pop my-aider-sr-queue))
           (filename (car file-entry))
           (hunks (cdr file-entry))
           (project-root (or (and (fboundp 'doom-project-root) (doom-project-root)) default-directory))
           (target-path (expand-file-name filename project-root))
           (target-buf (find-file-noselect target-path))
           (patch-buf (get-buffer-create (format "*aider-patch-%s*" filename)))
           (case-fold-search nil))

      (with-current-buffer patch-buf
        (erase-buffer)
        (insert-buffer-substring target-buf)
        ;; Apply EVERY hunk for this file to the temp buffer
        (dolist (hunk hunks)
          (let ((search-text (nth 0 hunk))
                (replace-text (nth 1 hunk)))
            (goto-char (point-min))
            (if (re-search-forward (my-aider--make-fuzzy-regex search-text) nil t)
                (replace-match replace-text t t)
              (message "Could not match a hunk in %s" filename))))
        (funcall (buffer-local-value 'major-mode target-buf)))

      (setq my-aider-sr-temp-buffers (list patch-buf))
      (add-hook 'ediff-quit-hook #'my-aider-sr-chain-handler)
      (ediff-buffers target-buf patch-buf))))

(defun my-aider-ediff-sr-from-clipboard ()
  "Group hunks by file and start Ediff."
  (interactive)
  (let* ((text (current-kill 0))
         (files-alist (my-aider--parse-sr-blocks text)))
    (if (null files-alist)
        (user-error "No Search/Replace blocks found.")
      (setq my-aider-sr-queue files-alist)
      (my-aider-sr-process-next))))
