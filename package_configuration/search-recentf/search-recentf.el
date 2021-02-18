;;; package_configuration/search-recentf/search-recentf.el -*- lexical-binding: t; -*-

(defvar config-recentf '())

(defun +config/push-to-recentf (folder)
  (push folder config-recentf))

(defun +config/search-recentf ()
  (interactive)
  (ivy-read "Search recent folder: " config-recentf
    :action (lambda (f)
	      (let ((default-directory f))
		(call-interactively
		#'+ivy/project-search-from-cwd)))
    :require-match t
    :caller 'counsel-recentf))

(defun +default/search-cwd (&optional arg)
  "Conduct a text search in files under the current folder.
If prefix ARG is set, prompt for a directory to search from."
  (interactive "P")
  (let ((default-directory
          (if arg
              (read-directory-name "Search directory: ")
            default-directory)))
    (+config/push-to-recentf default-directory)
    (call-interactively
     (cond ((featurep! :completion ivy)  #'+ivy/project-search-from-cwd)
           ((featurep! :completion helm) #'+helm/project-search-from-cwd)
           (#'rgrep)))))

(map! :leader
  "sr" #'+config/search-recentf)
