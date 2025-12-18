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
  "Stream code generation. 
If selection: Rewrite/Replace it.
If no selection: AUTOCOMPLETE from the exact cursor position."
  (interactive)
  (let* ((use-region (use-region-p))
         (beg (if use-region (region-beginning) (point)))
         (end (if use-region (region-end) (point)))
         (selection (if use-region (buffer-substring-no-properties beg end) ""))
         (instruction (read-string (if use-region "Edit selection: " "Generate/Complete: ")))
         
         ;; Setup Marker for insertion
         (proc-buffer (current-buffer))
         (start-marker (make-marker))
         
         ;; 1. GET PROJECT CONTEXT (from gptel-add-file)
         (project-context 
          (if (boundp 'gptel-context)
              (or (gptel-context--string (gptel-context--collect)) "")
            ""))

         ;; 2. GET LOCAL CONTEXT (Split into Before and After cursor)
         ;; We grab 30 lines before and 30 lines after to give the LLM the picture.
         (context-before
          (save-excursion
            (let ((limit (progn (goto-char beg) (forward-line -30) (point))))
              (buffer-substring-no-properties limit beg))))
         
         (context-after
          (save-excursion
            (let ((limit (progn (goto-char end) (forward-line 30) (point))))
              (buffer-substring-no-properties end limit))))

         ;; 3. CONSTRUCT SYSTEM PROMPT
         (system-prompt 
          (format "You are an expert coder acting as an intelligent autocomplete engine.
Current File: %s
Language: %s

CRITICAL RULES:
1. Output ONLY the code to be inserted.
2. Do NOT output markdown backticks (```).
3. Do NOT repeat code that is already in the 'Code Before Cursor' block.
4. Just write the code that comes next."
                  (file-name-nondirectory (or (buffer-file-name) "scratch"))
                  major-mode))
         
         ;; 4. CONSTRUCT USER PROMPT
         (final-prompt 
          (if use-region
              ;; --- REWRITE MODE (Selection Active) ---
              (format "
=== PROJECT CONTEXT ===
%s

=== CODE CONTEXT ===
%s<SELECTION>%s</SELECTION>%s

=== INSTRUCTION ===
Refactor the code marked in <SELECTION> based on this instruction: %s
Output only the new code to replace the selection.
" 
               project-context context-before selection context-after instruction)

            ;; --- AUTOCOMPLETE MODE (No Selection) ---
            (format "
=== PROJECT CONTEXT ===
%s

=== CODE BEFORE CURSOR ===
%s

=== CODE AFTER CURSOR ===
%s

=== INSTRUCTION ===
The cursor is exactly at the end of 'CODE BEFORE CURSOR'.
Complete the code or generate new code based on this instruction: %s
DO NOT REPEAT the last line of 'CODE BEFORE CURSOR'. Start exactly where it ends.
" 
             project-context context-before context-after instruction))))

    ;; Set marker to insertion point
    (set-marker start-marker beg)

    ;; If region active, delete it so we can stream the replacement
    (if use-region (delete-region beg end))

    (message "Cursor: generating...")
    
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
                       ;; Move marker forward so next chunk appends
                       (set-marker start-marker (point)))))))))

;; (global-set-key (kbd "C-c k") 'cursor-ctrl-k)

;; Bind it
;; (global-set-key (kbd "C-c k") 'cursor-ctrl-k)

;; Bind it
;; (global-set-key (kbd "C-c k") 'cursor-ctrl-k)

;; Bind to C-c k (Ctrl+k is usually kill-line, so C-c k is safer)
;; (global-set-key (kbd "C-c k") 'cursor-ctrl-k)

(map! "C-k" #'cursor-ctrl-k)
(map! :n "C-k" #'cursor-ctrl-k)
(map! :i "C-k" #'cursor-ctrl-k)

(defun gptel-context-export-and-copy ()
  "Export the current gptel context to /tmp/context.txt and copy its URI.
This copies the file URI (file:///tmp/context.txt) to the clipboard with
MIME type 'text/uri-list', making it pasteable into file managers or
chat apps that support file attachments."
  (interactive)
  (require 'gptel-context)
  (let ((output-file "/tmp/context.txt")
        (context-string (gptel-context--string gptel-context)))
    
    ;; 1. Write context to /tmp/context.txt
    (if (or (null context-string) (string-empty-p context-string))
        (user-error "No active gptel context to export")
      (with-temp-file output-file
        (insert (s-concat context-string 
"Output in Aider/Unified diff:
```diff
--- mathweb/flask/app.py
+++ mathweb/flask/app.py
@@ ... @@
-class MathWeb:
+import sympy
+
+class MathWeb:
```
"
									)))

      (message "Context written to %s" output-file))

    ;; 2. Copy URI to clipboard (Wayland/X11 detection)
    (let* ((uri (format "file://%s\n" output-file))
           (wayland-p (string-equal (getenv "XDG_SESSION_TYPE") "wayland"))
           (process-connection-type nil)) ; Use pipe for process
      
      (if wayland-p
          ;; Wayland: wl-copy
          (let ((proc (start-process "gptel-copy-uri" nil "wl-copy" "-t" "text/uri-list")))
            (process-send-string proc uri)
            (process-send-eof proc))
        
        ;; X11: xclip
        (let ((proc (start-process "gptel-copy-uri" nil "xclip" "-sel" "clip" "-t" "text/uri-list" "-i")))
          (process-send-string proc uri)
          (process-send-eof proc)))
      
      (message "Copied %s to clipboard (text/uri-list)" output-file))))

(map! (:leader
				"a" nil
				(:n "ab" #'gptel-add)
				(:n "ae" #'gptel-context-export-and-copy)
				(:n "ai" #'gptel--suffix-context-buffer)
				))

(defun gptel-context-inspect ()
	(interactive)
	(gptel-context--buffer-setup))


;; (define-key gptel-context-buffer-mode-map (kbd "q") #'quit-window)
(map! :map gptel-context-buffer-mode-map
	:n "q" #'quit-window
	)

(with-eval-after-load 'transient
  (define-key transient-map "q" 'transient-quit-one))

;; (map! (:leader "aa" #'my-ediff-multifile-sequential))

;; (map! (:leader "aa" #'my-ediff-multifile-sequential))
