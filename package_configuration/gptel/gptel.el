;; TODO test
(after! gptel
	(setq gptel--system-message "
    You are an intelligent programmer named EmacsBot. You are powered by qwen-2.5-coder-32b-instruct.

    You are helping a colleague answer a programming question.

    Please make your response as concise as possible, and avoid being too verbose.

    You will be given a query and various pieces of context which may or may not be helpful in answering the query.

    Your goal is to answer their query in a freeform markdown-formatted response in a faithful manner. You must not lie or make up facts.
")
  (map!
    (:leader
      "a" nil
      (:n "aa" #'gptel-menu)
      (:v "ak" #'gptel--suffix-update-and-ediff)
      (:n "ab" #'gptel-add)))
  (map! "C-k" #'gptel--suffix-inplace)
  (map! :n "C-k" #'gptel--suffix-inplace)
  (map! :i "C-k" #'gptel--suffix-inplace)
  ;; (setq! gptel-api-key "your key")
  )

(set-popup-rule! "^\\*OpenRouter\\*" :side 'right :size 0.4 :select 1)

;; OpenRouter offers an OpenAI compatible API
(setq gptel-model 'qwen/qwen-2.5-coder-32b-instruct
	gptel-backend (gptel-make-openai "OpenRouter"               ;Any name you want
  :host "openrouter.ai"
  :endpoint "/api/v1/chat/completions"
  :stream t
  :key (with-temp-buffer (insert-file-contents "/etc/nixos/modules/nixos/editors/.doom.d/package_configuration/gptel/.env") (s-trim (buffer-string) ))
  :models '(qwen/qwen-2.5-coder-32b-instruct)))

(cl-defun my/clean-up-gptel-refactored-code (beg end)
  "Clean up the code responses for refactored code in the current buffer.

The response is placed between BEG and END.  The current buffer is
guaranteed to be the response buffer."
  (when gptel-mode          ; Don't want this to happen in the dedicated buffer.
    (cl-return-from my/clean-up-gptel-refactored-code))
  (when (and beg end)
    (save-excursion
      (let ((contents
             (replace-regexp-in-string
              "\n*``.*\n*" ""
              (buffer-substring-no-properties beg end))))
        (delete-region beg end)
        (goto-char beg)
        (insert contents))
      ;; Indent the code to match the buffer indentation if it's messed up.
      (indent-region beg end)
      (pulse-momentary-highlight-region beg end))))

(add-hook 'gptel-post-response-functions #'my/clean-up-gptel-refactored-code)

;; write test

;; OPTIONAL configuration
;; (setq gptel-model   'qwen-2.5-coder-32b-instruct
;;       gptel-backend nil)

(defun gptel--update-message ()
  "Set a generic refactor/rewrite message for the buffer."
  (format "You are a %s programmer. Generate only code, no explanation, no code fences. Update the following code part with following instruction: %s"
    (gptel--strip-mode-suffix major-mode) (read-string "Prompt: ")))

(defun gptel--update-message-programmer ()
  (format "You are a %s programmer. Generate only code, no explanation, no code fences. Preserve identation."
    (gptel--strip-mode-suffix major-mode)))

(defun gptel--update-message-end ()
  "Set a generic refactor/rewrite message for the buffer."
  (if (region-active-p) (format "Update the following code part with following instruction: %s\n\n Code: %s" (read-string "Prompt: ")
													(buffer-substring-no-properties
														(region-beginning) (region-end))
													)
		(format "Update the following code part with following instruction: %s\n\nCode Above: %s\nCode Below: %s \n(don't output code above and below)"
			(read-string "Prompt: ")
      (buffer-substring-no-properties (line-beginning-position 0) (line-end-position 0))
      (buffer-substring-no-properties (line-beginning-position 2) (line-end-position 2))
      )))

(after! gptel
	(require 'transient)
	(require 'gptel)
	(require 'ediff)
  (defun gptel--suffix-update-and-ediff (&rest args)
    "Refactoring or rewrite region contents and run Ediff."
    (interactive )
    (letrec ((prompt (buffer-substring-no-properties
											 (region-beginning) (region-end)))
							(gptel--system-message (gptel--update-message))
							(gptel--num-messages-to-send 10)
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

  (transient-define-suffix gptel--suffix-inplace (&rest args)
    "Send ARGS."
    :key "i"
    :description "Inplace"
    (interactive)
    (let* ((stream gptel-stream)
						(in-place t)
						(gptel--system-message (gptel--update-message-programmer))
						(gptel--num-messages-to-send 10)
						(output-to-other-buffer-p nil)
						(backend gptel-backend)
						(model gptel-model)
						(backend-name (gptel-backend-name gptel-backend))
						(buffer nil)
						(position (point))
						(callback)
						(system-extra nil)
						(dry-run nil)
						(prompt (gptel--update-message-end)))
			;; (gptel-context-add)
      (prog1
				(gptel-request prompt
          :buffer (or buffer (current-buffer))
          :position position
          :in-place (and in-place (not output-to-other-buffer-p))
          :stream stream
          :system (or (and gptel--system-message system-extra
                        (concat gptel--system-message "\n\n" system-extra))
                    gptel--system-message)
          :callback callback
          :dry-run dry-run)
				;; (gptel-context-add)
				(gptel--update-status " Waiting..." 'warning)
				(when (and in-place (use-region-p))
					(let ((beg (region-beginning))
								 (end (region-end)))
						(unless output-to-other-buffer-p
							(gptel--attach-response-history (list (buffer-substring-no-properties beg end))))
						(kill-region beg end))))))
  )
