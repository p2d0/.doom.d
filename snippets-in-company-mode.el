;;; snippets-config.el -*- lexical-binding: t; -*-


(after! sh-script
  (set-company-backend! 'sh-mode
    '(company-shell :with company-yasnippet)))

(after! lsp-mode
  (setq lsp-mode-hook
        (remq '+lsp-init-company-h lsp-mode-hook)))

(after! omnisharp
  (set-company-backend! 'omnisharp-mode
    '(company-omnisharp :with company-yasnippet)))

(setq-default company-backends '((company-yasnippet :separate company-capf)))
