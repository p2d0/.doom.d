;;; ~/.doom.d/map.el -*- lexical-binding: t; -*-


(map! :leader "/" #'+default/search-project)

(map!
 :leader
 "ap" #'list-processes)

(map!
  :leader
  "pR" #'projectile-replace)

(map!
 :map emacs-lisp-mode-map
 :localleader
 :desc "Test"
 "t" #'test-simple-run)

(map!
 :leader
 :desc "Switch to previous buffer" "TAB" #'evil-switch-to-windows-last-buffer
 "`" nil)

(map!
 :map evil-normal-state-map
 "gs" #'avy-goto-char)

(map!
 :map evil-visual-state-map
 "gs" #'avy-goto-char)
(map!
  :leader
  :desc "Git time machine"
  "gt" #'git-timemachine
  )

(map! :v "s" #'evil-surround-region)
