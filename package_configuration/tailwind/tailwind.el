;;; nixos/editors/.doom.d/package_configuration/tailwind/tailwind.el -*- lexical-binding: t; -*-

(use-package! lsp-tailwindcss
	:after lsp-mode)

(after! lsp
	(set-company-backend! 'web-mode 'company-capf)
	)
