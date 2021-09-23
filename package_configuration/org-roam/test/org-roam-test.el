;; -*- no-byte-compile: t; -*-
;;; package_configuration/org-roam/test/org-roam-test.el

(describe "Org roam export"
  (before-all
    (load-file "../org-roam.el")
    (setq-local post-command-hook '())
    (remove-hook 'post-command-hook #'org-roam-buffer--redisplay-h)
    (set-buffer (find-file-noselect "~/Dropbox/org/roam/20210809144731-tdd_the_bad_parts_matt_parker.org")))

  (it "Should get backlinks from org file"
    (let ((backlinks (org-roam-backlinks-get (org-roam-node-at-point))))
      (expect (seq-length backlinks) :to-be-greater-than 1)))

  (it "Should insert backlinks"
    (roam-export/insert-backlinks)
    (let ((text (buffer-substring-no-properties (point-min) (point-max))))
      (expect  text :to-match "Backlinks")
      (expect  text :to-match "(Articles -> TDD: The Bad Parts — Matt Parker)"  )))

  (after-all
    (set-buffer-modified-p nil)
    (kill-buffer (current-buffer))))
