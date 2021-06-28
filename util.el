;;; util.el -*- lexical-binding: t; -*-

(defun get-directory (path)
  (if (f-dir? path)
    path
    (file-name-directory
      path) ))
