;;; package_configuration/org.el -*- lexical-binding: t; -*-


(setq org-directory "~/Dropbox/org/")
(set-popup-rule! "^\\*Org Agenda" :size 16)

(use-package org-tidy
  :ensure t
  :hook
  (org-mode . org-tidy-mode))

(defun toggle-org-zen ()
	(require 'writeroom-mode)
	(if (member #'writeroom-mode org-mode-hook)
		(remove-hook! 'org-mode-hook #'writeroom-mode)
		(add-hook! 'org-mode-hook #'writeroom-mode))
	(writeroom--disable)
	(revert-buffer))

(defun buffer-name-contains-date ()
  "Check if the current buffer name contains a date in the format YYYY-MM-DD."
  (string-match-p "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}.org" (buffer-name)))

(defun zen-mode-enable ()
	(when (and (> (frame-width) 200) (not (buffer-name-contains-date)))
		(writeroom-mode)))

(after! org
	(require 'ox-publish)
	(require 'writeroom-mode)
	(setq org-enforce-todo-dependencies nil)

	(add-hook! 'org-mode-hook #'zen-mode-enable)
	;; (add-hook 'org-mode-hook #'xenops-mode)
	;; (setq xenops-math-image-scale-factor 1.7
	;; 	xenops-reveal-on-entry t)
	(setq org-publish-project-alist
		'(
			 ("org-notes"
				 :base-directory "~/Dropbox/org/"
				 :base-extension "org"
				 :publishing-directory "/ssh:android@192.168.31.12:/home/android/igor/"
				 :publishing-function org-html-publish-to-html
				 :headline-levels 4
				 :auto-preamble t
				 :exclude ".*"
				 :include ["igor_update.org"]
				 )
			 ("org-static"
				 :base-directory "~/Dropbox/org/.attach/"
				 :base-extension "css\\|js\\|png\\|jpg"
				 :publishing-directory "/ssh:android@192.168.31.12:/home/android/igor/.attach/"
				 :recursive t
				 :publishing-function org-publish-attachment
				 )
			 ("Pepegas" :components ("org-notes" "org-static"))
			 ;; ... add all the components here (see below)...

			 ))

	;; (if (file-directory-p org-directory)
	;; 	(setq org-agenda-files (directory-files-recursively org-directory "\\.org$")))

	;; (setq org-startup-folded nil)
	;; (setq org-hide-block-startup t)

	(add-to-list 'org-capture-templates
    '("s" "Possible Solution" entry (file buffer-name)
       "** %^{Possible solution} \n*** Pros \n**** \n*** Cons \n**** \n*** Rating: =%?= "))

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
