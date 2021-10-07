;;; package_configuration/embark.el -*- lexical-binding: t; -*-

(defun embark-guake (file)
  (interactive "GDirectory: ")
  (guake-open (file-name-directory
		(expand-file-name
		  (substitute-in-file-name file)))))

(map! :map embark-file-map
  "g" #'embark-guake)

(map! :map embark-region-map
	"f" #'consult-find)
