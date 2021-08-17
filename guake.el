;;; guake.el -*- lexical-binding: t; -*-

(defun guake-open (path)
  (start-process "" nil "guake" "--show" "-n"
    (concat "--rename-tab=" path)
    (concat "--execute-command=cd '" path "'")  ) )


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
      (guake-open path)
      )
    (_ (treemacs-pulse-on-failure "Don't know how to open files on %s."
	 (propertize (symbol-name system-type) 'face 'font-lock-string-face)))
    (treemacs-pulse-on-failure "Nothing to open here.")))

(defun guake-open-current-file ()
  (interactive)
  (let ((path (or buffer-file-name default-directory)))
    (guake-open
     (if arg
         (abbreviate-file-name path)
       (file-name-nondirectory path)))))

(map!
  :map treemacs-mode-map
  "og" #'treemacs-visit-node-in-guake
  )
