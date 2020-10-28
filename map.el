;;; ~/.doom.d/map.el -*- lexical-binding: t; -*-

(map! :leader "/" #'+default/search-project)

(map!
 :leader
 "ap" #'list-processes)

(map!
  :leader
  "pR" #'projectile-replace)

(map!
  :map origami-mode-map
  :n "<backtab>" #'origami-toggle-all-nodes)

(map!
  :map origami-mode-map
  :n "<tab>" #'origami-toggle-node)

(map!
 :map emacs-lisp-mode-map
 :localleader
 :desc "Test"
 "t" #'ert)

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

(map! :v "s" #'evil-surround-region)

(defun toggle-fixed (&optional args)
  (interactive)
  (if window-size-fixed
      (setq window-size-fixed nil)
      (setq window-size-fixed 'width)))

(map! :leader
     :desc "Toggle fixed"
     "tf" #'toggle-fixed)
