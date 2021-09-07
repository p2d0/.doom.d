;;; ~/.doom.d/evil-iedit-config.el -*- lexical-binding: t; -*-
;; (require 'evil-iedit-state)
;; (defalias 'iedit-cleanup 'iedit-lib-cleanup)

;; (map! (:leader
;;        "se" #'evil-iedit-state/iedit-mode))

(defun evil-multiedit-match-and-next-and-state (&rest args)
  (interactive)
  (evil-multiedit-match-and-next)
  (evil-multiedit-state))

(map!
  :v "R" #'evil-multiedit-toggle-or-restrict-region
  (:leader
    "se" #'evil-multiedit-match-and-next-and-state)
  (:map evil-multiedit-state-map
    "C-n" #'evil-multiedit-next
    "C-p" #'evil-multiedit-prev
    "C-j" #'evil-multiedit-match-and-next
    "C-k" #'evil-multiedit-match-and-prev
    "F" #'iedit-restrict-function
    "S" #'evil-multiedit--substitute
    )
  )
