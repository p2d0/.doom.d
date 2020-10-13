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

(defun neotree-find-no-focus (&optional path default-path)
  "Quick select node which specified PATH in NeoTree.
If path is nil and no buffer file name, then use DEFAULT-PATH,"
  (interactive)
  (let* ((ndefault-path (if default-path default-path
                          (neo-path--get-working-dir)))
         (npath (if path path
                  (or (buffer-file-name) ndefault-path))))
    (neo-global--open-and-find npath)
    (when neo-auto-indent-point
      (neo-point-auto-indent))))

(defun +neotree/find-this-file-no-focus ()
  "Open the neotree window in the current project, and find the current file."
  (interactive)
  (let ((path buffer-file-name)
        (project-root (or (doom-project-root)
                          default-directory)))
    (require 'neotree)
    (cond ((and (neo-global--window-exists-p)
                (get-buffer-window neo-buffer-name t))
           (neotree-find-no-focus path project-root))
          ((not (and (neo-global--window-exists-p)
                     (equal (file-truename (neo-global--with-buffer neo-buffer--start-node))
                            (file-truename project-root))))
           (neotree-dir project-root)
           (neotree-find-no-focus path project-root))
          (t
           (neotree-find-no-focus path project-root)))))


(defun neotree-on-buffer-change (frame)
  (let ((path (buffer-file-name)))
    (when path
      (+neotree/find-this-file-no-focus))))

(add-hook 'window-buffer-change-functions #'neotree-on-buffer-change)
