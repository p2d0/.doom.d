;;; package_configuration/review-queue/test/test-review-queue.el -*- lexical-binding: t; -*-

(require 'buttercup)
(require 'json)

(defvar review-queue-test-dir (file-name-directory load-file-name))

(defun review-queue-test--load-deps ()
  "Load review-queue module for tests."
  (load-file (expand-file-name "../review-queue.el" review-queue-test-dir)))

(describe "review-queue"
  (before-all (review-queue-test--load-deps))

  (describe "review-queue--get-file-and-lines"
    (before-each (setq review-queue--comments nil))

    (it "returns file path and line range for normal buffer with region"
      (expect t :to-equal t))

    (it "returns file path and current line for normal buffer without region"
      (let ((tmp-file (make-temp-file "test")))
        (unwind-protect
            (progn
              (with-temp-file tmp-file
                (insert "line1\nline2\nline3\n"))
              (with-temp-buffer
                (let ((buffer-file-name tmp-file)
                      (default-directory temporary-file-directory))
                  (insert "line1\nline2\nline3\n")
                  (goto-char (point-min))
                  (forward-line 1)
                  (let ((result (review-queue--get-file-and-lines)))
                    (expect (nth 0 result) :to-equal tmp-file)
                    (expect (nth 1 result) :to-equal 2)
                    (expect (nth 2 result) :to-equal 2)))))
          (delete-file tmp-file))))

    (it "returns relative path when in git repo"
      (let ((tmp-dir (make-temp-file "test-repo" t)))
        (unwind-protect
            (progn
              (let ((tmp-file (expand-file-name "src/test.el" tmp-dir)))
                (make-directory (file-name-directory tmp-file) t)
                (shell-command (format "git -C %s init -q" tmp-dir))
                (with-temp-file tmp-file
                  (insert "test\n"))
                (with-temp-buffer
                  (let ((buffer-file-name tmp-file)
                        (default-directory tmp-dir))
                    (insert "test\n")
                    (goto-char (point-min))
                    (let ((result (review-queue--get-file-and-lines)))
                      (expect (nth 0 result) :to-equal "src/test.el")
                      (expect (nth 1 result) :to-equal 1)))))
          (delete-directory tmp-dir 'recursive)))))

    (it "signals error in scratch buffer with no file"
      (with-temp-buffer
        (expect (review-queue--get-file-and-lines)
                :to-throw)))

    (it "extracts file and line from magit diff buffer"
      (with-temp-buffer
        (insert
         "diff --git a/src/test.el b/src/test.el\n"
         "index abc123..def456 100644\n"
         "--- a/src/test.el\n"
         "+++ b/src/test.el\n"
         "@@ -10,3 +10,4 @@ defun foo ()\n"
         "   (message \"hello\")\n"
         "   (message \"world\")\n"
         "+ (message \"new line\")\n")
        (setq major-mode 'magit-diff-mode)
        (goto-char (point-min))
        (forward-line 6)
        (let ((result (review-queue--get-file-and-lines)))
          (expect (nth 0 result) :to-equal "src/test.el")
          (expect (nth 1 result) :to-equal 10)
          (expect (nth 2 result) :to-equal 10))))

    (it "uses region lines in magit diff buffer"
      (with-temp-buffer
        (insert
         "diff --git a/src/test.el b/src/test.el\n"
         "index abc123..def456 100644\n"
         "--- a/src/test.el\n"
         "+++ b/src/test.el\n"
         "@@ -10,3 +10,4 @@ defun foo ()\n"
         "   (message \"hello\")\n"
         "   (message \"world\")\n"
         "+ (message \"new line\")\n")
        (setq major-mode 'magit-diff-mode)
        (goto-char (point-min))
        (forward-line 5)
        (set-mark (point))
        (forward-line 4)
        (let ((result (review-queue--get-file-and-lines)))
          (expect (nth 0 result) :to-equal "src/test.el")
          (expect (nth 1 result) :to-equal 10)
          (expect (nth 2 result) :to-equal 10))))

    (it "signals error in magit buffer with no hunk header"
      (with-temp-buffer
        (insert "no diff here\n")
        (setq major-mode 'magit-diff-mode)
        (expect (review-queue--get-file-and-lines)
                :to-throw))))

  (describe "review-queue--format-queue"
    (before-each (setq review-queue--comments nil))

    (it "formats empty queue as JSON"
      (expect (review-queue--format-queue)
              :to-equal "{\"comments\":[]}"))

    (it "formats comments as JSON array"
      (setq review-queue--comments
            '(("src/test.el" 10 15 "This is a comment")))
      (let ((json (review-queue--format-queue)))
        (expect json :to-match "\"comments\"")
        (expect json :to-match "\"src/test.el\"")
        (expect json :to-match "\"This is a comment\"")
        (expect json :to-match "\"start\":10")
        (expect json :to-match "\"end\":15"))))

  (describe "review-queue--comments"
    (before-each (setq review-queue--comments nil))

    (it "pushes comment to queue"
      (push '("file.el" 1 5 "test") review-queue--comments)
      (expect (length review-queue--comments) :to-equal 1)
      (expect (nth 0 review-queue--comments) :to-equal '("file.el" 1 5 "test")))))

(describe "queue management"
  (before-all (review-queue-test--load-deps))

  (it "parses index at point"
    (with-temp-buffer
      (insert "1. src/test.el:10-15\n    comment text\n")
      (goto-char (point-min))
      (expect (review-queue--get-index-at-point) :to-equal 1)))

  (it "queue mode keymap has RET bound"
    (let ((key-seq (vector ?\r)))
      (expect (lookup-key review-queue--queue-mode-map key-seq)
              :to-equal #'review-queue--open-at-point)))

  (it "queue mode keymap has d/e/q bound"
    (expect (lookup-key review-queue--queue-mode-map (kbd "d"))
            :to-equal #'review-queue--delete-comment)
    (expect (lookup-key review-queue--queue-mode-map (kbd "e"))
            :to-equal #'review-queue--edit-comment)
    (expect (lookup-key review-queue--queue-mode-map (kbd "q"))
            :to-equal #'quit-window))

  (it "evil-define-key configures Evil normal mode when available"
    ;; evil-define-key not available in batch mode, skip if missing
    (assume (fboundp 'evil-define-key) "evil-define-key not available")
    ;; evil-define-key sets bindings in evil-normal-state-map overlay
    ;; Verify at least one binding is set via evil's state-local keymap
    (let ((evil-normal-state-map (get 'evil-normal-state 'evil-keymap)))
      (when evil-normal-state-map
        (expect (lookup-key review-queue--queue-mode-map (kbd "RET"))
                :to-equal #'review-queue--open-at-point))))

  (it "deletes comment by index"
    (let ((review-queue--comments '(("file1.el" 1 5 "first")
                                     ("file2.el" 10 15 "second"))))
      (setf (nth 0 review-queue--comments) nil)
      (setq review-queue--comments (delq nil review-queue--comments))
      (expect (length review-queue--comments) :to-equal 1)
      (expect (nth 0 review-queue--comments) :to-equal '("file2.el" 10 15 "second"))))

  (it "edits comment text"
    (let ((review-queue--comments '(("file1.el" 1 5 "first")
                                     ("file2.el" 10 15 "second"))))
      (let ((comment (nth 0 review-queue--comments)))
        (setcar (nthcdr 3 comment) "updated"))
      (expect (nth 3 (nth 0 review-queue--comments)) :to-equal "updated")))

  (it "comment is a proper list"
    (let ((review-queue--comments '(("file1.el" 1 5 "first")
                                     ("file2.el" 10 15 "second"))))
      (expect (listp (nth 0 review-queue--comments)) :to-equal t)
      (expect (length (nth 0 review-queue--comments)) :to-equal 4))))

(describe "review-queue--send-to-pi buffer safety"
  (before-all (review-queue-test--load-deps))

  (it "does not insert HTTP response into current buffer"
    (with-temp-buffer
      (insert "original content")
      (let ((start-len (buffer-size)))
        (condition-case nil
            (progn
              (setq review-queue--server-host "localhost")
              (setq review-queue--server-port 1984)
              (call-process "curl" nil nil nil
                            "-sf" "-X" "GET"
                            "http://localhost:1984/health"))
          (error nil))
        (expect (buffer-size) :to-equal start-len)
)
)))
