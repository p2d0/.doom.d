;;; ~/.doom.d/evil-iedit-config.el -*- lexical-binding: t; -*-
(require 'evil-iedit-state)
(defalias 'iedit-cleanup 'iedit-lib-cleanup)

(map! (:leader
       "se" #'evil-iedit-state/iedit-mode))
