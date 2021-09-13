;;; package_configuration/company-mode.el -*- lexical-binding: t; -*-

(setq company-lighter nil)

(after! emacs-lisp-mode
  (set-company-backend! 'company-capf 'company-yasnippet))
