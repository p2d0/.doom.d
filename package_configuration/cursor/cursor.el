;;; nixos/editors/.doom.d/package_configuration/cursor/cursor.el -*- lexical-binding: t; -*-

(defun cursor-open (path)
	(start-process "" "*cursor*" "/run/current-system/sw/bin/cursor" ;; (projectile-project-root)
		path))

(defun cursor-open-current-file ()
  (interactive)
  (let ((path (or buffer-file-name default-directory)))
    (cursor-open path)))

(defun cursor-open-project-folder ()
  (interactive)
  (let ((path (or buffer-file-name default-directory)))
    (cursor-open-folder path)))

(defun cursor-open-folder (path)
	(start-process "" "*cursor*" "/run/current-system/sw/bin/cursor" (projectile-project-root) "-g"
		path))

(map!
  :leader
  "fc" #'cursor-open-current-file)
