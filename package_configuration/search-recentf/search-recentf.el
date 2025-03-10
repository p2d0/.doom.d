;;; package_configuration/search-recentf/search-recentf.el -*- lexical-binding: t; -*-

;; (defvar config-recentf '())

;; (defun +config/push-to-recentf (folder)
;;   (if (not (member folder config-recentf) )
;;     (push folder config-recentf)))

;; (defun +config/search-recentf ()
;;   (interactive)
;;   (ivy-read "Search recent folder: " config-recentf
;;     :action (lambda (f)
;; 	      (let ((default-directory f))
;; 		(call-interactively
;; 		#'+ivy/project-search-from-cwd)))
;;     :require-match t
;;     :caller 'counsel-recentf))


;; (defun +config/search-other-cwd (&optional arg)
;;   "Conduct a text search in files under the current folder.
;; If prefix ARG is set, prompt for a directory to search from."
;;   (interactive "P")
;;   (let ((default-directory
;; 	    (read-directory-name "Search directory: ")))
;;     (+config/push-to-recentf default-directory)
;;     (call-interactively
;;       (cond ((featurep! :completion ivy)  #'+ivy/project-search-from-cwd)
;; 	((featurep! :completion helm) #'+helm/project-search-from-cwd)
;; 	(#'rgrep)))))

;; (defun +config/save-recentf ()
;;   (dump-vars-to-file 'config-recentf "./cache.el"))

;; (add-hook 'kill-emacs-hook #'+config/save-recentf t)

;; (map! :leader
;;   "sr" #'+config/search-recentf)

;; (map! :leader
;;   "sD" #'+config/search-other-cwd)

(defun recentf-save-only-if-main ()

	)

;; (after! recentf
;; 	(setq recentf-max-saved-items 5000)
;; 	(setq recentf-max-menu-items 1000)
;; 	;; (run-at-time 60 (* 5 15) 'recentf-save-list)
;; 	)

(use-package recentf
  :init
  (setq
    recentf-save-file "~/.cache/emacs/recentf"
    recentf-max-saved-items 10000
    recentf-max-menu-items 5000
    )
  (recentf-mode 1)
  (run-at-time nil (* 5 60) 'recentf-save-list)
  )
