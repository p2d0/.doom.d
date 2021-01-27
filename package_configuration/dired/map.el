;;; package_configuration/dired/map.el -*- lexical-binding: t; -*-

(defun get-string-after-: (str)
  (string-trim (car (last (split-string str ":") ) ) ))

(defun fd-ivy-dired-project ()
  (interactive)
  (fd-dired (doom-project-root) (ivy--input)))

(defun fd-ivy (&optional args)
  (interactive)
  (ivy-exit-with-action #'fd-ivy-dired-project))

(defun ivy-test ()
  (interactive)
  (fd-ivy-dired-project)
  (ivy-exit-with-action (lambda (_)
			  (pop-to-buffer "*Fd*")
			  ))
  )

(defun fd-dired-project (input)
  (interactive (list (read-string "File name: ")))
  (fd-dired (doom-project-root) input))

(map!
  :leader
  "pd" #'fd-dired-project)

(map!
  :map ivy-mode-map
  "C-d" #'ivy-test)
