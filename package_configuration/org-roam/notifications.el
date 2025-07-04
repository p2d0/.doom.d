;;; nixos/editors/.doom.d/package_configuration/org-roam/notifications.el -*- lexical-binding: t; -*-

;; Add these requires at the top of your file if they aren't there already
(require 's)
(require 'notifications)
(require 'org-element)

;; --- 1. Helper Function to Get Today's Daily Note Path ---
;; We need a function to get today's file, not yesterday's.
(defun my-get-todays-daily-path ()
  "Return the full path to today's org-roam daily note.
Returns nil if 'org-roam-dailies-directory' or 'org-roam-directory' is not set."
  (when (and (boundp 'org-roam-dailies-directory) (boundp 'org-roam-directory))
    (let* ((date (format-time-string "%Y-%m-%d" (current-time)))
           (file (concat date ".org")))
      (expand-file-name file (expand-file-name org-roam-dailies-directory org-roam-directory)))))

;; --- 2. Core Logic to Find Unfinished Tasks ---
;; --- The New, Pure Parsing Function (EASY TO TEST) ---
;; We need the org export library for this solution.
(require 'ox)

(defun my-parse-unfinished-tasks-from-string (org-content heading limit)
  "Parse ORG-CONTENT string and find the first LIMIT unfinished tasks under HEADING.
This is a pure function, ideal for testing."
  (let ((tasks '()))
    (with-temp-buffer
      (insert org-content)
      (org-mode)
      (let* ((data (org-element-parse-buffer))
             (target-headline
              (org-element-map data 'headline
                (lambda (h)
                  (when (string-equal heading (org-element-property :raw-value h)) h))
                nil 'first-match)))

        (when target-headline
          ;; Find the top-level plain-list in the headline
          (let ((top-level-list
                 (car (org-element-map (org-element-contents target-headline) 'plain-list
                        #'identity nil t))))  ; t = no-recursion (only direct children)

            (when top-level-list
              ;; Process only direct children of the top-level list
              (dolist (item (org-element-contents top-level-list))
                (when (and (< (length tasks) limit)
                           (member (org-element-property :checkbox item) '(off trans)))
                  (let* ((contents (org-element-contents item))
                         (paragraph (org-element-map contents 'paragraph #'identity nil 'first-match))
                         (item-text (if paragraph
                                        (s-trim (org-element-interpret-data paragraph))
                                      "")))
                    (push item-text tasks))))))))
    (nreverse tasks))))

;; --- The Updated Wrapper Function (interacts with filesystem) ---
;; (defun my-get-unfinished-tasks-under-heading (heading limit)
;;   "Find the first LIMIT unfinished tasks under a specific HEADING in today's daily file.
;; This is a wrapper around the pure parsing function."
;;   (let ((daily-file (my-get-todays-daily-path)))
;;     (when (and daily-file (file-exists-p daily-file))
;;       (let ((org-content (with-temp-buffer
;;                            (insert-file-contents daily-file)
;;                            (buffer-string))))
;;         (my-parse-unfinished-tasks-from-string org-content heading limit)))))

(defun org-find-headlines-under-noparse (heading predicate)
  "Find the headlines under a given heading that satisfy a predicate."
  (let* ((data (org-element-parse-buffer)) ; parse the buffer
          (first-heading (org-element-map data 'headline ; find the first headline
                           (lambda (head) (if (s-contains? heading (org-element-property :raw-value head))
																						(org-element-extract head)
																						))
                           nil t)) ; return the first match
          (reset-check  (org-element-map first-heading 'item
											  	 (lambda (head)
											  		 (when (funcall predicate head)
															 (if (org-element-type-p (org-element-parent (org-element-parent head)) 'section)
																 (org-element-put-property head :checkbox 'off)
																 (progn
																	 (org-element-put-property head :checkbox 'off)
																	 nil)))))))
    reset-check))

(defun get-line-at-pos (pos)
  "Return the line at the given buffer position POS as a string."
  (save-excursion
    (goto-char pos)
    (buffer-substring-no-properties
     (line-beginning-position)
     (line-end-position))))

(defun my/org-element-contents (element)
   "Get the contents of the partially specified 'element'
that only consists of '(TYPE PROPS)'."
   (let ((beg (org-element-property :contents-begin element))
         (end (org-element-property :contents-end element)))
     (get-line-at-pos beg)))

(defun my/clean-todo-text (text)
  "Remove Org-mode links and checklist markers from TEXT and return cleaned lines."
  (with-temp-buffer
    (insert text)
    (goto-char (point-min))
    ;; Remove checklist markers (- [ ] or - [X])
    (while (re-search-forward "^- \\[.\\]\\s-*" nil t)
      (replace-match ""))
    ;; Remove Org-mode links ([[id:...][text]] -> text)
    (goto-char (point-min))
    (while (re-search-forward "\\[\\[[^]]+\\]\\[\\([^]]+\\)\\]\\]" nil t)
      (replace-match "\\1"))
    ;; Return cleaned text, split into lines
    (split-string (buffer-string) "\n" t)))

(defun my-get-unfinished-tasks-under-heading-current-buffer (heading limit)
  "Find the first LIMIT unfinished tasks under a specific HEADING in the current buffer."
  (let* ((all-tasks (org-find-headlines-under-noparse heading
                      (lambda (head)
                        (member (org-element-property :checkbox head) '(off trans)))))
         (safe-limit (min limit (length all-tasks)))
         (limited-tasks (cl-subseq all-tasks 0 safe-limit)))
    (flatten-list
     (org-element-map limited-tasks 'item
       (lambda (item)
         (when (org-element-type-p (org-element-parent (org-element-parent item)) 'section)
           (my/clean-todo-text (s-trim (my/org-element-contents item)))))))))

(defun my-get-unfinished-tasks-under-heading (heading limit)
	"Find the first LIMIT unfinished tasks under a specific HEADING in today's daily file."
	(let ((daily-file (my-get-todays-daily-path)))
		(when (and daily-file (file-exists-p daily-file))
			(with-current-buffer (find-file-noselect daily-file)
				(my-get-unfinished-tasks-under-heading-current-buffer heading limit))))
	)

;; --- 3. The Notification Function ---
(defun my-notify-unfinished-tasks (&rest args)
  "Fetch top 3 unfinished tasks from 'Repeatable' and 'Speedruns'.
Send a styled desktop notification using Pango markup with
high-contrast colors for a black background."
  (interactive)
	(when (not (file-exists-p (my-get-todays-daily-path)))
		(org-roam-dailies-capture-today))
	(let* ((repeatable-tasks (my-get-unfinished-tasks-under-heading "Other progress / Distractions" 10))
					(speedrun-tasks (my-get-unfinished-tasks-under-heading "Speedruns" 1))
					(current-time (decode-time))
					(hour (nth 2 current-time))
					(minute (nth 1 current-time))
					)

    (when (and (or (> hour 10) (and (= hour 10) (>= minute 30)))
					(or repeatable-tasks speedrun-tasks) )
      ;; If tasks were found in either category, format and send the notification
      (let* ((format-task-list
               ;; Helper lambda to format a list of tasks into a numbered string
               (lambda (tasks)
                 (let ((i 1))
                   (mapconcat
                     (lambda (task)
                       (prog1 (format "<b>%d.</b> %s" i task) (setq i (1+ i))))
                     tasks
                     "\n"))))
              (repeatable-section
                (when repeatable-tasks
                  (format "<span font='12' weight='bold' foreground='#c0c0c0'>Distractions:</span>\n<span font='11' foreground='#e0e0e0'>%s</span>"
                    (funcall format-task-list repeatable-tasks))))
              (speedrun-section
                (when speedrun-tasks
                  (format "<span font='12' weight='bold' foreground='#c0c0c0'>Speedruns:</span>\n<span font='11' foreground='#e0e0e0'>%s</span>"
                    (funcall format-task-list speedrun-tasks))))
              ;; Join the sections that are not nil with a double newline
              (task-sections (string-join (delq nil (list repeatable-section speedrun-section)) "\n\n"))
              (message-body task-sections))

        (notifications-notify
          :title "Org Daily Reminder"
          :body message-body
          :app-name "Emacs"
          :urgency 'normal))
			)))

;; --- 4. Timer Management ---
;; We store the timer in a variable so we can cancel it later.
(defvar my-daily-reminder-timer nil "Holds the timer for the daily task reminder.")

(defun my-start-daily-reminder-timer ()
  "Start a timer that runs 'my-notify-unfinished-tasks' every 30 minutes."
  (interactive)
  (if (timerp my-daily-reminder-timer)
      (message "Reminder timer is already running.")
    (progn
      ;; The timer will start immediately (0), and repeat every 1800 seconds (30 minutes).
      (setq my-daily-reminder-timer
            (run-with-timer 0 (* 30 60) 'my-notify-unfinished-tasks))
      (message "Started daily reminder timer. You will be notified every 30 minutes."))))

(defun my-stop-daily-reminder-timer ()
  "Stop the currently running daily task reminder timer."
  (interactive)
  (if (timerp my-daily-reminder-timer)
      (progn
        (cancel-timer my-daily-reminder-timer)
        (setq my-daily-reminder-timer nil)
        (message "Daily reminder timer stopped."))
    (message "No daily reminder timer is running.")))


(after! org-roam
	(my-start-daily-reminder-timer))
