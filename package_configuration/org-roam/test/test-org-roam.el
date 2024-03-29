;; -*- no-byte-compile: t; -*-
;;; package_configuration/org-roam/test/org-roam-test.el

(describe "Org roam export"
  (before-all
    (load-file "../org-roam.el")
    (load-file "../daily.el")
    (setq-local post-command-hook '())
    (remove-hook 'post-command-hook #'org-roam-buffer--redisplay-h)
    (set-buffer (find-file-noselect "~/Dropbox/org/roam/20210809144731-tdd_the_bad_parts_matt_parker.org")))

  (xit "Should get backlinks from org file"
    (let ((backlinks (org-roam-backlinks-get (org-roam-node-at-point))))
      (expect (seq-length backlinks) :to-be-greater-than 1)))

  (xit "Should insert backlinks"
    (roam-export/insert-backlinks)
    (let ((text (buffer-substring-no-properties (point-min) (point-max))))
      (expect  text :to-match "Backlinks")
      (expect  text :to-match "(Articles -> TDD: The Bad Parts — Matt Parker)"  )))

  (it "should return first shit under the last daily"
    (expect (get-text-under-first-heading) :to-match "** testo")
    (expect (get-last-daily-test-under-first-heading) :to-match "Creatine")
    )
  (describe "getting text headings"
    (it "should return text under heading with specific text"
      (expect (org-get-text-under "Overmocking") :to-match "** tata")
      )
    )
	(describe "getting completed todos from previous daily"
		(it "should return todo"
			(let ((unfinished (org-get-unfinished-under "TODOS")))
				(expect unfinished :to-match "NOT COMPLETED")
				(expect unfinished :not :to-match "testing"))
			))
	(describe "getting dailies"
		(it "should update dailies status to [ ]"
		  (expect (org-get-dailies-under "DAILIES") :to-match "\\[ \\] KEK")
			))
  (after-all
    (set-buffer-modified-p nil)
    (kill-buffer (current-buffer))))

(describe "org-roam-db-sync"
  (xit "should calculate contents-hash right"
    (let* ((first-file (cl-first (org-roam-list-files)))
						(contents-hash (org-roam-db--file-hash first-file))
						(db-files (org-roam-db--get-current-files))
						(db-hash (gethash first-file db-files))
						)
      (expect first-file :to-match "/home/andrew/Dropbox/org/roam/20210808103958-sleep.org")
      ;; (prin1 db-files)
      ;; (prin1 db-files)
      ;; (expect (gethash first-file db-files) :to-equal "")
      (expect contents-hash :to-equal db-hash)
      )
    ))
