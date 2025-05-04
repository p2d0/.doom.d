;;; package_configuration/org-roam.el -*- lexical-binding: t; -*-

(defun display-org-roam-buffer ()
  (when (and (org-roam-buffer-p) (not (org-roam-dailies--daily-note-p)) (memq (org-roam-buffer--visibility) '(exists none)))
    (display-buffer (get-buffer-create org-roam-buffer))
    (org-roam-buffer-persistent-redisplay)))

(defun org-daily-setup-hook ()
	(add-hook! 'before-save-hook :local #'display-org-roam-buffer #'update-total-story-points #'update-total-minutes))

(after! org-roam
  (setq org-roam-directory (expand-file-name "~/Dropbox/org/roam/"))
  (setq org-roam-node-default-sort 'file-mtime)
	(add-hook 'org-roam-find-file-hook #'org-daily-setup-hook)

	;; (add-hook! 'save-buffer)
	;; (add-hook! 'after-save-hook )

	;; Override to not get backlinks from dailies
	(defun org-roam-backlinks-remove-if-daily (backlinks)
		(cl-remove-if (pcase-lambda (`(,source-id ,dest-id ,pos ,properties))
										(string-match "daily" (org-roam-node-file (org-roam-node-from-id  source-id))))
      backlinks))

	(cl-defun org-roam-backlinks-get (node &key unique)
		"Return the backlinks for NODE.

 When UNIQUE is nil, show all positions where references are found.
 When UNIQUE is t, limit to unique sources."
		(let* ((sql (if unique
                  [:select :distinct [source dest pos properties]
										:from links
										:where (= dest $s1)
										:and (= type "id")
										:group :by source
										:having (funcall min pos)]
									[:select [source dest pos properties]
										:from links
										:where (= dest $s1)
										:and (= type "id")]))
						(backlinks (org-roam-backlinks-remove-if-daily (org-roam-db-query sql (org-roam-node-id node)))))
			(cl-loop for backlink in  backlinks
        collect (pcase-let ((`(,source-id ,dest-id ,pos ,properties) backlink))
                  (org-roam-populate
                    (org-roam-backlink-create
                      :source-node (org-roam-node-create :id source-id)
                      :target-node (org-roam-node-create :id dest-id)
                      :point pos
                      :properties properties))))))

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

  (push '("k" "Dr.K" plain "%?"
					 :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
										 "#+title: ${title}\n#+filetags: :Youtube:DR.K:\n[[%^{Please insert the youtube link}][Youtube link]]\n* ?\n* 🤖 AI Summary")
					 :unnarrowed t
					 :immediate-finish t
					 ) org-roam-capture-templates)

  (push '("h" "Huberman" plain "%?"
					 :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
										 "#+title: ${title}\n#+filetags: :Youtube:Huberman:\n[[%^{Please insert the youtube link}][Youtube link]]\n* ?\n* 🤖 AI Summary")
					 :unnarrowed t
					 :immediate-finish t
					 ) org-roam-capture-templates)
  (push '("k" "Dr.K" plain "%?"
					 :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
										 "#+title: ${title}\n#+filetags: :Youtube:DR.K:\n[[%^{Please insert the youtube link}][Youtube link]]\n* ?\n* 🤖 AI Summary")
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
