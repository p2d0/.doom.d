;;; ~/.doom.d/treemacs-config.el -*- lexical-binding: t; -*-


(defun treemacs-visit-node-in-guake ()
  "Open file in guake"
  (interactive)
  ;; code adapted from ranger.el
  (-if-let (path (treemacs--prop-at-point :path))
      (let ((process-connection-type nil))
				(message path)
				(start-process "" nil "guake" "--show" "-n"
											 (concat "--rename-tab=" (file-name-directory path))
											 (concat "--execute-command=cd '" (file-name-directory path) "'")  )
				)
    (_ (treemacs-pulse-on-failure "Don't know how to open files on %s."
         (propertize (symbol-name system-type) 'face 'font-lock-string-face)))
    (treemacs-pulse-on-failure "Nothing to open here.")))

(map!
 :map treemacs-mode-map
 "og" #'treemacs-visit-node-in-guake)
