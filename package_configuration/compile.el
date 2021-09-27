;;; package_configuration/compile.el -*- lexical-binding: t; -*-

(after! js2-mode
	(defconst jest-error-match "at.+?(\\(.+?\\):\\([0-9]+\\):\\([0-9]+\\)")

	(eval-after-load 'compile
		(lambda ()
			(dolist
				(regexp
					`((jest-error
							,jest-error-match
							1 2 3
							)))
				(add-to-list 'compilation-error-regexp-alist-alist regexp)
				(add-to-list 'compilation-error-regexp-alist (car regexp))))))
