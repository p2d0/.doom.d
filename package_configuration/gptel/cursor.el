;;; nixos/editors/.doom.d/package_configuration/gptel/cursor.el -*- lexical-binding: t; -*-
(require 'gptel)
(require 'gptel-context) ;; Ensure your provided file is loaded

(defun cursor/get-surrounding-code (lines)
  "Get LINES of context around the cursor or selection."
  (save-excursion
    (let* ((use-region (use-region-p))
           (start (if use-region (region-beginning) (point)))
           (end (if use-region (region-end) (point)))
           ;; Determine boundaries for context
           (ctx-start (progn (goto-char start) (forward-line (- lines)) (point)))
           (ctx-end (progn (goto-char end) (forward-line lines) (point))))
      (buffer-substring-no-properties ctx-start ctx-end))))

(defun cursor/generate-prompt (instruction context-string selection-string)
  "Build the final prompt string for the LLM."
  (format 
   "You are an AI programming assistant.
   
=== PROJECT CONTEXT (Files explicitly added) ===
%s

=== ACTIVE FILE CONTEXT (Surrounding code) ===
File: %s (Language: %s)
```
%s
```

=== INSTRUCTION ===
User Request: %s
%s

=== TASK ===
1. If code was selected, output the REPLACEMENT code.
2. If no code was selected, output the NEW code to insert.
3. OUTPUT ONLY CODE. No markdown backticks (```), no explanations."
   (if (string-empty-p context-string) "(No global context)" context-string)
   (file-name-nondirectory (or (buffer-file-name) "buffer"))
   major-mode
   (cursor/get-surrounding-code 60) ;; Grabs +/- 60 lines around point
   instruction
   (if (not (string-empty-p selection-string)) 
       (format "Target Code to Change:\n```\n%s\n```" selection-string)
     "Target: Insert code at the current cursor position.")))

(defun cursor-ctrl-k ()
  "Stream changes to the buffer using gptel, inserting text as it arrives."
  (interactive)
  (let* ((use-region (use-region-p))
         (beg (if use-region (region-beginning) (point)))
         (end (if use-region (region-end) (point)))
         (selection (if use-region (buffer-substring-no-properties beg end) ""))
         (instruction (read-string (if use-region "Refactor: " "Generate: ")))
         
         ;; Capture the buffer and position so insertion happens in the right place
         ;; even if you switch windows while waiting.
         (proc-buffer (current-buffer))
         (start-marker (make-marker))
         
         ;; 1. GATHER LOCAL CONTEXT (Surrounding lines)
         (local-context 
          (save-excursion
            (let ((c-beg (progn (goto-char beg) (forward-line -20) (point)))
                  (c-end (progn (goto-char end) (forward-line 20) (point))))
              (buffer-substring-no-properties c-beg c-end))))

         ;; 2. GATHER PROJECT CONTEXT
         (project-context-raw 
          (when (boundp 'gptel-context)
            (gptel-context--string (gptel-context--collect))))
         (project-context (or project-context-raw ""))

         ;; 3. SYSTEM PROMPT
         (system-prompt 
          (format "You are an expert coder using Emacs.
Current File: %s
Language: %s

RULES:
1. Output ONLY the code. No markdown backticks (```).
2. No explanations.
3. If editing, output the replaced code only."
                  (file-name-nondirectory (or (buffer-file-name) "scratch"))
                  major-mode))
         
         ;; 4. FINAL PROMPT
         (final-prompt 
          (format "
=== PROJECT CONTEXT ===
%s

=== LOCAL CONTEXT ===
%s

=== INSTRUCTION ===
%s
%s
" 
           project-context
           local-context
           (if use-region (format "Replace the code below:\n%s\nWith code that does:" selection) 
             "At the cursor position, generate code that does:")
           instruction)))

    ;; Set marker to where we want the code to appear
    (set-marker start-marker beg)

    ;; Delete selection if replacing
    (if use-region (delete-region beg end))

    ;; Send Request
    (gptel-request
     final-prompt
     :system system-prompt
     :stream t
     :callback (lambda (response info)
                 (when (and response (stringp response))
                   (with-current-buffer proc-buffer
                     (save-excursion
                       (goto-char start-marker)
                       (insert response)
                       ;; Advance marker so next chunk appends correctly
                       (set-marker start-marker (point)))))))
    
    (message "Cursor: Thinking...")))

;; Bind it
;; (global-set-key (kbd "C-c k") 'cursor-ctrl-k)

;; Bind it
;; (global-set-key (kbd "C-c k") 'cursor-ctrl-k)

;; Bind to C-c k (Ctrl+k is usually kill-line, so C-c k is safer)
;; (global-set-key (kbd "C-c k") 'cursor-ctrl-k)

(map! "C-k" #'cursor-ctrl-k)
(map! :n "C-k" #'cursor-ctrl-k)
(map! :i "C-k" #'cursor-ctrl-k)
