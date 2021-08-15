;;; package_configuration/org-roam.el -*- lexical-binding: t; -*-

(setq org-roam-graph-viewer "brave")
(setq org-roam-graph-executable "neato")

(defun roam-export--concat-outline (outline)
  (--reduce (concat acc " -> " it) outline))

(defun roam-export--insert-backlink (backlink)
  (let* ((source (org-roam-backlink-source-node backlink))
	  (text (concat "[[id:" (org-roam-node-id source) "][" (org-roam-node-title source) "]]"))
	  (outline (roam-export--concat-outline (plist-get (org-roam-backlink-properties backlink) :outline)))
	  )
    (insert text)
    (insert " (" outline ")\n\n")
    ))

(defun roam-export/insert-backlinks (&optional backend)
  (if (org-roam-buffer-p)
    (let ((backlinks (org-roam-backlinks-get (org-roam-node-at-point))))
      (goto-char (point-max))
      (insert (concat "\n* Backlinks\n"))
      (seq-each 'roam-export--insert-backlink backlinks)
      ) )
  )
(add-hook 'org-export-before-processing-hook #'roam-export/insert-backlinks)

(require 'org-id)

(defun publish-dir-org ()
  "Publish all org files in a directory"
  (interactive)
  (setq org-hugo-base-dir "~/.dump")
  (setq org-hugo-section "braindump")
  (setq org-export-with-broken-links t)
  (dolist (file (file-expand-wildcards "*.org"))
    (with-current-buffer
      (find-file-noselect file)
      (org-hugo-export-to-md)
      (message file))))

;; Export
