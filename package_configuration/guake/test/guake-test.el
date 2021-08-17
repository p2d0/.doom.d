;; -*- no-byte-compile: t; -*-
;;; package_configuration/guake/test/guake-test.el

(ert-deftest test-get-current-file-path ()
  (let ((path (or buffer-file-name default-directory)))
      (prin1 (file-name-directory path) )))
