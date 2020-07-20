;;; ~/.doom.d/overrides/treemacs.el -*- lexical-binding: t; -*-

;; Treemacs hook position override
(after! treemacs
  (defun treemacs--create-file/dir (is-file?)
    "Interactively create either a file or directory, depending on IS-FILE.
IS-FILE?: Bool"
    (interactive)
    (let* ((curr-path (--if-let (treemacs-current-button)
                          (treemacs--nearest-path it)
                        (f-expand "~")))
           (path-to-create (read-file-name
                            (if is-file? "Create File: " "Create Directory: ")
                            (treemacs--add-trailing-slash
                             (if (f-dir? curr-path)
                                 curr-path
                               (f-dirname curr-path))))))
      (treemacs-block
       (treemacs-error-return-if (file-exists-p path-to-create)
         "%s already exists." (propertize path-to-create 'face 'font-lock-string-face))
       (treemacs--without-filewatch
        (if is-file?
            (-let [dir (f-dirname path-to-create)]
              (unless (f-exists? dir)
                (make-directory dir t))
              (f-touch path-to-create))
          (make-directory path-to-create t))
        (-when-let (project (treemacs--find-project-for-path path-to-create))
          (-when-let* ((created-under (treemacs--parent path-to-create))
                       (created-under-pos (treemacs-find-visible-node created-under)))
            ;; update only the part that changed to keep things smooth
            ;; for files that's just their parent, for directories we have to take
            ;; flattening into account
            (if (and (treemacs-button-get created-under-pos :parent)
                     (or (treemacs-button-get created-under-pos :collapsed)
                         ;; count includes "." "..", so it'll be flattened
                         (= 3 (length (directory-files created-under)))))
                (treemacs-do-update-node (-> created-under-pos
                                             (treemacs-button-get :parent)
                                             (treemacs-button-get :path)))
              (treemacs-do-update-node created-under)))
          (treemacs-goto-file-node (treemacs--canonical-path path-to-create) project)
          (recenter))
        (run-hook-with-args 'treemacs-create-file-functions path-to-create))
       (treemacs-pulse-on-success
           "Created %s." (propertize path-to-create 'face 'font-lock-string-face))))) )
