;;; package_configuration/org-roam.el -*- lexical-binding: t; -*-

(defun org-hugo--tag-processing-fn-roam-tags(tag-list info)
  "Process org roam tags for org hugo"
  (if (org-roam--org-roam-file-p)
      (append tag-list (mapcar #'downcase (org-roam--extract-tags)))
    (mapcar #'downcase tag-list)
    ))

(add-to-list 'org-hugo-tag-processing-functions 'org-hugo--tag-processing-fn-roam-tags)

(defun org-hugo--org-roam-backlinks (backend)
  (when (equal backend 'hugo)
  (when (org-roam--org-roam-file-p)
    (end-of-buffer)
    (org-roam-buffer--insert-backlinks))))
(add-hook 'org-export-before-processing-hook #'org-hugo--org-roam-backlinks)

(defun my-org-hugo-org-roam-sync-all()
  ""
  (interactive)
  (dolist (fil (org-roam--list-files org-roam-directory))
    (with-current-buffer (find-file-noselect fil)
      (org-hugo-export-wim-to-md)
      (kill-buffer))))
