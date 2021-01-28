;;; package_configuration/yasnippet/yasnippet.el -*- lexical-binding: t; -*-

(yas-minor-mode-on)

(add-hook 'yas-after-exit-snippet-hook
  (lambda () (evil-indent (point-min) (point-max))))

