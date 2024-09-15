;;; nixos/editors/.doom.d/package_configuration/gptel/gptel.el -*- lexical-binding: t; -*-

(use-package! gptel
	:config
	(map!
		:leader "a" nil
		:leader :n "aa" #'gptel-menu
		:leader :v "ak" #'gptel--suffix-update-and-ediff
		:leader :n "ab" #'gptel-add)
	;; (setq! gptel-api-key "your key")
	)

(defun gptel--update-message ()
	"Set a generic refactor/rewrite message for the buffer."
  (format "You are a %s programmer. Generate only code, no explanation, no code fences. Update the following code part with following instruction: %s"
    (gptel--strip-mode-suffix major-mode) (read-string "Prompt: ")))

(after! gptel
	(transient-define-prefix gptel-menu ()
		"Change parameters of prompt to send to the LLM."
		;; :incompatible '(("-m" "-n" "-k" "-e"))
		[:description
			(lambda ()
				(string-replace
					"\n" "⮐ "
					(truncate-string-to-width
						gptel--system-message (max (- (window-width) 12) 14) nil nil t)))
			[""
				"Instructions"
				("s" "Set system message" gptel-system-prompt :transient t)
				(gptel--infix-add-directive)]
			[:pad-keys t
				""
				"Context"
				(gptel--infix-context-add-region)
				(gptel--infix-context-add-buffer)
				(gptel--infix-context-add-file)
				(gptel--suffix-context-buffer)]]
		[["Request Parameters"
			 :pad-keys t
			 (gptel--infix-variable-scope)
			 (gptel--infix-provider)
			 (gptel--infix-max-tokens)
			 (gptel--infix-num-messages-to-send
				 :if (lambda () (or gptel-mode gptel-track-response)))
			 (gptel--infix-temperature :if (lambda () gptel-expert-commands))
			 (gptel--infix-use-context)
			 (gptel--infix-track-response
				 :if (lambda () (and gptel-expert-commands (not gptel-mode))))]
			["Prompt from"
				("m" "Minibuffer instead" "m")
				("y" "Kill-ring instead" "y")
				""
				("i" "Respond in place" "i")]
			["Response to"
				("e" "Echo area instead" "e")
				("g" "gptel session" "g"
					:class transient-option
					:prompt "Existing or new gptel session: "
					:reader
					(lambda (prompt _ _history)
						(read-buffer
							prompt (generate-new-buffer-name
											 (concat "*" (gptel-backend-name gptel-backend) "*"))
							nil (lambda (buf-name)
										(if (consp buf-name) (setq buf-name (car buf-name)))
										(let ((buf (get-buffer buf-name)))
											(and (buffer-local-value 'gptel-mode buf)
												(not (eq (current-buffer) buf))))))))
				("b" "Any buffer" "b"
					:class transient-option
					:prompt "Output to buffer: "
					:reader
					(lambda (prompt _ _history)
						(read-buffer prompt (buffer-name (other-buffer)) nil)))
				("k" "Kill-ring" "k")]]
		[["Send"
			 (gptel--suffix-send)
			 ("M-RET" "Regenerate" gptel--regenerate :if gptel--in-response-p)]
			[:description gptel--refactor-or-rewrite
				:if use-region-p
				("r"
					;;FIXME: Transient complains if I use `gptel--refactor-or-rewrite' here. It
					;;reads this function as a suffix instead of a function that returns the
					;;description.
					(lambda () (if (derived-mode-p 'prog-mode)
									"Refactor" "Rewrite"))
					gptel-rewrite-menu)]
			[:description "Update"
				:if use-region-p
				("k" "Update" gptel--suffix-update-and-ediff)
				]
			["Tweak Response" :if gptel--in-response-p :pad-keys t
				("SPC" "Mark" gptel--mark-response)
				("P" "Previous variant" gptel--previous-variant
					:if gptel--at-response-history-p
					:transient t)
				("N" "Next variant" gptel--previous-variant
					:if gptel--at-response-history-p
					:transient t)
				("E" "Ediff previous" gptel--ediff
					:if gptel--at-response-history-p)]
			["Dry Run" :if (lambda () (or gptel-log-level gptel-expert-commands))
				("I" "Inspect query (Lisp)"
					(lambda ()
						"Inspect the query that will be sent as a lisp object."
						(interactive)
						(gptel--sanitize-model)
						(gptel--inspect-query
							(gptel--suffix-send
								(cons "I" (transient-args transient-current-command))))))
				("J" "Inspect query (JSON)"
					(lambda ()
						"Inspect the query that will be sent as a JSON object."
						(interactive)
						(gptel--sanitize-model)
						(gptel--inspect-query
							(gptel--suffix-send
								(cons "I" (transient-args transient-current-command)))
							'json)))]]
		(interactive)
		(gptel--sanitize-model)
		(transient-setup 'gptel-menu))

	;; (transient-define-prefix gptel-update-menu ()
	;; 	"Rewrite or refactor text region using an LLM."
	;; 	[[:description "Diff Options"
	;; 		 ("-w" "Wordwise diff" "-w")]
	;; 		[:description "Update"
	;; 			(gptel--suffix-update-and-ediff)]]
	;; 	(interactive)
	;; 	(unless gptel--rewrite-message
	;; 		(setq gptel--rewrite-message (gptel--rewrite-message)))
	;; 	(transient-setup 'gptel-update-menu))


	(transient-define-suffix gptel--suffix-update-and-ediff (args)
		"Refactoring or rewrite region contents and run Ediff."
		:key "e"
		:description "Update and Ediff"
		(interactive (list (transient-args transient-current-command)))
		(letrec ((prompt (buffer-substring-no-properties
											 (region-beginning) (region-end)))
							(gptel--system-message (gptel--update-message))
							;; TODO: Technically we should save the window config at the time
							;; `ediff-setup-hook' runs, but this will do for now.
							(cwc (current-window-configuration))
							(gptel--ediff-restore
								(lambda ()
									(when (window-configuration-p cwc)
										(set-window-configuration cwc))
									(remove-hook 'ediff-quit-hook gptel--ediff-restore))))
			(message "Waiting for response... ")
			(gptel-request
				prompt
				:context (cons (region-beginning) (region-end))
				:callback
				(lambda (response info)
					(if (not response)
						(message "ChatGPT response error: %s" (plist-get info :status))
						(let* ((gptel-buffer (plist-get info :buffer))
										(gptel-bounds (plist-get info :context))
										(buffer-mode
											(buffer-local-value 'major-mode gptel-buffer)))
							(pcase-let ((`(,new-buf ,new-beg ,new-end)
														(with-current-buffer (get-buffer-create "*gptel-rewrite-Region.B-*")
															(let ((inhibit-read-only t))
																(erase-buffer)
																(funcall buffer-mode)
																(insert response)
																(goto-char (point-min))
																(list (current-buffer) (point-min) (point-max))))))
								(require 'ediff)
								(add-hook 'ediff-quit-hook gptel--ediff-restore)
								(apply
									#'ediff-regions-internal
									(get-buffer (ediff-make-cloned-buffer gptel-buffer "-Region.A-"))
									(car gptel-bounds) (cdr gptel-bounds)
									new-buf new-beg new-end
									nil
									(if (transient-arg-value "-w" args)
										(list 'ediff-regions-wordwise 'word-wise nil)
										(list 'ediff-regions-linewise nil nil))))))))))
	)
