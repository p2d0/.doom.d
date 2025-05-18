;;; editors/.doom.d/package_configuration/dired/dired.el -*- lexical-binding: t; -*-

(defun dired--do-shell (command-string)
  (interactive)
  (dired-do-shell-command
   command-string current-prefix-arg
   (dired-get-marked-files t current-prefix-arg)))

(defun dired-jpg-down-to ()
	(interactive)
	(dired--do-shell (s-concat "jpegoptim -S " (read-string "Size in Kb default 768: " nil nil "768") " ?" )))

(after! dired-preview
	(setq dired-preview-delay 0.2)
	(map! :map dired-mode-map
		:n "C-d" #'dired-preview-page-down
		:n "C-u" #'dired-preview-page-up
		)
	)
