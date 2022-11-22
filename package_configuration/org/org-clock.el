;;; editors/.doom.d/package_configuration/org/org-clock.el -*- lexical-binding: t; -*-

(defun my/org-clock-query-out ()
  "Ask the user before clocking out.
This is a useful function for adding to `kill-emacs-query-functions'."
  (if (and
				(featurep 'org-clock)
				(funcall 'org-clocking-p)
				(y-or-n-p "You are currently clocking time, clock out? "))
    (org-clock-out)
    t)) ;; only fails on keyboard quit or error

;; timeclock.el puts this on the wrong hook!
(add-hook 'kill-emacs-query-functions 'my/org-clock-query-out)
;; (add-hook 'kill-emacs-query-functions '+workspace/close-window-or-workspace)

(defun my/quit-emacs ()
	(interactive)
	(run-hooks 'kill-emacs-query-functions)
	(save-buffers-kill-terminal))
(map!
	:leader "qq" #'my/quit-emacs)
