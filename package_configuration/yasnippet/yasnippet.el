;;; package_configuration/yasnippet/yasnippet.el -*- lexical-binding: t; -*-

;; (yas-minor-mode-on)

;; TODO fix

(defun my/org-tab-conditional ()
  (interactive)
  (if (yas-active-snippets)
    (yas-next-field-or-maybe-expand)
    (org-cycle)))

(after! yasnippet
	(setq yas-wrap-around-region t)
	(map! :map yas-keymap
		:n [tab] #'yas-next-field-or-maybe-expand)
	(add-hook 'yas-after-exit-snippet-hook
		(lambda () (indent-buffer))))
