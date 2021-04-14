;;; package_configuration/evil-motion-trainer.el -*- lexical-binding: t; -*-

(evil-motion-trainer-mode)
(global-evil-motion-trainer-mode 1)
(setq evil-motion-trainer-threshold 3)
(after! evil-motion-trainer-mode
  (global-evil-motion-trainer-mode 1)
  (setq evil-motion-trainer-threshold 3))
