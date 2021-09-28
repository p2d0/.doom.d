;;; package_configuration/writeroom-mode.el -*- lexical-binding: t; -*-
(after! org
	(global-writeroom-mode)
	(setq writeroom-major-modes '(markdown-mode org-mode org-roam-mode)))
