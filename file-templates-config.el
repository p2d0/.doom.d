(defun +file-template-apply ()
	"apply file-template to current buffer from file-templates list"
	(when-let (rule (cl-find-if #'+file-template-p +file-templates-alist))
		(apply #'+file-templates--expand rule)))


(defun open-buffer-and-insert-template (path)
	(when (not (f-dir? path))
		(select-window (next-window (selected-window)))
		(find-file path)
		(+file-template-apply)))


(add-hook 'treemacs-create-file-functions #'open-buffer-and-insert-template t)

(set-file-template!
  "\\(test\\|spec\\)\\.py"   :trigger "__test.py"    :mode 'python-mode)

(add-hook 'python-mode-hook
   '(lambda () (set (make-local-variable 'yas-indent-line) 'fixed)))
