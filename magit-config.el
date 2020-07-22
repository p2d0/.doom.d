;;; ~/.doom.d/magit-config.el -*- lexical-binding: t; -*-

(defun magit-toggle-status (buf)
		(if-let ((win (get-buffer-window buf)))
				(delete-window  win)
			(display-buffer-in-side-window buf
																		 '((side . right)
																			 (window-width . 50))))
		(display-buffer buf))

(defun magit-status-toggle ()
	(if-let ((win (get-buffer-window buf)))
			(delete-window  win)
		(display-buffer-in-side-window buf
																	 '((side . right)
																		 (window-width . 50)))))

(setq magit-display-buffer-function 'display-buffer)
