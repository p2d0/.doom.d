;;; ~/.doom.d/map.el -*- lexical-binding: t; -*-




(map! "M-p" #'counsel-yank-pop)

(map! :leader "0" #'treemacs-select-window)


(map! :leader
			"/" #'+default/search-project)

(map!
 :leader
 "ap" #'list-processes)

(map!
 :leader
 :desc "Switch to previous buffer" "TAB" #'evil-switch-to-windows-last-buffer
 "`" nil)

(map! :v "s" #'evil-surround-region)


(defun toggle-fixed (&rest args)
  (interactive)
  (if window-size-fixed
      (setq window-size-fixed nil)
    (setq window-size-fixed 'width)))

(map! :leader
     :desc "Toggle fixed"
     "tf" #'toggle-fixed)

(defun set-window-width-60-fixed ()
  (interactive)
  (setq window-size-fixed nil)
  (evil-window-set-width 60)
  (setq window-size-fixed 'width)
  (visual-line-mode))

(defun set-window-width-50-fixed ()
  (interactive)
  (setq window-size-fixed nil)
  (evil-window-set-width 50)
  (setq window-size-fixed 'width)
  (visual-line-mode))

(defun set-window-height-10-fixed ()
  (interactive)
  (evil-window-set-height 10))

(defun set-window-height-5-fixed ()
  (interactive)
  (evil-window-set-height 5))

(after! winum
  (map! :leader
        :desc "Make window width 60 and fixed"
        "w6" #'set-window-width-60-fixed)

  (map! :leader
        :desc "Make window width 50 and fixed"
        "w5" #'set-window-width-50-fixed)

  (map! :leader
        :desc "Make window height 10 and fixed"
        "w1" #'set-window-height-10-fixed)

(map! :leader
        :desc "Make window height 5 and fixed"
        "w0" #'set-window-height-5-fixed))
