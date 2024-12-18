;;; package_configuration/org-roam.el -*- lexical-binding: t; -*-

(defun display-org-roam-buffer ()
  (when (and (org-roam-buffer-p) (not (org-roam-dailies--daily-note-p)) (memq (org-roam-buffer--visibility) '(exists none)))
    (display-buffer (get-buffer-create org-roam-buffer))
    (org-roam-buffer-persistent-redisplay)))

(after! org-roam
  (setq org-roam-directory (expand-file-name "~/Dropbox/org/roam/"))
  (setq org-roam-node-default-sort 'file-atime)
	(add-hook! 'org-mode-hook #'display-org-roam-buffer)
  ;; (setq org-roam-buffer-postrender-functions '(display-org-roam-buffer))

  ;; (setq org-roam-db-location "~/Dropbox/org/roam/roam.db")
  ;; (advice-remove 'org-roam-db-query #'+org-roam-try-init-db-a)
  ;; (setq org-roam-graph-viewer "brave")
  ;; (setq org-roam-graph-executable "neato")

  ;; (require 'ox-hugo)

  ;; (defun roam-export--concat-outline (outline)
  ;;   (--reduce (concat acc " -> " it) outline))

  ;; (defun roam-export--insert-backlink (backlink)
  ;;   (let* ((source (org-roam-backlink-source-node backlink))
  ;; 					(text (concat "[[id:" (org-roam-node-id source) "][" (org-roam-node-title source) "]]"))
  ;; 					(outline (roam-export--concat-outline (plist-get (org-roam-backlink-properties backlink) :outline)))
  ;; 					)
  ;;     (insert text)
  ;;     (insert " (" outline ")\n\n")
  ;;     ))

  ;; (defun roam-export/insert-backlinks (&optional backend)
  ;;   (if (org-roam-buffer-p)
  ;; 		(let ((backlinks (org-roam-backlinks-get (org-roam-node-at-point))))
  ;; 			(goto-char (point-max))
  ;; 			(insert (concat "\n* Backlinks\n"))
  ;; 			(seq-each 'roam-export--insert-backlink backlinks)
  ;; 			) )
  ;;   )

  ;; ;; (add-hook 'org-export-before-processing-hook #'roam-export/insert-backlinks)


  ;; (defun roam-export/get-tags (tag-list info)
  ;;   (if (org-roam-buffer-p)
  ;; 		(append tag-list (seq-map #'downcase (org-roam-node-tags (org-roam-node-at-point) )))))


  ;; (add-to-list 'org-hugo-tag-processing-functions 'roam-export/get-tags)

  ;; (setq org-hugo-auto-set-lastmod t)
  ;; (setq org-export-with-date t)
  ;; (setq org-export-with-broken-links t)

  ;; (defun roam-export/export (&rest args)
  ;;   (when (org-roam-file-p)
  ;;     (org-hugo-export-to-md)))

  ;; (add-hook 'org-mode-hook
  ;; 	(lambda ()
  ;; 		(add-hook 'after-save-hook #'roam-export/export nil t)))


  ;; (defun publish-dir-org ()
  ;;   "Publish all org files in a directory"
  ;;   (interactive)
  ;;   (dolist (file (file-expand-wildcards "*.org"))
  ;;     (with-current-buffer
  ;; 			(find-file-noselect file)
  ;; 			(org-hugo-export-to-md))))

  (setq daily-template "~/Dropbox/org/daily.org")
  (setq org-roam-dailies-capture-templates `(("j" "journal" plain "%?\n"
					       :if-new (file+head "%<%Y-%m-%d>.org" ,(format "%%[%s]" daily-template))
					       :immediate-finish t
					       :unnarrowed t
					       )))
  (setq org-roam-capture-templates '(("d" "default" plain "%?"
				       :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
						 "#+title: ${title}\n")
				       :immediate-finish t
				       :unnarrowed t)))

  (push '("y" "youtube" plain "%?"
	   :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
		     "#+title: ${title}\n#+filetags: :Youtube:\n[[%^{Please insert the youtube link}][Youtube link]]\n* ?\n* 🤖 AI Summary")
	   :unnarrowed t
	   :immediate-finish t
	   ) org-roam-capture-templates)
  (push '("a" "article" plain "%?"
	   :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
		     "#+title: ${title}\n#+filetags: :Article:\n[[%^{Please insert the article link}][Article link]]")
	   :unnarrowed t
	   :immediate-finish t
	   ) org-roam-capture-templates)

  (push '("p" "private" plain "%?"
	   :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}_private.org"
		     "#+title: ${title}\n")
	   :unnarrowed t
	   ) org-roam-capture-templates)

  (push '("b" "book" plain "* 🚀 The Book in 3 Sentences\n1. \n\n* ☘ How the Book Changed Me\n+ \n\n* ✍ My Top 3 Quotes\n\n* 📒 Summary + Notes\n%?"
	   :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
		     "#+title: ${title}\n#+filetags: :Book:\n")
	   :unnarrowed t
	   :immediate-finish t
	   ) org-roam-capture-templates))

;; Export
;;
;; :PROPERTIES:
;; :ID:       84ae1004-f452-4926-b260-154344e379ef
;; :END:
;; #+title: 2023-08-03
;; * Currently trying: Eliminating eggs ([[id:c6ccc52d-1591-4f15-b6b3-636117c7e399][Trigger foods]])
;; * Table
;; |  Time |        | Blood pressure | HeartRate |
;; |-------+--------+----------------+-----------|
;; | 10:00 | Sleepy | 114/71         |        94 |
;; |       |        |                |           |
;; * Notes
