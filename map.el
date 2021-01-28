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

(map! :v "s" #'evil-surround-region)

(defun toggle-fixed (&optional args)
  (interactive)
  (if window-size-fixed
      (setq window-size-fixed nil)
      (setq window-size-fixed 'width)))

(map! :leader
     :desc "Toggle fixed"
     "tf" #'toggle-fixed)
