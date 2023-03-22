;;; editors/.doom.d/package_configuration/chatgpt/chatgpt.el -*- lexical-binding: t; -*-

;; (setq chatgpt-repo-path "~/.doom.d/packages/ChatGPT.el/")
(set-popup-rule! "*ChatGPT*"
	:ignore t)

(defvar chatgpt-query-format-string-map
	'(("doc" . "Please write the documentation for the following function.\n\n%s")
     ("bug" . "There is a bug in the following function, please help me fix it.\n\n%s")
     ("understand" . "What is the following?\n\n%s")
     ("refactor" . "Please refactor the following code.\n\n%s")
     ("improve" . "Please improve the following.\n\n%s")))

(setq gptel-default-mode 'markdown-mode)
(setq gptel--num-messages-to-send nil)

(defun chatgpt--get-query-type ()
  "Helper function to get the type of query."
  (completing-read "Type of Query: " (cons "custom" (mapcar #'car chatgpt-query-format-string-map))))

(defun chatgpt--get-query-prompt (query-type query)
  "Helper function to get the query prompt based on the query type."
  (if (equal query-type "custom")
    (format "%s\n\n%s" (read-from-minibuffer "ChatGPT Custom Prompt: ") query)
    (format (cdr (assoc query-type chatgpt-query-format-string-map)) query)))

(defun chatgpt--send-query-prompt (buf prompt)
  "Helper function to send the query prompt to the given buffer."
  (with-current-buffer buf
    (goto-char (point-max))
    (insert prompt)
    (gptel-send)))

(defun chatgpt-query ()
  "Function to query ChatGPT and send the result to another buffer."
  (interactive)
  (when-let* ((this (buffer-name))
               (query-type (chatgpt--get-query-type))
               (query (buffer-substring (region-beginning) (region-end)))
               (prompt (chatgpt--get-query-prompt query-type query))
               (buf (completing-read
											"Send query in buffer: " (mapcar #'buffer-name (buffer-list))
											(lambda (buf) (and (buffer-local-value 'gptel-mode (get-buffer buf))
                                 (not (equal this buf)))))))
    (chatgpt--send-query-prompt buf prompt)
    (pop-to-buffer buf)))


(setq gptel-prompt-string "-> ")

(map! (:leader "sq" #'chatgpt-query
				"sg" #'gptel)
	(:map gptel-mode-map
		"C-K" #'erase-buffer
		(:n "C-<return>" #'gptel-send)
		(:i "C-<return>" #'gptel-send)))
