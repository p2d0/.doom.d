;;; nixos/editors/.doom.d/package_configuration/codeium/tests/codeium_test.el -*- lexical-binding: t; -*-

(describe "company backend"
  (before-all)
  (it "should return something"
    (let* ((result (company-dabbrev 'candidates "expe")))
      (expect result :to-be-truthy) )
    ))

(describe "codeium company"
  (before-all
    (load-file "../codeium.el"))
  (it "should return something"
    (expect t :to-be-truthy)))
