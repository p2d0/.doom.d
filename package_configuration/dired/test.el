;;; package_configuration/dired/test.el -*- lexical-binding: t; -*-

(require 'test-simple)
(test-simple-start)

;; (assert-t (load-file "./map.el"))

(note "Get string after should return string")
(assert-equal "kekw" (get-string-after-: "1       [.doom.d] Find file: kekw"))

(end-tests)
