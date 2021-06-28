;;; ~/.doom.d/treemacs-config.el -*- lexical-binding: t; -*-


(defun treemacs-visit-node-in-guake ()
  "Open file in guake"
  (interactive)
  ;; code adapted from ranger.el
  (-if-let (path (treemacs--prop-at-point :path))
    (let ((process-connection-type nil)
	   (path (if (f-dir? path)
		   path
		   (file-name-directory
		     path) )))
      (message path)
      (start-process "" nil "guake" "--show" "-n"
	(concat "--rename-tab=" path)
	(concat "--execute-command=cd '" path "'")  )
      )
    (_ (treemacs-pulse-on-failure "Don't know how to open files on %s."
	 (propertize (symbol-name system-type) 'face 'font-lock-string-face)))
    (treemacs-pulse-on-failure "Nothing to open here.")))

(map!
  :map treemacs-mode-map
  "og" #'treemacs-visit-node-in-guake)



(after! treemacs
  (treemacs-git-mode -1)
  (map!
    :map treemacs-mode-map
    :localleader
    "o" #'treemacs-display-current-project-exclusively)

  )
(setq treemacs-read-string-input 'from-minibuffer)
