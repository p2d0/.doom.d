;;; nixos/editors/.doom.d/package_configuration/gptel/aider_whole.el -*- lexical-binding: t; -*-


;;; Whole-file (editor-whole / whole) clipboard parsing + Ediff -*- lexical-binding: t; -*-

(require 'subr-x)

(require 'subr-x)

(defun my-aider--looks-like-path-p (s)
  "Heuristic: does S look like a repo-relative file path?"
  (let ((s (string-trim s)))
    (and (string-match-p "\\`[[:graph:]]+\\'" s)
         ;; avoid obvious non-path lines
         (not (string-match-p "\\`\\(;\\|#\\|//\\)" s))
         ;; require either a slash path or an extension-ish dot segment
         (or (string-match-p "/" s)
             (string-match-p "\\.[[:alnum:]]\\{1,8\\}\\'" s)))))

(defun my-aider--parse-whole-blocks (text)
  "Parse Aider whole-file listings from TEXT.

Returns a list of (FILENAME CONTENT) pairs.

Supports:
  A) Old:  filename\\n``````
  B) New:  ``````
  C) Unfenced (clipboard lost fences): filename\\n...EOF"
  (let (blocks)
    (with-temp-buffer
      (insert text)
      (goto-char (point-min))

      ;; 1) Fenced variants (A & B)
      (let ((prefix-re
             (concat
              "^\\(?:"
              ;; A) filename line then opening fence
              "\\([[:graph:]][^\n]*\\)\n\\(?:\\s-*\n\\)*```"
              "\\|"
              ;; B) opening fence then filename line
              "```[^`\n]*\\s-*\n\\([[:graph:]][^\n]*\\)\n"
              "\\)")))
        (while (re-search-forward prefix-re nil t)
          (let* ((filename (string-trim (or (match-string 1) (match-string 2))))
                 (content-start (point))
                 (content-end (if (re-search-forward "^```")
                                  (match-beginning 0)
                                (point-max)))
                 (content (buffer-substring-no-properties content-start content-end)))
            (push (list filename content) blocks))))

      (setq blocks (nreverse blocks))

      ;; 2) Fallback: unfenced single/multi (best-effort)
      (when (null blocks)
        (goto-char (point-min))
        (skip-chars-forward "\n\t\s")
        (let ((filename (string-trim (buffer-substring-no-properties
                                      (line-beginning-position)
                                      (line-end-position)))))
          (when (my-aider--looks-like-path-p filename)
            (forward-line 1)
            (let ((content (buffer-substring-no-properties (point) (point-max))))
              (setq blocks (list (list filename content))))))))

    blocks))

(defun my-ediff-aider-whole-from-clipboard ()
  "Ediff current file (or chosen file) against Aider 'whole' content in clipboard."
  (interactive)
  (let* ((text (current-kill 0))
         (blocks (my-aider--parse-whole-blocks text)))
    (unless blocks
      (user-error "No Aider whole-file blocks found in clipboard."))

    (let* ((project-root (if (project-current)
                             (project-root (project-current))
                           (or (doom-project-root) default-directory)))
           (current-rel (when buffer-file-name
                          (file-relative-name buffer-file-name project-root)))
           (filenames (mapcar #'car blocks))
           (selected (cond
                      ((and current-rel (member current-rel filenames)) current-rel)
                      ((= (length blocks) 1) (car (car blocks)))
                      (t (completing-read "Select file to Ediff: " filenames nil t))))
           (new-content (cadr (assoc selected blocks)))
           (target-path (expand-file-name selected project-root))
           (target-buf (find-file-noselect target-path))
           (patch-buf (get-buffer-create (format "*aider-whole-%s*" selected))))

      (with-current-buffer patch-buf
        (erase-buffer)
        (insert new-content)
        ;; Match major mode for nicer Ediff/Font-lock.
        (funcall (buffer-local-value 'major-mode target-buf)))

      (ediff-buffers target-buf patch-buf))))

(defvar my-ediff-whole-patch-queue nil
  "Queue of (filename content) for sequential whole-file Ediff.")

(defvar my-current-whole-patch-buffers nil
  "Holds (target-buf patch-buf) for cleanup after each Ediff.")

(defun my-ediff-whole-chain-handler ()
  "Cleanup current whole-file Ediff and trigger the next queued file."
  (remove-hook 'ediff-quit-hook 'my-ediff-whole-chain-handler)
  (when (and my-current-whole-patch-buffers
             (get-buffer (cadr my-current-whole-patch-buffers)))
    (kill-buffer (cadr my-current-whole-patch-buffers)))
  (setq my-current-whole-patch-buffers nil)
  (run-at-time 0.1 nil #'my-process-next-whole-patch-in-queue))

(defun my-process-next-whole-patch-in-queue ()
  "Pop the next whole-file patch from the queue and run Ediff."
  (if (null my-ediff-whole-patch-queue)
      (message "All whole-file patches processed!")
    (let* ((patch (pop my-ediff-whole-patch-queue))
           (filename (nth 0 patch))
           (new-content (nth 1 patch))
           (project-root (if (project-current)
                             (project-root (project-current))
                           (or (doom-project-root) default-directory)))
           (target-path (expand-file-name filename project-root))
           (target-buf (find-file-noselect target-path))
           (patch-buf (get-buffer-create (format "*aider-whole-%s*" filename))))

      (with-current-buffer patch-buf
        (erase-buffer)
        (insert new-content)
        (funcall (buffer-local-value 'major-mode target-buf)))

      (add-hook 'ediff-quit-hook 'my-ediff-whole-chain-handler)
      (setq my-current-whole-patch-buffers (list target-buf patch-buf))
      (message "Ediffing (whole) %s..." filename)
      (ediff-buffers target-buf patch-buf))))

(defun my-ediff-multifile-sequential-whole ()
  "Parse clipboard for Aider 'whole' blocks and Ediff them sequentially."
  (interactive)
  (let* ((text (current-kill 0))
         (blocks (my-aider--parse-whole-blocks text)))
    (unless blocks
      (user-error "No Aider whole-file blocks found in clipboard."))
    (setq my-ediff-whole-patch-queue blocks)
    (my-process-next-whole-patch-in-queue)))

;; (map! (:leader "aa" #'my-ediff-multifile-sequential-whole))
;; (map! (:leader "ak" #'my-ediff-aider-whole-from-clipboard))
