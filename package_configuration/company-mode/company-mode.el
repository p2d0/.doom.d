;;; package_configuration/company-mode.el -*- lexical-binding: t; -*-

(setq company-lighter nil)

(set-company-backend! 'prog-mode 'company-capf '(:separate company-yasnippet company-tabnine))
;; (after! emacs-lisp
;;   (add-to-list 'company-backends 'company-tabnine)
;;   )
