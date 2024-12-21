;;; nixos/editors/.doom.d/package_configuration/web/web.el -*- lexical-binding: t; -*-


(after! web-mode
	(setq web-mode-comment-style 2)
 ;; TODO autocomplete web-mode
	(map! :map web-mode-map
		:i "C-j" #'emmet-expand-line
		)
	)
