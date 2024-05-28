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
	(require 'telega-status-history)
	(telega-status-history-mode)
	(global-telega-squash-message-mode)
	(telega-autoplay-mode)
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
					(choices '(
											("Kappa" . "CAACAgEAAxkDAAEF-ipmVFORmG-MULKGXhv4j0d-unyCKwACEQcAAsTJswOwrIcn0_a7izUE")
											("Кееро" . "CAACAgEAAxkDAAEF-ipmVFORmG-MULKGXhv4j0d-unyCKwACEQcAAsTJswOwrIcn0_a7izUE")
											("Monsters Inc" . "CAACAgIAAxkDAAEF-gZmU6tWR3gn86q4E1PQSxjepshCegACN1IAAt3T-EhRSg__piCCYjUE")
											("Povel durev" . "CAACAgIAAx0EX863OQACqsZmVFQUDTzV1b1ca-7cTSeOgroxAQAC2UQAAn_sqEi1g3e4gaIY-jUE")
											("Taps temple" . "CAACAgIAAxkDAAEF-01mVLIgLdqqi4C8_U5ew_QYsXxuNQACkUsAApwHqUhIBZp0Hsk-QTUE")
											("Cat creepy smile" . "CAACAgIAAxkDAAEF-05mVLKybxqnvIoGSFUF_eau9owi2QACNwoAAiqoEEqhwiI9a9XVDjUE")
											("Позитивчик" . "CAACAgIAAxkDAAEF-rVmVHHZzJvgVBYY-3CDFnLsvvbCOAACmhYAAtWaCUm0dVDgdBrLzzUE")
											("Positive" . "CAACAgIAAxkDAAEF-rVmVHHZzJvgVBYY-3CDFnLsvvbCOAACmhYAAtWaCUm0dVDgdBrLzzUE")
											("Negative" . "CAACAgIAAxUAAWZQ-0m-O4Q2GQuVEqbB3EWcyQEzAAKfFgACiUEISWcQ0MRBWShsNQQ")
											("Негативчик" . "CAACAgIAAxUAAWZQ-0m-O4Q2GQuVEqbB3EWcyQEzAAKfFgACiUEISWcQ0MRBWShsNQQ")
											("Drakepc" . "CAACAgIAAxkBAAEF-91mVb_IRQJA_V34KM_WKddNrmk73wAC8BUAAsoz2UvNOg9kKyyItjUE")
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
(defun telega-chat-message-thread-id--advice (fun chat &rest args)
	(if-let (id (plist-get chat :message_thread_id))
		id
		(apply fun chat args)))

(advice-add 'telega-chat-message-thread-id :around #'telega-chat-message-thread-id--advice)

(defun send-sticker (sticker-id &optional chat)
	(telega--sendMessage (or telega-chatbuf--chat chat) (list :@type "inputMessageSticker"
																												:sticker (list :@type "inputFileRemote" :id sticker-id)
																												)))
(defun telega-if-kappa-send-sticker (msg)
  "Send a sticker if the message contains 'Kappa', 'Keepo', 'Кееро', or 'лул'."
	(prin1 msg)
  (when (plist-get msg :is_outgoing)
		(let* ((text (telega--tl-get msg :content :text :text))
						(chat (plist-put (telega--getChat (telega--tl-get msg :chat_id))
										:message_thread_id (plist-get msg :message_thread_id))))
			(when text
				(cond
					((string-match-p (regexp-opt '("Kappa" "Keepo" "Кееро")) text)
						(send-sticker "CAACAgEAAxkDAAEF-ipmVFORmG-MULKGXhv4j0d-unyCKwACEQcAAsTJswOwrIcn0_a7izUE" chat))
					((string-match-p "\\bлул\\b" text)
						(send-sticker "CAACAgIAAxUAAWZQ-0nkrwuYlm-A5x5uWHPXL7F2AAJPGAACIpwgSeBzTLabQpkkNQQ" chat))
					((string-match-p "\\bкек\\b" text)
						(send-sticker "CAACAgIAAxkBAAEF-6dmVbk85usdTNLE6A_Drz18ClwETgACZAIAAm8m4Qzq5B9_hFFkXjUE" chat))
					((string-match-p "\\bмбмб\\b" text)
						(send-sticker "CAACAgIAAxkDAAEF-9RmVb5QNYo8N3RW1za6WGLWNjSlSwACdhoAAnO4KEliRUylvMokHDUE" chat))
					((string-match-p "\\bтру\\b" text)
						(send-sticker "CAACAgQAAxkDAAEF-9dmVb7wcql9CfPRsUSUzcsKAX_-EAACyAQAApv7sgABu26S-uQZztw1BA" chat))
					((string-match-p "\\bфак\\b" text)
						(send-sticker "CAACAgIAAxkBAAEF-9xmVb85nl23wbb3RtyBf8EkqZSKTwACSBgAAguqyEt9mn6NENQmYjUE" chat))
					((string-match-p "\\bхмм\\b" text)
						(send-sticker "CAACAgQAAxkBAAEF--NmVcFHU717OH-jcCKbTzcYGyiDjQACNQEAAqghIQYAAaMWQBNooEw1BA" chat))
					((string-match-p "\\bопа\\b" text)
						(send-sticker "CAACAgQAAxkBAAEF--JmVcC51aBGOdWHWBtnddkk1b8rHwACMwEAAqghIQaDngab6f9thTUE" chat))
					((string-match-p "\\bват\\b" text)
						(send-sticker "CAACAgQAAxkBAAEF-95mVcAXn4DR7h-KSPQMh6C2vHgOmAACMwQAAnhXAQ4N5WrISOEcfDUE" chat))
					((string-match-p "\\b\\(хз\\|хезе\\)\\b" text)
						(send-sticker "CAACAgIAAxkDAAEF-8VmVbySNB8Nv39XxmP82j25aW8DUwAC-QADVp29CpVlbqsqKxs2NQQ" chat))
					))) ))

(defun telega-if-kappa-tester (squash-fun send-msg-fun chat imc &optional reply-to-msg options &rest args)
	(let ((text (telega--tl-get imc :text :text)))
		(if (and text (string-match-p (regexp-opt '("Kappa" "Keepo" "Кееро")) text))
			(apply send-msg-fun chat imc reply-to-msg options args)
			(apply squash-fun send-msg-fun chat imc reply-to-msg options args)
			)))

(defun timestamp-to-date (timestamp)
  "Convert an Emacs Lisp TIMESTAMPT to a date string."
  (format-time-string "%Y-%m-%d %H:%M:%S" (seconds-to-time timestamp)))

(defun telega-status-history-get-today ()
	(-> (telega--time-at00 current-ts)
		telega-status-history--filename
		telega-status-history-file--entries))

(defun telega-find-last-online ()
  "Find the last time the given USER-ID was online in the list of TIMESTAMPS."
	(interactive)
  (let* ((last-online nil)
					(user-id (telega-user-at))
					)
    (dolist (timestamp (telega-status-history-get-today))
      (when (and (equal (cdr timestamp) user-id)
              (equal (car (last timestamp)) :online))
        (setq last-online (car timestamp))))
    (if last-online
      (timestampt-to-date last-online)
      "User was never online")))
