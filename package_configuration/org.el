;;; package_configuration/org.el -*- lexical-binding: t; -*-


(setq org-directory "~/Dropbox/org/")

(if (file-directory-p org-directory)
  (setq org-agenda-files (directory-files-recursively org-directory "\\.org$")))

;; (setq org-startup-folded nil)
;; (setq org-hide-block-startup t)

(push 'org-habit org-modules)

(setq org-agenda-window-setup 'reorganize-frame)

;; (setq org-image-actual-width nil)
