;;; nixos/editors/.doom.d/package_configuration/gptel/gptel_2.el -*- lexical-binding: t; -*-


(after! gptel

  ;; (map! "C-k" #'gptel-menu)
  ;; (map! :n "C-k" #'gptel-menu)
  ;; (map! :i "C-k" #'gptel-menu)
  ;; (setq! gptel-api-key "your key")
(set-popup-rule! "^\\*OpenRouter\\*" :side 'right :size 0.4 :select 1)

;; OpenRouter offers an OpenAI compatible API
(setq gptel-model 'google/gemini-3-flash-preview
	gptel-backend (gptel-make-openai "OpenRouter"               ;Any name you want
									:host "openrouter.ai"
									:endpoint "/api/v1/chat/completions"
									:stream t
									:key (with-temp-buffer (insert-file-contents "/etc/nixos/modules/nixos/editors/.doom.d/package_configuration/gptel/.env") (s-trim (buffer-string) ))
									:models '(google/gemini-3-flash-preview z-ai/glm-4.5-air deepseek/deepseek-v3.2 qwen/qwen3-235b-a22b google/gemini-2.0-flash-001 deepseek/deepseek-chat-v3-0324 qwen/qwen-2.5-coder-32b-instruct meta-llama/llama-3.3-70b-instruct)))

	(setq gptel-directives '((default
														. "You are a large language model living in Emacs and a helpful assistant. Respond concisely.")
													 (programming
														 . "You are a large language model and a programmer. Provide code and only code as output without any additional text, prompt or note or code fences.")
													 (writing
														 . "You are a large language model and a writing assistant. Respond concisely.")
													 (chat
														 . "You are a large language model and a conversation partner. Respond concisely.")))
	)


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
