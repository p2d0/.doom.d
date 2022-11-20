;;; editors/.doom.d/package_configuration/skeletor/skeletor.el -*- lexical-binding: t; -*-

(after! skeletor
	(setq skeletor-completing-read-function #'completing-read-default)
	(setq skeletor-user-directory "~/.doom.d/skeletor-templates")
	(skeletor-define-template "test"
		:title "Test"
		:no-license? t
		)

	)
;; TODO mini templates without specifiying folder name
;; TODO hygen

;; (defun skeletor-create-mini-at (dir skeleton)
;;   "Interactively create a new project with Skeletor.

;; DIR is destination directory, which must exist.

;; SKELETON is a SkeletorProjectType."
;;   (interactive (list (read-directory-name "Create at: " nil nil t)
;;                      (skeletor--read-project-type)))
;;   ;; Dynamically rebind the project directory.
;;   (let ((skeletor-project-directory dir))
;;     (skeletor-create-project skeleton)))
