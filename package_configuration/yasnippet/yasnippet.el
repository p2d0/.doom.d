;;; package_configuration/yasnippet/yasnippet.el -*- lexical-binding: t; -*-

(yas-minor-mode-on)

;; TODO fix
(add-hook 'yas-after-exit-snippet-hook
  (lambda () (indent-buffer)))
