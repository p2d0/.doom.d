;;; nixos/editors/.doom.d/package_configuration/org-roam/org-daily.el -*- lexical-binding: t; -*-
;; -*- no-byte-compile: t; -*-
;; -*- lexical-binding: t; -*-
;;; package_configuration/org-roam/test/org-roam-test.el

(describe "Org roam export"
	(let*
		((buf (find-file-noselect "~/Dropbox/org/roam/20210809144731-tdd_the_bad_parts_matt_parker.org")))

		(before-all
			(load-file "../org-roam.el")
			(load-file "../daily.el")
			(setq-local post-command-hook '())
			(remove-hook 'post-command-hook #'org-roam-buffer--redisplay-h)
			(set-buffer buf))

		(xit "Should get backlinks from org file"
			(let ((backlinks (org-roam-backlinks-get (org-roam-node-at-point))))
				(expect (seq-length backlinks) :to-be-greater-than 1)))

		(xit "Should insert backlinks"
			(roam-export/insert-backlinks)
			(let ((text (buffer-substring-no-properties (point-min) (point-max))))
				(expect  text :to-match "Backlinks")
				(expect  text :to-match "(Articles -> TDD: The Bad Parts — Matt Parker)"  )))

		(xit "should return first shit under the last daily"
			(expect (get-text-under-first-heading) :to-match "** testo")
			(expect (get-last-daily-test-under-first-heading) :to-match "Creatine")
			)

		(describe "getting text headings"
			(it "should return text under heading with specific text"
				(expect (org-get-text-under "Overmocking") :to-match "** tata")
				)
			)

		(describe "get-total-minutes-done"
			(it "should return minutes done tasks"
				(with-current-buffer buf
					(expect (get-total-minutes-done) :to-equal 70)
					)
				)
			)

		(xdescribe "get-total-points-done"
			(it "should return minutes done tasks"
				(with-current-buffer buf
					(expect (get-total-story-points-done) :to-equal 70)
					)
				)
			)


		(xdescribe "getting completed todos from previous daily"
			(it "should return todo"
				(let ((unfinished (org-get-unfinished-under "TODOS")))
					(expect unfinished :to-match "NOT COMPLETED")
					(expect unfinished :not :to-match "testing"))
				))

		(xdescribe "getting dailies"
			(it "should update dailies status to [ ]"
				(with-current-buffer buf
					(expect (org-get-dailies-under "DAILIES") :to-match "\\[ \\] KEK")
					)
				))
		(describe "checkmark dailies"
			(it "should return properly"
				(with-current-buffer (find-file-noselect "~/Dropbox/org/test.org")
					(expect (org-get-dailies-under "testing") :to-match "\\[ \\] Brother")
					)
				)
			)

		(after-all
			(set-buffer-modified-p nil)
			;; (kill-buffer (current-buffer))
			)))

(xdescribe "org-roam-db-sync"
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
