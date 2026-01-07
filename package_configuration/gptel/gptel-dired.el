;;; gptel-dired.el --- Dired integration for gptel context  -*- lexical-binding: t; -*-

(require 'gptel-context)
(require 'dired)
(require 'cl-lib)

(defvar gptel-context) ; Silence byte-compiler

(defun my/gptel--force-insert-file (path)
  "Insert PATH even if not visited or collected via Dired."
  (let ((coding-system-for-read 'utf-8))
    (insert
     (with-temp-buffer
       (insert-file-contents-literally path)
       (buffer-string)))))

(advice-add
 'gptel-context--insert-file-string
 :override
 (lambda (path &optional spec)
   (when (file-readable-p path)
     (insert (format "In file `%s`:\n\n```\n"
                     (abbreviate-file-name path)))
     (my/gptel--force-insert-file path)
     (insert "\n```\n"))))

(defun gptel-dired-highlight ()
  "Highlight files in the current Dired buffer that are in the gptel context."
  (interactive)
  (remove-overlays (point-min) (point-max) 'category 'gptel-dired)
  (let ((context-files (cl-loop for ctx in gptel-context
                                for path = (car (ensure-list ctx))
                                when (stringp path)
                                collect (expand-file-name path))))
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
        (when-let ((filename (dired-get-filename nil t)))
          (when (member (expand-file-name filename) context-files)
            (save-excursion
              (let* ((beg (dired-move-to-filename))
                     (end (dired-move-to-end-of-filename))
                     (ov (make-overlay beg end)))
                (overlay-put ov 'category 'gptel-dired)
                (overlay-put ov 'face 'gptel-context-highlight-face)
                (overlay-put ov 'evaporate t)))))
        (forward-line 1)))))

(defun gptel-dired-add-marked ()
  "Add marked files in Dired to gptel context and highlight them."
  (interactive)
  (dolist (file (dired-get-marked-files))
    (gptel-context-add-file file))
  (gptel-dired-highlight))

(defun gptel-dired-remove-marked ()
  "Remove marked files in Dired from gptel context and update highlights."
  (interactive)
  (dolist (file (dired-get-marked-files))
    (gptel-context-remove file))
  (gptel-dired-highlight))

(defun gptel-dired-toggle-marked ()
  "Toggle gptel context for marked files in Dired.

If a directory is marked:
- Remove it (recursively) if any of its files are currently in context.
- Otherwise, add it (recursively)."
  (interactive)
  (let ((files (dired-get-marked-files)))
    (dolist (path files)
      (let ((full-path (expand-file-name path)))
        (if (file-directory-p full-path)
            ;; Directory handling
            (let ((dir-prefix (file-name-as-directory full-path)))
              (if (cl-some (lambda (entry)
                             (let ((key (car (ensure-list entry))))
                               (and (stringp key)
                                    (string-prefix-p dir-prefix key))))
                           gptel-context)
                  (gptel-context-remove full-path)
                (gptel-context-add-file full-path)))
          ;; File handling
          (if (assoc full-path gptel-context)
              (gptel-context-remove full-path)
            (gptel-context-add-file full-path))))))
  (gptel-dired-highlight))

;; Ensure highlights are refreshed when Dired buffer is updated
(add-hook 'dired-after-readin-hook #'gptel-dired-highlight)

(provide 'gptel-dired)
(map! :map dired-mode-map :localleader "a" #'gptel-dired-toggle-marked)
