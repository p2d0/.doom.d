;;; snippets-config.el -*- lexical-binding: t; -*-

(require 'company-tabnine)
(add-to-list 'company-backends #'company-tabnine)
(setq company-show-numbers t)

(after! sh-script
  (set-company-backend! 'sh-mode
    '(company-shell :with company-yasnippet)))

(after! lsp-mode
  (setq lsp-mode-hook
        (remq '+lsp-init-company-h lsp-mode-hook)))

(after! omnisharp
  (set-company-backend! 'omnisharp-mode
    '(company-omnisharp :separate company-tabnine)))

(setq-default company-backends '((company-tabnine :separate company-capf)))
