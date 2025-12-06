;;; nixos/editors/.doom.d/package_configuration/gptel/gptel_2.el -*- lexical-binding: t; -*-


(after! gptel

  (map! "C-k" #'gptel-menu)
  (map! :n "C-k" #'gptel-menu)
  (map! :i "C-k" #'gptel-menu)
  ;; (setq! gptel-api-key "your key")
(set-popup-rule! "^\\*OpenRouter\\*" :side 'right :size 0.4 :select 1)

;; OpenRouter offers an OpenAI compatible API
(setq gptel-model 'deepseek/deepseek-v3.2
	gptel-backend (gptel-make-openai "OpenRouter"               ;Any name you want
									:host "openrouter.ai"
									:endpoint "/api/v1/chat/completions"
									:stream t
									:key (with-temp-buffer (insert-file-contents "/etc/nixos/modules/nixos/editors/.doom.d/package_configuration/gptel/.env") (s-trim (buffer-string) ))
									:models '(deepseek/deepseek-v3.2 qwen/qwen3-235b-a22b google/gemini-2.0-flash-001 deepseek/deepseek-chat-v3-0324 qwen/qwen-2.5-coder-32b-instruct meta-llama/llama-3.3-70b-instruct)))

	(setq gptel-directives '((default
														. "You are a large language model living in Emacs and a helpful assistant. Respond concisely.")
													 (programming
														 . "You are a large language model and a programmer. Respond without thinking. Provide code and only code as output without any additional text, prompt or note or code fences.")
													 (writing
														 . "You are a large language model and a writing assistant. Respond concisely.")
													 (chat
														 . "You are a large language model and a conversation partner. Respond concisely.")))
	)
