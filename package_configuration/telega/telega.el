;;; nixos/editors/.doom.d/package_configuration/telega/telega.el -*- lexical-binding: t; -*-

(after! telega
	(require 'telega-dired-dwim)
	(global-telega-squash-message-mode)
	(setq telega-notifications-mode 1)
	(add-hook 'telega-load-hook #'telega-notifications-mode))

(defvar kek-timer nil
  "Timer object for running `kek` every 10 seconds.")

(defun kek ()
  "Send typing action to a specified chat in Telega."
  (telega--sendChatAction
   (telega--getChat
    ;; "874727779"
    ;; "216082031"
    ;; "-454024920"
		 "216082031"
		 ;; "-1001607382841"
    )
   (list :@type "chatActionTyping")))

(defun start-kek-timer ()
  "Start the timer to run `kek` every 10 seconds."
  (setq kek-timer (run-at-time 0 10 'kek)))

(defun stop-kek-timer ()
  "Stop the timer running `kek`."
  (when (timerp kek-timer)
    (cancel-timer kek-timer)
    (setq kek-timer nil)))

;; Start the timer

;; To stop the timer, call `stop-kek-timer`
