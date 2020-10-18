;;; package_configuration/dap-mode.el -*- lexical-binding: t; -*-

(require 'dap-netcore)
(setq dap-auto-configure-features '(sessions locals controls tooltip))
(require 'dap-firefox)
