;;; package_configuration/org.el -*- lexical-binding: t; -*-


(setq org-directory "~/Dropbox/org/")
(setq org-roam-directory "~/Dropbox/org/roam/")
(set-popup-rule! "^\\*Org Agenda" :size 16)

(after! org
	(if (file-directory-p org-directory)
		(setq org-agenda-files (directory-files-recursively org-directory "\\.org$")))

	;; (setq org-startup-folded nil)
	;; (setq org-hide-block-startup t)

	(push 'org-habit org-modules)

	;; (setq org-agenda-window-setup 'reorganize-frame)
	(setq org-startup-with-inline-images t)
	(setq org-export-preserve-breaks t)

	(setq org-image-actual-width nil);; Modified version of contrib/lisp/org-man.el; see
	;; (http://orgmode.org/manual/Adding-hyperlink-types.html#Adding-hyperlink-types)
	;; (setq org-image-actual-width 400)

	(defun org-info-store-link ()
		"Store a link to an info page."
		(interactive)
		(when (memq major-mode '(Info-mode))
			;; This is a info page, we do make this link
			(let* ((page (org-info-get-page-name))
							(link (concat "info:" page))
							(description (format "Infopage for %s" page)))
				(org-store-link-props
					:type "info"
					:link link
					:description description))))
	(setq org-hide-emphasis-markers t)

	(setq-default prettify-symbols-alist '(("#+begin_src" . "λ")
																					("#+end_src" . "λ")
																					("#+attr_html: :width" . "⭤")
																					;; ("#+title:" . "➹")
																					("#+filetags:" . "₮")
																					;; ("->" . "➔")
																					))

	(setq org-todo-keywords '((sequence  "TODO(t)" "UNFINISHED(u)" "PROJ(p)" "LOOP(r)" "STRT(s)" "WAIT(w)" "HOLD(h)" "IDEA(i)" "|" "DONE(d)" "KILL(k)")
														 (sequence "QUESTIONABLE(q)")
														 (sequence "[ ](T)" "[-](S)" "[?](W)" "|" "[X](D)")
														 (sequence "|" "OKAY(o)" "YES(y)" "NO(n)")) )

	(setq org-todo-keyword-faces '(("[-]" . +org-todo-active)
																	("UNFINISHED(u)" . +org-todo-active)
																	("QUESTIONABLE" . +org-todo-project)
																	("STRT" . +org-todo-active)
																	("[?]" . +org-todo-onhold)
																	("WAIT" . +org-todo-onhold)
																	("HOLD" . +org-todo-onhold)
																	("PROJ" . +org-todo-project)
																	("NO" . +org-todo-cancel)
																	("KILL" . +org-todo-cancel)))

	(setq  org-agenda-custom-commands '(("n" "Agenda only todo.org" agenda "" ((org-agenda-files '("~/Dropbox/org/todo.org")))) ))

	(add-hook 'org-mode-hook 'prettify-symbols-mode))
