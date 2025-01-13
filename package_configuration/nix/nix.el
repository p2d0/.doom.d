;;; package_configuration/nix/nix.el -*- lexical-binding: t; -*-

;; (after! nix-mode
;;   (setq lsp-nix-server-path "nil")
;; 	)

;; ;; (use-package nix-mode
;; ;; :after lsp-mode
;; ;; :ensure t
;; ;; :hook
;; ;; (nix-mode . lsp-deferred) ;; So that envrc mode will work
;; ;; :custom
;; ;; (lsp-disabled-clients '((nix-mode . nix-nil))) ;; Disable nil so that nixd will be used as lsp-server
;; ;; :config
;; ;; (setq lsp-nix-nixd-server-path "nixd"
;; ;;       lsp-nix-nixd-formatting-command [ "nixfmt" ]
;; ;;       lsp-nix-nixd-nixpkgs-expr "import (builtins.getFlake \"/etc/nixos/\").inputs.nixpkgs { }"
;; ;;       lsp-nix-nixd-nixos-options-expr "(builtins.getFlake \"/etc/nixos\").nixosConfigurations.mysystem.options"
;; ;;       lsp-nix-nixd-home-manager-options-expr "(builtins.getFlake \"/etc/nixos\").nixosConfigurations.mysystem.options.home-manager.users.type.getSubOptions []"
;; ;; 	))

;; ;; (with-eval-after-load 'lsp-mode
;; ;;   (lsp-register-client
;; ;;     (make-lsp-client :new-connection (lsp-stdio-connection "nixd")
;; ;;                      :major-modes '(nix-mode)
;; ;;                      :priority 0
;; ;;                      :server-id 'nixd)))

;; (add-hook! 'nix-mode-hook
;;          ;; enable autocompletion with company
;;          (setq company-idle-delay 0.1))

;; (after! lsp
;;   (add-to-list 'lsp-language-id-configuration '(nix-mode . "nix"))
;;   (lsp-register-client
;;    (make-lsp-client :new-connection (lsp-stdio-connection '("nil"))
;;                     :major-modes '(nix-mode)
;;                     :server-id 'nix)))

;; (use-package lsp-nix
;;   :ensure lsp-mode
;;   :after (lsp-mode)
;;   :demand t
;; 	;; :config
;;   ;; (setq +lsp-company-backends '(:separate  company-capf))
;;   ;; :custom
;;   ;; (lsp-nix-nil-formatter ["nixpkgs-fmt"])
;; 	)

;; (use-package nix-mode
;;   :hook (nix-mode . lsp-deferred)
;; 	:config
;;   (setq +lsp-company-backends '(:separate  company-capf))
;;   ;; :ensure t
;; 	)

(use-package lsp-mode
  :ensure t)

(use-package lsp-nix
  :ensure lsp-mode
  :after (lsp-mode)
  :demand t
  :custom
  (lsp-nix-nil-formatter ["nixfmt"])
	(lsp-nix-nil-max-mem 16000)
	(lsp-nix-nil-auto-eval-inputs nil)
	)

(use-package nix-mode
  :hook (nix-mode . lsp-deferred)
  :ensure t)
