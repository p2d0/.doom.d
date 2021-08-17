;;; ~/.doom.d/treemacs-config.el -*- lexical-binding: t; -*-


(map!
  :map evil-treemacs-state-map
  "H" #'treemacs-root-up
  "L" #'treemacs-root-down
  )



(after! treemacs
  (treemacs-git-mode -1)
  (map!
    :map treemacs-mode-map
    "M-H" nil
    "M-L" nil
    :localleader
    "o" #'treemacs-display-current-project-exclusively)
  )
(setq treemacs-read-string-input 'from-minibuffer)
