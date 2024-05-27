;;; nixos/editors/.doom.d/package_configuration/telega/telega.el -*- lexical-binding: t; -*-
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

(after! telega
	(require 'telega-dired-dwim)
	(global-telega-squash-message-mode)
	(setq telega-notifications-mode 1)
	(setq telega-emoji-use-images nil)
	(setq telega-chat-input-markups '("org" "markdown2"))
	;; (setq telega-filter-default '(and main top))
	(add-hook 'telega-load-hook #'telega-notifications-mode)
	(load! "choices.el")
	(defun test-send-message ()
		(interactive)
		(telega--sendMessage telega-chatbuf--chat (list :@type "inputMessageSticker"
																								:sticker (list :@type "inputFileRemote" :id "CAACAgEAAxkDAAEF-ipmVFORmG-MULKGXhv4j0d-unyCKwACEQcAAsTJswOwrIcn0_a7izUE")
																								)))

	(add-hook 'telega-chat-post-message-hook #'telega-if-kappa-send-sticker 100)
	(advice-add 'telega-squash-message--send-message :around 'telega-if-kappa-tester)
	(map! :map telega-chat-mode-map
		:n "Zk" #'telega-insert-kappa))

(defun telega-insert-kappa ()
	(interactive)
	(let* (
					(choices '(("Kappa" . "CAACAgEAAxkDAAEF-ipmVFORmG-MULKGXhv4j0d-unyCKwACEQcAAsTJswOwrIcn0_a7izUE")
											("Monsters Inc" . "CAACAgIAAxkDAAEF-gZmU6tWR3gn86q4E1PQSxjepshCegACN1IAAt3T-EhRSg__piCCYjUE")
											("Povel durev" . "CAACAgIAAx0EX863OQACqsZmVFQUDTzV1b1ca-7cTSeOgroxAQAC2UQAAn_sqEi1g3e4gaIY-jUE")
											("Taps temple" . "CAACAgIAAxkDAAEF-01mVLIgLdqqi4C8_U5ew_QYsXxuNQACkUsAApwHqUhIBZp0Hsk-QTUE")
											("Cat creepy smile" . "CAACAgIAAxkDAAEF-05mVLKybxqnvIoGSFUF_eau9owi2QACNwoAAiqoEEqhwiI9a9XVDjUE")
											))
					(choice-options (mapcar 'car choices))
					(choice (completing-read "Choose sticker: " choice-options))
					(sticker-id (alist-get choice choices nil nil #'equal)))
		;; (prin1 sticker)
		(send-sticker sticker-id)
		)
	)

;; (defun telega-sticker-completion-at-point ()
;;   "Provide sticker completions at point."
;;   (let* ((choices '(("Kappa" . "CAACAgEAAxkDAAEF-ipmVFORmG-MULKGXhv4j0d-unyCKwACEQcAAsTJswOwrIcn0_a7izUE")
;;                     ("Monsters Inc" . "CAACAgIAAxkDAAEF-gZmU6tWR3gn86q4E1PQSxjepshCegACN1IAAt3T-EhRSg__piCCYjUE")
;;                     ("Povel durev" . "CAACAgIAAx0EX863OQACqsZmVFQUDTzV1b1ca-7cTSeOgroxAQAC2UQAAn_sqEi1g3e4gaIY-jUE")))
;; 				(bounds (bounds-of-thing-at-point 'word))
;;          (start (car bounds))
;;          (end (cdr bounds))
;;          (completion (try-completion (buffer-substring start end) choices)))
;;     (list start end (mapcar 'car choices)
;;           :annotation-function (lambda (choice)
;;                                  (format " [%s]" (cdr (assoc choice choices))))
;;           :exit-function (lambda (chosen _status)
;;                            (when (member chosen (mapcar 'car choices))
;;                              (send-sticker (cdr (assoc chosen choices))))))))

(defun send-sticker (sticker-id &optional chat)
	(telega--sendMessage (or telega-chatbuf--chat chat) (list :@type "inputMessageSticker"
																												:sticker (list :@type "inputFileRemote" :id sticker-id)
																												)))

(defun telega-if-kappa-send-sticker (msg)
	"Send a sticker if the message contains 'Kappa', 'Keepo', or 'Кееро'."
	(when-let* ((text (telega--tl-get msg :content :text :text))
							 (chat (telega--getChat (telega--tl-get msg :chat_id))))
		(when (string-match-p (regexp-opt '("Kappa" "Keepo" "Кееро")) text)
			(send-sticker "CAACAgEAAxkDAAEF-ipmVFORmG-MULKGXhv4j0d-unyCKwACEQcAAsTJswOwrIcn0_a7izUE" chat))))

(defun telega-if-kappa-tester (squash-fun send-msg-fun chat imc &optional reply-to-msg options &rest args)
	(let ((text (telega--tl-get imc :text :text)))
		(if (and text (string-match-p (regexp-opt '("Kappa" "Keepo" "Кееро")) text))
			(apply send-msg-fun chat imc reply-to-msg options args)
			(apply squash-fun send-msg-fun chat imc reply-to-msg options args)
			)))
