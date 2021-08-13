;; -*- no-byte-compile: t; -*-
;;; package_configuration/org-roam/test/org-roam-test.el

(load-file "../org-roam.el")
(ert-deftest ert-test-record-backtrace ()
  (let ((test (make-ert-test :body (lambda () (ert-fail "foo")))))
    (let ((result (ert-run-test test)))
      (should (ert-test-failed-p result))
      (with-temp-buffer
        (ert--insert-backtrace-header (ert-test-failed-backtrace result))
        (goto-char (point-min))
        (end-of-line)
        (let ((first-line (buffer-substring-no-properties
                           (point-min) (point))))
          (should (equal first-line
                         "  signal(ert-test-failed (\"foo\"))")))))))
