;;; nixos/editors/.doom.d/package_configuration/eat/eat.el -*- lexical-binding: t; -*-

;; (advice-add #'compilation-start :override #'eat-compilation-start)
;; (defun eat-compilation-start (command &optional mode name-function highlight-regexp continue)
;; 	(let ((name-of-mode "compilation")
;; 				 (dir default-directory)
;; 				 outbuf)
;; 		(if (or (not mode) (eq mode t))
;; 			(setq mode #'compilation-minor-mode)
;; 			(setq name-of-mode (replace-regexp-in-string "-mode\\'" "" (symbol-name mode))))
;; 		(with-current-buffer
;; 			(setq outbuf
;; 				(get-buffer-create
;; 					(compilation-buffer-name name-of-mode mode name-function)))
;; 			(setq default-directory dir)
;; 			(setq buffer-read-only nil)
;; 			(erase-buffer)
;; 			(compilation-insert-annotation
;; 				"-*- mode: " name-of-mode
;; 				"; default-directory: "
;; 				(prin1-to-string (abbreviate-file-name default-directory))
;; 				" -*-\n")
;; 			(compilation-insert-annotation
;; 				(format "%s started at %s\n\n"
;; 					mode-name
;; 					(substring (current-time-string) 0 19))
;; 				command "\n")
;; 			(eat-mode)
;; 			(eat-exec outbuf "*compile*" shell-file-name nil (list "-lc" command))
;; 			(run-hook-with-args 'compilation-start-hook (get-buffer-process outbuf))
;; 			(eat-emacs-mode)
;; 			(funcall mode)
;; 			(setq next-error-last-buffer outbuf)
;; 			(display-buffer outbuf '(nil (allow-no-window . t)))
;; 			(when-let (w (get-buffer-window outbuf))
;; 				(set-window-start w (point-min))))))

(map!
	:map eat-mode-map
	:n "C-k" #'compilation-previous-error
	:n "C-j" #'compilation-next-error
	)
