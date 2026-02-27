;;; nixos/editors/.doom.d/package_configuration/gptel/aider_search.el -*- lexical-binding: t; -*-

;;; Aider Search/Replace clipboard parsing + Ediff -*- lexical-binding: t; -*-

(defun my-aider--parse-sr-blocks (text)
  "Parse Search/Replace blocks with strict newline handling."
  (let (blocks)
    (with-temp-buffer
      (insert text)
      (goto-char (point-min))
      ;; Look for the marker at the start of a line
      (while (re-search-forward "^<<<<<<< SEARCH\n" nil t)
        (let ((search-start (point))
              filename search-content replace-content)
          ;; Filename is exactly one line above the SEARCH marker
          (save-excursion
            (goto-char (match-beginning 0))
            (forward-line -1)
            (setq filename (string-trim (buffer-substring-no-properties 
                                         (line-beginning-position) 
                                         (line-end-position)))))
          
          (when (re-search-forward "^=======\n" nil t)
            ;; Extract search content (includes the newline before =======)
            (setq search-content (buffer-substring-no-properties search-start (match-beginning 0)))
            (let ((replace-start (point)))
              (when (re-search-forward "^>>>>>>> REPLACE\n?" nil t)
                ;; Extract replace content
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
  "Convert SEARCH block into a regex that is fuzzy about indentation but strict about newlines."
  (let ((re (regexp-quote text)))
    ;; 1. Handle "..." as a multi-line wildcard
    (setq re (replace-regexp-in-string (regexp-quote "\\.\\.\\.") "[[:ascii:][:nonascii:]]*?" re t t))
    ;; 2. Make horizontal whitespace (spaces/tabs) fuzzy
    ;; This allows matching even if the AI uses different indentation levels.
    (setq re (replace-regexp-in-string "[ \t]+" "[ \t]*" re t t))
    re))

(defun my-aider-sr-process-next ()
  "Apply the patch to a temporary buffer and Ediff against the real file."
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
           (fuzzy-re (my-aider--make-fuzzy-regex search-text))
           ;; Disable case-folding for strict code matching
           (case-fold-search nil))

      (with-current-buffer patch-buf
        (erase-buffer)
        (insert-buffer-substring target-buf)
        (goto-char (point-min))
        
        (if (re-search-forward fuzzy-re nil t)
            (replace-match replace-text t t)
          (message "No match found for hunk in %s" filename))
        
        (funcall (buffer-local-value 'major-mode target-buf)))

      (setq my-aider-sr-temp-buffers (list patch-buf))
      (add-hook 'ediff-quit-hook #'my-aider-sr-chain-handler)
      (message "Ediffing %s..." filename)
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
