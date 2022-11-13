;;; package_configuration/writeroom-mode.el -*- lexical-binding: t; -*-
(after! org
	(global-writeroom-mode)
	(setq writeroom-width 100)
	(setq +zen-text-scale 1.5)
	(setq writeroom-major-modes '(;; markdown-mode
																 org-mode org-roam-mode)))
