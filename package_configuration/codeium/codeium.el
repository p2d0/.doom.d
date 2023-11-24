;;; editors/.doom.d/package_configuration/codeium/codeium.el -*- lexical-binding: t; -*-

;; (after! lsp
;;   (advice-add #'lsp-completion-at-point :around #'cape-wrap-nonexclusive))
(after! emacs-lisp
  (advice-add #'elisp-completion-at-point :around #'cape-wrap-nonexclusive))
;; (after! fish
;;   (advice-add #'cape-keyword :around #'cape-wrap-nonexclusive))
;; (after! python
;;   (advice-add #'python-completion-at-point :around #'cape-wrap-nonexclusive))

(defun codeium-complete ()
	(interactive)
	(let ((completion-at-point-functions '(codeium-completion-at-point)))
		(completion-at-point)
		)
	)
(map! "C-x C-i" #'codeium-complete)
;; keep the cursor on the same position after completing
;; (add-hook 'company-completion-started-hook #'company-posframe-enable)

(use-package codeium
  ;; if you use straight
  ;; :straight '(:type git :host github :repo "Exafunction/codeium.el")
  ;; otherwise, make sure that the codeium.el file is on load-path

  :init
  ;; use globally
  ;; (add-to-list 'completion-at-point-functions #'codeium-completion-at-point)
  ;; or on a hook
  ;; (add-hook 'python-mode-hook
  ;;     (lambda ()
  ;;         (setq-local completion-at-point-functions '(codeium-completion-at-point))))

  ;; if you want multiple completion backends, use cape (https://github.com/minad/cape):
	(add-hook 'prog-mode-hook
		(lambda ()
			(add-to-list 'completion-at-point-functions #'codeium-completion-at-point 1)))
  ;; (add-hook 'emacs-lisp-mode-hook
  ;;   (lambda ()
  ;;     (setq-local completion-at-point-functions
  ;;       (list #'elisp-completion-at-point #'codeium-completion-at-point))))
	;; codeium-completion-at-point is autoloaded, but you can bibasically
  ;; codeium-completion-at-point is autoloaded, but you can
  ;; optionally set a timer, which might speed up things as the
  ;; codeium local language server takes ~0.2s to start up
  ;; (add-hook 'emacs-startup-hook
  ;;  (lambda () (run-with-timer 0.1 nil #'codeium-init)))

  ;; :defer t ;; lazy loading, if you want
  ;; :config
  ;; (setq use-dialog-box nil) ;; do not use popup boxes

  ;; ;; if you don't want to use customize to save the api-key
  ;; ;; (setq codeium/metadata/api_key "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")

  ;; ;; get codeium status in the modeline
  ;; (setq codeium-mode-line-enable
  ;;   (lambda (api) (not (memq api '(CancelRequest Heartbeat AcceptCompletion)))))
  ;; (add-to-list 'mode-line-format '(:eval (car-safe codeium-mode-line)) t)
  ;; ;; alternatively for a more extensive mode-line
  ;; ;; (add-to-list 'mode-line-format '(-50 "" codeium-mode-line) t)

  ;; ;; use M-x codeium-diagnose to see apis/fields that would be sent to the local language server
  ;; (setq codeium-api-enabled
  ;;   (lambda (api)
  ;;     (memq api '(GetCompletions Heartbeat CancelRequest GetAuthToken RegisterUser auth-redirect AcceptCompletion))))
  ;; ;; you can also set a config for a single buffer like this:
  ;; ;; (add-hook 'python-mode-hook
  ;; ;;     (lambda ()
  ;; ;;         (setq-local codeium/editor_options/tab_size 4)))

  ;; ;; You can overwrite all the codeium configs!
  ;; ;; for example, we recommend limiting the string sent to codeium for better performance
  ;; (defun my-codeium/document/text ()
  ;;   (buffer-substring-no-properties (max (- (point) 3000) (point-min)) (min (+ (point) 1000) (point-max))))
  ;; ;; if you change the text, you should also change the cursor_offset
  ;; ;; warning: this is measured by UTF-8 encoded bytes
  ;; (defun my-codeium/document/cursor_offset ()
  ;;   (codeium-utf8-byte-length
  ;;     (buffer-substring-no-properties (max (- (point) 3000) (point-min)) (point))))
  ;; (setq codeium/document/text 'my-codeium/document/text)
  ;; (setq codeium/document/cursor_offset 'my-codeium/document/cursor_offset)
  )
