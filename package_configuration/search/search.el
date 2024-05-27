;;; nixos/editors/.doom.d/package_configuration/search/search.el -*- lexical-binding: t; -*-

(defun +default/find-file-under ()
	(interactive)
	(+vertico/consult-fd-or-find (read-directory-name "Search directory: "))
	;; (doom-project-find-file (read-directory-name "Search directory: "))
	)

(map! :leader "fE" #'+default/find-file-under)
