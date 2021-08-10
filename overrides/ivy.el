;;; overrides/ivy.el -*- lexical-binding: t; -*-

;; (defun +ivy-config/woccur (&optional args)
;;   (interactive)
;;   (swiper--occur-insert-lines (mapcar #'counsel--normalize-grep-match ivy--old-cands)))

;; (after! lsp
;;   (defun ivy-restrict-to-matches ()
;;     "Restrict candidates to current input and erase input."
;;     (interactive)
;;     (delete-minibuffer-contents)
;;     (if (ivy-state-dynamic-collection ivy-last)
;;       (progn
;; 	(setf (ivy-state-dynamic-collection ivy-last) nil)
;; 	(setf (ivy-state-collection ivy-last)
;; 	  (setq ivy--all-candidates ivy--old-cands)))
;;       (let* ((cands (ivy--filter ivy-text ivy--all-candidates)))
;; 	(setq ivy--all-candidates cands)
;; 	(setq ivy--old-cands cands)))))

;; (after! (ivy counsel swiper)
;;   (defun +ivy/woccur-custom ()
;;     "MODIFIED FUNCTION. Invoke a wgrep buffer on the current ivy results, if supported."
;;     (interactive)
;;     (unless (window-minibuffer-p)
;;       (user-error "No completion session is active"))
;;     (require 'wgrep)

;;     (let ((caller (ivy-state-caller ivy-last)))
;;       (if-let (occur-fn (plist-get +ivy-edit-functions caller))
;; 	(ivy-exit-with-action
;; 	  (lambda (_) (funcall occur-fn)))
;; 	(if-let (occur-fn '+ivy-config/woccur)
;; 	  (let ((buffer (generate-new-buffer
;; 			  (format "*ivy-occur%s \"%s\"*"
;; 			    (if caller (concat " " (prin1-to-string caller)) "")
;; 			    ivy-text))))
;; 	    (with-current-buffer buffer
;; 	      (let ((inhibit-read-only t))
;; 		(erase-buffer)
;; 		(funcall occur-fn))
;; 	      (setq ivy-occur-last ivy-last)
;; 	      (setq-local ivy--directory ivy--directory))
;; 	    (ivy-exit-with-action
;; 	      `(lambda (_)
;; 		 (pop-to-buffer ,buffer)
;; 		 (ivy-wgrep-change-to-wgrep-mode))))
;; 	  (user-error "%S doesn't support wgrep" caller))))))



;; ;; S-SPC not working
;; (map!
;;   :map projectile-mode-map
;;   "C-SPC" #'ivy-restrict-to-matches
;;   "C-c C-e" '+ivy/woccur-custom)
