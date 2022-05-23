;;; package_configuration/taskrunner/taskrunner.el -*- lexical-binding: t; -*-

(after! taskrunner
  (set-popup-rule! taskrunner--buffer-name-regexp
		:size 16
		:quit t))
