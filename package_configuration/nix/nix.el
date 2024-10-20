;;; package_configuration/nix/nix.el -*- lexical-binding: t; -*-

(after! nix-mode
  (setq lsp-nix-server-path "nil"))

;; (after! lsp
;;   (add-to-list 'lsp-language-id-configuration '(nix-mode . "nix"))
;;   (lsp-register-client
;;    (make-lsp-client :new-connection (lsp-stdio-connection '("nil"))
;;                     :major-modes '(nix-mode)
;;                     :server-id 'nix)))

(use-package lsp-nix
  :ensure lsp-mode
  :after (lsp-mode)
  :demand t
  ;; :custom
  ;; (lsp-nix-nil-formatter ["nixpkgs-fmt"])
	)

(use-package nix-mode
  :hook (nix-mode . lsp-deferred)
  :ensure t)
