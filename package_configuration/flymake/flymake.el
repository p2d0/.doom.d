;;; nixos/editors/.doom.d/package_configuration/flymake/flymake.el -*- lexical-binding: t; -*-


(map! :leader
      :prefix ("e" . "Errors")
      "l" #'consult-flymake
      ;; "n" #'flycheck-next-error
      ;; "p" #'flycheck-previous-error
	)
