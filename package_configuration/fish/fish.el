;;; package_configuration/fish/fish.el -*- lexical-binding: t; -*-

(after! fish-mode
	(setq company-fish-enabled-modes '(fish-mode))

	(when (executable-find "fish")
		(add-to-list 'company-backends 'company-fish)
		(add-hook 'fish-mode-hook 'company-mode)
		(add-hook 'shell-mode-hook 'company-mode)
		(add-hook 'eshell-mode-hook 'company-mode))

	(set-company-backend! 'fish-mode 'company-fish 'company-yasnippet)


	(flycheck-define-checker fish
		"Fish -n linter"
		:command ("fish" "-n" source)
		:error-patterns ((error line-start (one-or-more anything) " (line " line "): " (message) line-end )

											)
		:error-filter (lambda (errors) (flycheck-sanitize-errors errors))
		:modes fish-mode
		)

	(add-to-list 'flycheck-checkers 'fish))
