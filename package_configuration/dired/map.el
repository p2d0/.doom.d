;;; package_configuration/dired/map.el -*- lexical-binding: t; -*-

(defun get-string-after-: (str)
  (string-trim (car (last (split-string str ":") ) ) ))

(defun fd-ivy-dired-project ()
  (fd-dired (doom-project-root) (seq-map (lambda (x) (kill-new x))
				  (completion-all-sorted-completions) )))

(defun ivy-dired ()
  (interactive)
  (fd-ivy-dired-project)
  (ivy-exit-with-action (lambda (_)
			  (pop-to-buffer
			    "*Fd*"))))

(map!
  :leader
  "pd" #'fd-dired-project)

(map!
  :map ivy-mode-map
  "C-d" #'ivy-dired)
