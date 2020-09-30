;;; ~/.doom.d/packages_configuration/omnisharp.el -*- lexical-binding: t; -*-

;; (setq omnisharp-expected-server-version "1.35.2")

(after! omnisharp
  (map! :localleader
        :map omnisharp-mode-map
        :prefix "r"
        "r" #'omnisharp-run-code-action-refactoring)
  (map!
   :localleader
   :map omnisharp-mode-map
   :prefix "g"
   :desc "Go to Definition"
   "d" #'omnisharp-go-to-definition
   "D" #'omnisharp-go-to-definition-other-window
   )
  (map! :localleader
        :map omnisharp-mode-map
        :prefix "r"
        "R" #'omnisharp-rename))
