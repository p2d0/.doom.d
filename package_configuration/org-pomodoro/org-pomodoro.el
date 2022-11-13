;;; package_configuration/org-pomodoro/org-pomodoro.el -*- lexical-binding: t; -*-

(after! org-pomodoro
	(setq org-pomodoro-ticking-sound-p t)
	;; (setq org-pomodoro-finished-sound
	;; 	(concat (file-name-directory (locate-library "org-pomodoro"))
	;; 		"resources/bell_multiple.wav"))
	)

(map!
	:map 'org-mode-map
	:localleader "cp" #'org-pomodoro)
