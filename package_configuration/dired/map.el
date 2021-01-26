;;; package_configuration/dired/map.el -*- lexical-binding: t; -*-

(defun get-string-after-: (str)
  (string-trim (car (last (split-string str ":") ) ) ))


(defun fd-dired-project (input)
  (interactive (list (read-string "File name: ")))
  (fd-dired (doom-project-root) input))

(map!
  :leader
  "pd" #'fd-dired-project
  )
