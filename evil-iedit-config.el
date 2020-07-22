;;; ~/.doom.d/evil-iedit-config.el -*- lexical-binding: t; -*-
(require 'evil-iedit-state)

(map! (:leader
       "se" #'evil-iedit-state/iedit-mode))
