;;; ~/.doom.d/magit-config.el -*- lexical-binding: t; -*-

(after! magit
  (setq magit-display-buffer-function 'display-buffer)
  (setq magit-diff-expansion-threshold 3)
  (setq magit-diff-highlight-trailing nil)
  (setq magit-diff-paint-whitespace nil)
  (setq magit-diff-highlight-hunk-body nil)
  (setq magit-section-highlight-hook '())
  (setq magit-diff-sections-hook '(magit-insert-diff))
  (setq magit-diff-highlight-hunk-region-functions '())
  (setq magit-diff-refine-hunk nil)
	(remove-hook 'server-switch-hook 'magit-commit-diff)
	(remove-hook 'with-editor-filter-visit-hook 'magit-commit-diff))

(defun my/magit-auto-add-and-push-date-tag (&optional target)
  "Create a Git tag in YYYY.MDD.N format (e.g. 2026.724.0) and push to remote."
  (interactive)
  ;; %-m = unpadded month (7), %d = 2-digit day (24) -> 2026.724.
  (let* ((date-prefix (format-time-string "%Y.%-m%d."))
         (pattern (concat date-prefix "*"))
         (existing-tags (magit-git-lines "tag" "-l" pattern))
         (max-suffix -1))
    ;; Parse existing tags matching today's prefix to find highest suffix N
    (dolist (tag existing-tags)
      (when (string-match (concat "^" (regexp-quote date-prefix) "\\([0-9]+\\)$") tag)
        (let ((num (string-to-number (match-string 1 tag))))
          (when (> num max-suffix)
            (setq max-suffix num)))))
    
    (let* ((new-tag (format "%s%d" date-prefix (1+ max-suffix)))
           (remote (magit-read-remote "Push tag to remote" nil t)))
      (if (y-or-n-p (format "Create and push tag '%s' to '%s'%s? " 
                            new-tag 
                            remote
                            (if target (format " at %s" target) "")))
          (progn
            ;; 1. Create local tag
            (if target
                (magit-run-git "tag" new-tag target)
              (magit-run-git "tag" new-tag))
            ;; 2. Push tag to remote
            (run-hooks 'magit-credential-hook)
            (magit-run-git-async "push" "-v" remote new-tag)
            (message "Created and pushed tag: %s" new-tag))
        (message "Tag creation canceled.")))))

(after! magit
  (transient-append-suffix 'magit-tag "t"
    '("a" "Auto Date Tag" my/magit-auto-add-and-push-date-tag)))

;; (after! magit-section
;; 	(defun magit-section-show (section)
;; 		"Show the body of the current section."
;; 		(interactive (list (magit-current-section)))
;; 		(oset section hidden nil)
;; 		(magit-section--maybe-wash section)
;; 		(when-let ((beg (oref section content)))
;; 			(when (< (- (oref section end) beg) 15000)
;; 				(remove-overlays beg (oref section end) 'invisible t)))
;; 		(magit-section-maybe-update-visibility-indicator section)
;; 		(magit-section-maybe-cache-visibility section)
;; 		(dolist (child (oref section children))
;; 			(if (oref child hidden)
;; 				(magit-section-hide child)
;; 				(magit-section-show child)))))
