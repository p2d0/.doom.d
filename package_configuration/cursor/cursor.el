;;; nixos/editors/.doom.d/package_configuration/cursor/cursor.el -*- lexical-binding: t; -*-

(defun cursor-open (path)
	(start-process "" nil "cursor" path ) )

(defun cursor-open-current-file ()
  (interactive)
  (let ((path (or buffer-file-name default-directory)))
    (cursor-open path)))

(map!
  :leader
  "fc" #'cursor-open-current-file)
