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
						) nil (list :@type "messageSendOptions" :disable_notification t)))

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

(defun send-sticker (sticker-id &optional msg)
  (let* ((chat
	   (if msg (plist-put (telega--getChat (telega--tl-get msg :chat_id))
		     :message_thread_id (plist-get msg :message_thread_id))
	     telega-chatbuf--chat
	     )))
    (telega--sendMessage
      chat
      (list :@type "inputMessageSticker"
	:sticker (list :@type "inputFileRemote" :id sticker-id))
      (list :@type "inputMessageReplyToMessage"
	:message_id (telega--tl-get msg :id))
      (list :@type "messageSendOptions" :disable_notification t))))

(defun telega-if-kappa-send-sticker (msg)
  "Send a sticker if the message contains 'Kappa', 'Keepo', 'Кееро', or 'лул'."
  ;; (prin1 msg)
  (if-let* ((sticker-id (telega--tl-get msg :content :sticker :sticker :remote :id)))
    (write-region (concat sticker-id "\n")
      nil (expand-file-name "sticker.txt" telega-directory) 'append 'quiet))
  (when (and ;; (plist-get msg :is_outgoing)
	  (not (plist-get msg :is_from_offline)) (not (= (telega--tl-get msg :sender_id :user_id) 216082031)))
    (let* ((text (telega--tl-get msg :content :text :text))
	    )
      (when text
	(cond
	  ((string-match-p (regexp-opt '("Kappa" "Keepo" "Кееро")) text)
	    (send-sticker "CAACAgEAAxkDAAEF-ipmVFORmG-MULKGXhv4j0d-unyCKwACEQcAAsTJswOwrIcn0_a7izUE" msg))
	  ((string-match-p "\\bлул\\b" text)
	    (send-sticker "CAACAgIAAxUAAWZQ-0nkrwuYlm-A5x5uWHPXL7F2AAJPGAACIpwgSeBzTLabQpkkNQQ" msg))
	  ((string-match-p "\\bкек\\b" text)
	    (send-sticker "CAACAgIAAxkBAAEF_Q5mVvhPf1JdemnANBJEULO_oZdrvAACnRgAAkMPIEqcZBUy2ZTufzUE" msg))
	  ((string-match-p "\\bмбмб\\b" text)
	    (send-sticker "CAACAgIAAxkDAAEF-9RmVb5QNYo8N3RW1za6WGLWNjSlSwACdhoAAnO4KEliRUylvMokHDUE" msg))
	  ((string-match-p "\\bтру\\b" text)
	    (send-sticker "CAACAgQAAxkDAAEF-9dmVb7wcql9CfPRsUSUzcsKAX_-EAACyAQAApv7sgABu26S-uQZztw1BA" msg))
	  ((string-match-p "\\bфак\\b" text)
	    (send-sticker "CAACAgIAAxkBAAEF-9xmVb85nl23wbb3RtyBf8EkqZSKTwACSBgAAguqyEt9mn6NENQmYjUE" msg))
	  ((string-match-p "\\bхмм\\b" text)
	    (send-sticker "CAACAgQAAxkBAAEF--NmVcFHU717OH-jcCKbTzcYGyiDjQACNQEAAqghIQYAAaMWQBNooEw1BA" msg))
	  ((string-match-p "\\bопа\\b" text)
	    (send-sticker "CAACAgQAAxkBAAEGBr9mXgXkzz1AlmdM_XmEaLd4B6EEZQACrBEAAtXtyVHrPfScnFD59jUE" msg))
	  ((string-match-p "\\bват\\b" text)
	    (send-sticker "CAACAgQAAxkBAAEF-95mVcAXn4DR7h-KSPQMh6C2vHgOmAACMwQAAnhXAQ4N5WrISOEcfDUE" msg))
	  ((string-match-p "\\bимба\\b" text)
	    (send-sticker "CAACAgIAAx0EX863OQACqwVmVuqrodaOR8vF174RgPQFpNWmQgACIwADXQWCFiBh-3UK1EC0NQQ" msg))
	  ((string-match-p "\\b\\(хз\\|хезе\\)\\b" text)
	    (send-sticker "CAACAgIAAxkDAAEF-8VmVbySNB8Nv39XxmP82j25aW8DUwAC-QADVp29CpVlbqsqKxs2NQQ" msg))
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
  (-> (telega--time-at00 (time-convert nil 'integer))
    telega-status-history--filename
    telega-status-history-file--entries))

(defun telega-status-history-get ()
  (-> (read-file-name "History file: " "~/.telega/online-history/")
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

;; (defun calculate-time-spent-online (user-id)
;;   "Calculate the total time spent online (in minutes) by USER-ID given a LOG of timestamped statuses."
;;   (let ((total-time 0)
;;          (last-online-time nil))
;;     (dolist (entry (telega-status-history-get-today))
;;       (let ((timestamp (nth 0 entry))
;;              (status (nth 1 entry))
;;              (id (nth 2 entry)))
;;         (when (equal id user-id)
;;           (cond
;; 						((equal status :online)
;; 							(setq last-online-time timestamp))
;; 						((equal status :offline)
;; 							(when last-online-time
;; 								(setq total-time (+ total-time (/ (- timestamp last-online-time) 60)))
;; 								(setq last-online-time nil)))))))
;;     total-time))

;; (defun calculate-time-spent-online ()
;;   "Calculate the total time spent online (in minutes) for each user in the LOG and return formatted results."
;;   (let ((user-times (make-hash-table :test 'equal)))
;;     ;; Calculate total online time for each user
;;     (dolist (entry (telega-status-history-get-today))
;;       (let ((timestamp (nth 0 entry))
;;             (status (nth 1 entry))
;;             (id (nth 2 entry)))
;;         (unless (gethash id user-times)
;;           (puthash id (list 0 nil) user-times))  ;; Initialize if not present
;;         (let ((user-data (gethash id user-times)))
;;           (cond
;;            ((equal status :online)
;;             (setf (nth 1 user-data) timestamp))  ;; Store the online timestamp
;;            ((equal status :offline)
;;             (let ((last-online-time (nth 1 user-data)))
;;               (when last-online-time
;;                 (setf (nth 0 user-data)
;;                       (+ (nth 0 user-data)
;;                          (/ (- timestamp last-online-time) 60)))  ;; Update total time
;;                 (setf (nth 1 user-data) nil))))))))  ;; Reset online timestamp

;;     ;; Format the output
;;     (maphash
;;      (lambda (id user-data)
;;        (let ((title (plist-get (telega-chat-get id) :title))
;;              (time (nth 0 user-data)))
;;          (message "%s: %d минут." title time)))
;;      user-times)))

(defun calculate-time-spent-online ()
  "Calculate the total time spent online (in minutes) for each user in the LOG and return formatted results."
  (interactive)
  (let ((user-times (make-hash-table :test 'equal)))
    ;; Calculate total online time for each user
    (dolist (entry (telega-status-history-get-today))
      (let ((timestamp (nth 0 entry))
             (status (nth 1 entry))
             (id (nth 2 entry)))
        (unless (gethash id user-times)
          (puthash id (list 0 nil) user-times))  ;; Initialize if not present
        (let ((user-data (gethash id user-times)))
          (cond
            ((equal status :online)
              (unless (nth 1 user-data)  ;; Only set if not already online
		(setf (nth 1 user-data) timestamp)))
            ((equal status :offline)
              (let ((last-online-time (nth 1 user-data)))
		(when last-online-time
                  (setf (nth 0 user-data)
                    (+ (nth 0 user-data)
                      (- timestamp last-online-time) ))  ;; Update total time
                  (setf (nth 1 user-data) nil))))))))  ;; Reset online timestamp

    ;; Format the output
    (maphash
      (lambda (id user-data)
	(let ((title (plist-get (telega-chat-get id) :title))
               (time (/ (nth 0 user-data) 60)))
          (message "%s: %d минут." title time)))
      user-times)))

(defun calculate-time-spent-online-for-file ()
  "Calculate the total time spent online (in minutes) for each user in the LOG and return formatted results."
  (interactive)
  (let ((user-times (make-hash-table :test 'equal)))
    ;; Calculate total online time for each user
    (dolist (entry (telega-status-history-get))
      (let ((timestamp (nth 0 entry))
             (status (nth 1 entry))
             (id (nth 2 entry)))
        (unless (gethash id user-times)
          (puthash id (list 0 nil) user-times))  ;; Initialize if not present
        (let ((user-data (gethash id user-times)))
          (cond
            ((equal status :online)
              (unless (nth 1 user-data)  ;; Only set if not already online
		(setf (nth 1 user-data) timestamp)))
            ((equal status :offline)
              (let ((last-online-time (nth 1 user-data)))
		(when last-online-time
                  (setf (nth 0 user-data)
                    (+ (nth 0 user-data)
                      (- timestamp last-online-time) ))  ;; Update total time
                  (setf (nth 1 user-data) nil))))))))  ;; Reset online timestamp

    ;; Format the output
    (maphash
      (lambda (id user-data)
	(let ((title (plist-get (telega-chat-get id) :title))
               (time (/ (nth 0 user-data) 60)))
          (message "%s: %d минут." title time)))
      user-times)))
