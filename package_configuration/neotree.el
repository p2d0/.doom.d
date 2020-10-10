(defun neotree-visit-node-in-guake (fullpath &optional arg)
  (start-process "" nil "guake" "--show" "-n"
                 (concat "--rename-tab=" fullpath)
                 (concat "--execute-command=cd '" fullpath "'")))

(defun neotree-visit-folder-in-guake (fullpath &optional arg)
  (neotree-visit-node-in-guake fullpath arg))

(defun neotree-visit-file-in-guake (fullpath &optional arg)
  (neotree-visit-node-in-guake (file-name-directory fullpath) arg))

(defun neotree-open-guake (&optional arg)
  (interactive)
  (neo-buffer--execute arg 'neotree-visit-file-in-guake 'neotree-visit-folder-in-guake))

(map!
 :map neotree-mode-map
 :n
 "og" #'neotree-open-guake)
