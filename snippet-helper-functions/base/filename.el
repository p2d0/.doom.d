;;; snippet-helper-functions/filename.el -*- lexical-binding: t; -*-

(defun +yas/filename ()
  (file-name-sans-extension (buffer-name)))
