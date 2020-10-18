;;; package_configuration/evil-motion-trainer.el -*- lexical-binding: t; -*-

(evil-motion-trainer-mode)
(after! evil-motion-trainer
  (global-evil-motion-trainer-mode 1)
  (setq evil-motion-trainer-threshold 3))
