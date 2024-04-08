;;; package_configuration/lsp/lsp.el -*- lexical-binding: t; -*-

(setq lsp-ui-doc-enable nil)
(setq lsp-lens-enable nil)
(setq lsp-ui-sideline-enable nil)

(setq lsp-enable-file-watchers nil)
(setq lsp-disabled-clients '())
;; (setq lsp-disabled-clients '((python-mode . pylsp)))
(setq read-process-output-max (* 1024 1024))
;; (setq lsp-completion-provider :capf)
;; (add-to-list 'lsp-language-id-configuration '("\\.tpl$" . "smarty"))
