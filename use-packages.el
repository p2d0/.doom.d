;;; editors/.doom.d/use-packages.el -*- lexical-binding: t; -*-

(use-package! org-attach-screenshot
	:after org-mode)


;; TODO only import autoload
(use-package! benchmark-init
	:disabled
  ;; :ensure t
  ;; :config
  ;; ;; (add-hook 'after-init-hook 'benchmark-init/deactivate)
  ;; (add-hook 'doom-first-input-hook 'benchmark-init/deactivate)
	)
;; (use-package! ssh-deploy
;; 	:after lisp-data-mode)
