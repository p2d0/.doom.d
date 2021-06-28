;;; ~/.doom.d/map.el -*- lexical-binding: t; -*-


(map! :leader "/" #'+default/search-project)

;; Expand variants
;; (global-set-key (kbd "M-/") 'hippie-expand)
;; (global-set-key (kbd "M-/") 'evil-complete-next)

;; Put in insert mode
;; (global-set-key (kbd "C-p") 'evil-paste-after)

;; (map! :i "C-p" #'evil-paste-after)

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
  "C-c C-c" #'string-inflection-lower-camelcase
  "C-c C-l" #'string-inflection-lisp
  "C-c C-a" #'string-inflection-all-cycle)

(map!
 :leader
 :desc "Switch to previous buffer" "TAB" #'evil-switch-to-windows-last-buffer
 "`" nil)

(map!
 :desc "Run Hygen..."
  (:leader
    (:prefix "ph"
      "h" #'hygen/run-project
      "o" #'hygen/run-other-project)))

(map!
  :map treemacs-mode-map
  (:localleader
    "a" #'treemacs-run-hygen-on-directory))

(map!
 :desc "Run Hygen Global..."
  (:leader
    (:prefix "gh"
      "h" #'hygen/run-global
      "o" #'hygen/run-global-in-folder)))

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

