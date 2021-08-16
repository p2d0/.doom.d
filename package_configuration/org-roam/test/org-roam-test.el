;; -*- no-byte-compile: t; -*-
;;; package_configuration/org-roam/test/org-roam-test.el

(load-file "../org-roam.el")
(ert-deftest test-get-backlinks ()
  (with-current-buffer "20210809144731-tdd_the_bad_parts_matt_parker.org"
    (let ((backlinks (org-roam-backlinks-get (org-roam-node-at-point))))
      (should (= 1 (seq-length backlinks)))
      (prin1 (plist-get (org-roam-backlink-properties (cl-first backlinks )) :outline ))
      )))

(ert-deftest test-adding-backlinks ()
  (with-current-buffer "20210809144731-tdd_the_bad_parts_matt_parker.org"
    (roam-export/insert-backlinks)
    (let ((text (buffer-substring-no-properties (point-min) (point-max))))
      (should (s-contains? "Backlinks" text))
      (should (s-contains? "(Articles -> TDD: The Bad Parts — Matt Parker)" text))
      )))

(ert-deftest test-exporting-automatically ()
  (with-current-buffer (find-file-noselect "~/Dropbox/org/roam/20210809144731-tdd_the_bad_parts_matt_parker.org" )
    ;; (publish-dir-org)
    ;; (prin1 (seq-length (file-expand-wildcards "*.org") ) )
    ))

(ert-deftest test-getting-tags ()
  (with-current-buffer (find-file-noselect "~/Dropbox/org/roam/20210810192401-deep_work.org" )
    (should (= (seq-length '("fjsdklfj")) 1))
    (should (equal (list "kek" "book") (roam-export/get-tags (list "kek") "info")))))

;; (ert-deftest ert-test-record-backtrace ()
;;   (let ((test (make-ert-test :body (lambda () (ert-fail "foo")))))
;;     (let ((result (ert-run-test test)))
;;       (should (ert-test-failed-p result))
;;       (with-temp-buffer
;;         (ert--insert-backtrace-header (ert-test-failed-backtrace result))
;;         (goto-char (point-min))
;;         (end-of-line)
;;         (let ((first-line (buffer-substring-no-properties
;;                            (point-min) (point))))
;;           (should (equal first-line
;;                          "  signal(ert-test-failed (\"foo\"))")))))))
