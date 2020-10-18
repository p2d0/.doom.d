;;; snippets-config.el -*- lexical-binding: t; -*-

(use-package! company-tabnine
  :after company
  :config
  (cl-pushnew 'company-tabnine (default-value 'company-backends)))

(setq company-show-numbers t)

(after! sh-script
  (set-company-backend! 'sh-mode
    '(company-shell :with company-tabnine)))

(after! lsp-mode
  (setq lsp-mode-hook
        (remq '+lsp-init-company-h lsp-mode-hook)))

(after! omnisharp
  (set-company-backend! 'omnisharp-mode
    '(company-omnisharp :separate company-tabnine)))
