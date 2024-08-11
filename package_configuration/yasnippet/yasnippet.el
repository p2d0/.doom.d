;;; package_configuration/yasnippet/yasnippet.el -*- lexical-binding: t; -*-

;; (yas-minor-mode-on)

;; TODO fix

(defun my/org-tab-conditional ()
  (interactive)
  (if (yas-active-snippets)
    (yas-next-field-or-maybe-expand)
    (org-cycle)))

;; (after! yasnippet
;; 	(setq yas-wrap-around-region t)
;; 	(map! :map yas-minor-mode-map
;; 		:n [tab] #'yas-next-field-or-maybe-expand
;; 		:i [tab] #'yas-next-field-or-maybe-expand
;; 		:n "S-TAB" #'yas-next-field-or-maybe-expand
;; 		:i "S-TAB" #'yas-next-field-or-maybe-expand
;; 		)
;; 	(add-hook 'yas-after-exit-snippet-hook
;; 		(lambda () (indent-buffer))))
