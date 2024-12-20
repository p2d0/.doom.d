;;; nixos/editors/.doom.d/package_configuration/tailwind/tailwind.el -*- lexical-binding: t; -*-

(use-package! lsp-tailwindcss :after lsp-mode)

(after! lsp-mode
	(set-company-backend! 'web-mode 'company-capf)
	)
