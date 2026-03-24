;;; nixos/editors/.doom.d/package_configuration/gptel/zai_edit.el -*- lexical-binding: t; -*-

;;; z.ai Buffer Edit — sends current buffer to glm-4.7, gets Aider S/R blocks, applies via ediff

(require 'gptel)
(require 'gptel-context)

;; ---------------------------------------------------------------------------
;; Backend

(defvar my-zai-backend
  (gptel-make-openai "z.ai"
    :host "api.z.ai"
    :endpoint "/api/coding/paas/v4/chat/completions"
    :stream nil
    :key (lambda ()
           (with-temp-buffer
             (insert-file-contents (expand-file-name "~/Dropbox/zai.txt"))
             (string-trim (buffer-string))))
    :models '(glm-4.7)
    :request-params '(:enable_thinking :json-false))
  "gptel backend for z.ai (glm-4.7).")

(defvar my-zai-model 'glm-4.7)

;; ---------------------------------------------------------------------------
;; System prompt

(defconst my-zai-system-prompt
  "You are an automated code-patching tool. Apply the requested changes using Aider Search/Replace blocks.

OUTPUT FORMAT — one block per changed region:
filename.ext
<<<<<<< SEARCH
[exact existing code, or use ... to skip unchanged lines]
=======
[new code]
>>>>>>> REPLACE

RULES:
1. The filename must appear on the line immediately above <<<<<<< SEARCH.
2. Use '...' inside SEARCH blocks to skip unchanged code between changed lines.
3. Output ONLY the Search/Replace blocks. No markdown fences, no explanations, no other text."
  "System prompt directing z.ai to output Aider Search/Replace blocks.")

;; ---------------------------------------------------------------------------
;; Pure helpers (unit-testable)

(defun my-zai--build-edit-prompt (buffer-content filename instruction)
  "Build the user prompt sent to z.ai.
BUFFER-CONTENT is the full file text, FILENAME is used as context label,
INSTRUCTION is the user's edit request."
  (format "=== FILE: %s ===\n```\n%s\n```\n\n=== INSTRUCTION ===\n%s"
          filename buffer-content instruction))

(defun my-zai--strip-outer-fence (text)
  "Strip a single surrounding triple-backtick fence from TEXT if present.
Handles optional language tag on the opening fence (e.g. ```elisp).
Returns TEXT unchanged when no fence is detected."
  (if (string-match "\\`[ \t\n]*```[^\n]*\n\\([\0-\377[:nonascii:]]*?\\)\n```[ \t\n]*\\'" text)
      (match-string 1 text)
    text))

;; ---------------------------------------------------------------------------
;; In-flight request state (for abort)

(defvar my-zai--active-buffer nil "Source buffer of the in-flight z.ai request.")
(defvar my-zai--spinner-timer nil "Timer animating the minibuffer spinner.")

(defun my-zai-abort ()
  "Cancel the in-flight z.ai request and stop the spinner."
  (interactive)
  (when (timerp my-zai--spinner-timer)
    (cancel-timer my-zai--spinner-timer)
    (setq my-zai--spinner-timer nil))
  (if (buffer-live-p my-zai--active-buffer)
      (progn
        (gptel-abort my-zai--active-buffer)
        (setq my-zai--active-buffer nil))
    (message "No active z.ai request.")))

;; ---------------------------------------------------------------------------
;; Interactive command

(defun my-zai-edit-buffer ()
  "Send the current buffer to z.ai (glm-4.7) and apply the response as Aider S/R blocks.

Prompts for an instruction, sends the full buffer content plus the instruction
to z.ai, then feeds the response into the aider_search.el ediff pipeline
\(`my-aider--parse-sr-blocks' → `my-aider-sr-queue' → `my-aider-sr-process-next')."
  (interactive)
  (unless (fboundp 'my-aider--parse-sr-blocks)
    (user-error "aider_search.el must be loaded first (my-aider--parse-sr-blocks not found)"))
  (let* ((source-buf (current-buffer))
         (filename (or (and (buffer-file-name)
                            (let ((root (or (and (fboundp 'doom-project-root) (doom-project-root))
                                           default-directory)))
                              (file-relative-name (buffer-file-name) root)))
                       (buffer-name)))
         (buffer-content (with-current-buffer source-buf
                           (buffer-substring-no-properties (point-min) (point-max))))
         (instruction (read-string "z.ai instruction: "))
         (project-root (or (and (fboundp 'doom-project-root) (doom-project-root)) default-directory))
         (prompt (my-zai--build-edit-prompt buffer-content filename instruction))
         (gptel-backend my-zai-backend)
         (gptel-model my-zai-model))
    (setq my-zai--active-buffer source-buf)
    (let* ((spinner-frames ["⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"])
           (spinner-idx 0))
      (setq my-zai--spinner-timer
            (run-at-time
             0 0.1
             (lambda ()
               (message "z.ai: thinking %s"
                        (aref spinner-frames
                              (% spinner-idx (length spinner-frames))))
               (cl-incf spinner-idx))))
      (gptel-request
       prompt
       :system my-zai-system-prompt
       :stream nil
       :callback (lambda (response info)
                   (when (timerp my-zai--spinner-timer)
                     (cancel-timer my-zai--spinner-timer)
                     (setq my-zai--spinner-timer nil))
                   (setq my-zai--active-buffer nil)
                   (if (not (and response (stringp response)))
                       (message "z.ai: no response (status: %s)" (plist-get info :status))
                     (let* ((cleaned (my-zai--strip-outer-fence response))
                            (blocks  (my-aider--parse-sr-blocks cleaned)))
                       (if (null blocks)
                           (message "z.ai: no Search/Replace blocks found in response")
                         (message "z.ai: applying %d block(s)..." (length blocks))
                         (setq my-aider-sr-project-root project-root)
                         (setq my-aider-sr-queue blocks)
                         (my-aider-sr-process-next)))))))))

;; ---------------------------------------------------------------------------
;; Keybinding

(map! (:leader (:n "az" #'my-zai-edit-buffer)
               (:n "aZ" #'my-zai-abort)))
