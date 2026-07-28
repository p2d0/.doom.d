;;; package_configuration/review-queue/review-queue.el -*- lexical-binding: t; -*-

;; Code review queue: select region → SPC a c → comment → SPC a s → send to pi
;; Works in normal buffers and magit diff. Sends HTTP POST to pi extension at localhost:1984.

(require 'json)

(defvar review-queue--comments nil
  "List of queued review comments. Each element: (file start-line end-line text).")

(defvar review-queue--server-host "localhost"
  "Host of the pi review extension server.")

(defvar review-queue--server-port 1984
  "Port of the pi review extension server.")

(defun review-queue--safe-line-number (&optional pos)
  "Return line number at POS (or point if POS omitted), or nil if both nil."
  (line-number-at-pos pos))

(defun review-queue--get-file-and-lines ()
  "Return (file-path start-line end-line) from region or magit context. Signal error if none."
  (let* ((buffer-file (buffer-file-name))
         (file-path)
         (start-line)
         (end-line))
    ;; Magit diff: extract file and line range from hunk header
    (when (derived-mode-p 'magit-diff-mode)
      (save-excursion
        ;; Search backward for hunk header: @@ -old_start,old_count +new_start,new_count @@
        (when (re-search-backward "^@@ -[0-9,]+ +\\(+[0-9,]+\\)" (point-min) t)
          (let* ((plus-part (match-string 1))
                 (new-start (string-to-number (replace-regexp-in-string "^+" "" (car (split-string plus-part ",")))))
                 ;; Find the file path from the diff header (+++ b/file)
                 (file-header (save-excursion
                                (when (re-search-backward "^\\+\\+\\+ b/\\(.*\\)" (point-min) t)
                                  (match-string-no-properties 1)))))
            (when file-header
              (setq file-path file-header)
              (setq start-line new-start))))))
    ;; If we got file from magit, determine line range
    (when file-path
      (if (and (use-region-p) (mark) (region-beginning) (region-end))
          (setq start-line (or start-line (review-queue--safe-line-number (region-beginning)))
                end-line (review-queue--safe-line-number (region-end)))
        (setq start-line (or start-line (review-queue--safe-line-number))
              end-line start-line)))
    ;; Normal buffer: use buffer file and region/line
    (when (and (null file-path) buffer-file)
      (setq file-path (let ((root (review-queue--get-repo-root)))
                        (if root
                            (file-relative-name buffer-file root)
                          buffer-file)))
      (if (and (use-region-p) (mark) (region-beginning) (region-end))
          (setq start-line (review-queue--safe-line-number (region-beginning))
                end-line (review-queue--safe-line-number (region-end)))
        (setq start-line (review-queue--safe-line-number)
              end-line start-line)))
    ;; Require file path and valid lines
    (unless file-path
      (user-error "Cannot determine file path. Not in a file buffer or magit diff"))
    (unless (and start-line end-line)
      (user-error "Cannot determine line numbers"))
    (list file-path start-line end-line)))

(defun review-queue--get-repo-root ()
  "Return git repo root directory, or nil."
  (with-temp-buffer
    (when (zerop (call-process "git" nil t nil "rev-parse" "--show-toplevel"))
      (string-trim (buffer-string)))))

(defun review-queue--add-comment ()
  "Prompt for a review comment and add it to the queue."
  (interactive)
  (let* ((file-and-lines (review-queue--get-file-and-lines))
         (file (nth 0 file-and-lines))
         (start (nth 1 file-and-lines))
         (end (nth 2 file-and-lines))
         (range-str (if (= start end)
                        (number-to-string start)
                      (format "%d-%d" start end)))
         (prompt (format "Review comment (%s:%s): " file range-str))
         (text (read-string prompt)))
    (when (and text (> (length (string-trim text)) 0))
      (push (list file start end text) review-queue--comments)
      (message "Review comment queued (%d total)" (length review-queue--comments)))))

(defun review-queue--format-queue ()
  "Format the queue as JSON for HTTP POST."
  (let ((comments (if (null review-queue--comments)
                      (seq-into '[] 'vector)
                    (mapcar (lambda (c)
                              (list (cons "file" (nth 0 c))
                                    (cons "start" (nth 1 c))
                                    (cons "end" (nth 2 c))
                                    (cons "text" (nth 3 c))))
                            review-queue--comments))))
    (json-encode (list (cons "comments" comments)))))

(defun review-queue--send-to-pi ()
  "Send queued comments to pi via HTTP POST."
  (interactive)
  (when (null review-queue--comments)
    (user-error "Review queue is empty"))
  (let* ((data (review-queue--format-queue))
         (url (format "http://%s:%d/review" review-queue--server-host review-queue--server-port))
         (sent-count (length review-queue--comments))
         (tmp-file (make-temp-file "review-queue"))
         (exit-code nil))
    (with-temp-file tmp-file
      (insert data))
    (setq exit-code (call-process
                     "curl" nil nil nil
                     "-sf" "-X" "POST"
                     "-H" "Content-Type: application/json"
                     "-d" (format "@%s" tmp-file)
                     url))
    (ignore-errors (delete-file tmp-file))
    (if (or (null exit-code)
            (zerop exit-code))
        (progn
          (setq review-queue--comments nil)
          (message "Sent %d review comment(s) to pi" sent-count))
      (message "Failed to send to pi (curl exit %d). Pi session may not be running." exit-code))))

(defun review-queue--show-queue ()
  "Show the review queue in a buffer."
  (interactive)
  (when (get-buffer "*review-queue*")
    (kill-buffer "*review-queue*"))
  (let ((buf (generate-new-buffer "*review-queue*")))
    (with-current-buffer buf
      (if (null review-queue--comments)
          (insert "Review queue is empty.\n")
        (insert (format "Review queue (%d comments)\n\n" (length review-queue--comments)))
        (insert "Keybindings: RET=open, d=delete, e=edit, q=quit\n\n")
        (let ((idx 1))
          (dolist (c review-queue--comments)
            (let ((file (nth 0 c))
                  (start (nth 1 c))
                  (end (nth 2 c))
                  (text (nth 3 c)))
              (let ((range-str (if (= start end)
                                   (number-to-string start)
                                 (format "%d-%d" start end))))
                (insert (format "%d. %s:%s\n    %s\n\n" idx file range-str text)))
              (setq idx (1+ idx)))))
      (review-queue--queue-mode)
      (display-buffer buf)))
    (message "Review queue: %d comment(s)" (length review-queue--comments))))

(define-derived-mode review-queue--queue-mode special-mode "Review-Queue"
  "Mode for the review queue buffer."
  (setq buffer-read-only t))

;; Keybindings — defined unconditionally for batch mode and Doom
(define-key review-queue--queue-mode-map (kbd "d") #'review-queue--delete-comment)
(define-key review-queue--queue-mode-map (kbd "e") #'review-queue--edit-comment)
(define-key review-queue--queue-mode-map (kbd "RET") #'review-queue--open-at-point)
(define-key review-queue--queue-mode-map (kbd "<return>") #'review-queue--open-at-point)
(define-key review-queue--queue-mode-map (kbd "q") #'quit-window)
(define-key review-queue--queue-mode-map (kbd "C-g") #'keyboard-quit)

;; Evil mode: RET intercepted by Evil, override with evil-define-key
(when (fboundp 'evil-define-key)
  (evil-define-key 'normal review-queue--queue-mode-map
    (kbd "RET") #'review-queue--open-at-point
    (kbd "<return>") #'review-queue--open-at-point
    (kbd "d") #'review-queue--delete-comment
    (kbd "e") #'review-queue--edit-comment
    (kbd "q") #'quit-window)
  (evil-set-initial-state 'review-queue--queue-mode 'normal))

(defun review-queue--open-at-point ()
  "Open the file at the comment on this line and jump to it."
  (interactive)
  (save-excursion
    ;; Move up to find entry header (may be on comment text line)
    (while (and (not (bobp))
                (not (looking-at (rx (one-or-more digit) ". "
                                     (one-or-more (not ":")) ":"
                                     (one-or-more digit)))))
      (forward-line -1))
    (if (looking-at (rx (one-or-more digit) ". "
                        (group (one-or-more (not ":"))) ":"
                        (group (one-or-more digit))
                        (? "-" (one-or-more digit))))
        (let ((file (match-string-no-properties 1))
              (line (string-to-number (match-string-no-properties 2)))
              (repo-root (review-queue--get-repo-root)))
          (find-file (expand-file-name file repo-root))
          (goto-line line)
          (message "Opened %s at line %d" file line)))
      (user-error "Not on a review queue entry")))

(defun review-queue--delete-comment ()
  "Delete the comment at point from the queue."
  (interactive)
  (let ((idx (review-queue--get-index-at-point)))
    (when idx
      (setf (nth (1- idx) review-queue--comments) nil)
      (setq review-queue--comments (delq nil review-queue--comments))
      (review-queue--show-queue)
      (message "Deleted comment %d" idx))))

(defun review-queue--edit-comment ()
  "Edit the comment text at point."
  (interactive)
  (let* ((idx (review-queue--get-index-at-point))
         (comment (and idx (nth (1- idx) review-queue--comments))))
    (when comment
      (let ((new-text (read-string "Edit comment: " (nth 3 comment))))
        (when (> (length (string-trim new-text)) 0)
          (setcar (nthcdr 3 comment) new-text)
          (review-queue--show-queue)
          (message "Updated comment %d" idx))))))

(defun review-queue--get-index-at-point ()
  "Return the comment index at point, or nil."
  (save-excursion
    ;; Move up to find entry header
    (while (and (not (bobp))
                (not (looking-at (rx (one-or-more digit) "\."))))
      (forward-line -1))
    (when (looking-at (rx (group (one-or-more digit)) "\."))
      (string-to-number (match-string 1)))))

;; Leader keybindings: SPC a c, SPC a q, SPC a s
(when (fboundp 'map!)
  (map! :leader
        (:prefix ("a" . "Review")
          :desc "Add review comment" "c" #'review-queue--add-comment
          :desc "Show review queue" "q" #'review-queue--show-queue
))
)
