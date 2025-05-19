;;; nixos/editors/.doom.d/package_configuration/org/org-modern.el -*- lexical-binding: t; -*-

(after! org-modern
	(setq
		;; Edit settings
		org-auto-align-tags nil
		org-tags-column 0
		org-catch-invisible-edits 'show-and-error
		org-modern-todo nil
		org-modern-tag t
		org-special-ctrl-a/e t
		org-insert-heading-respect-content t

		;; Org styling, hide markup etc.
		org-hide-emphasis-markers t
		org-pretty-entities t
		org-agenda-tags-column 0
		org-ellipsis "…")
	)
(setq org-modern-fold-stars '(("○" . "◉")
                          ("○" . "◉")
                          ("○" . "◉")
                          ("○" . "◉")
                          ("○" . "◉")
                          ("□" . "▣")  ;; ⯀  geometric shapes
                          ;; ("♡" . "♥")
                          ("◇" . "◈")
                          ("♤" . "♠")
                          ("▽" . "▼")
                          ("♧" . "♣")  ;; Miscellaneous symbols
                          ("✳" . "✸")
                          ("♕" . "♛")
                          ("⬡" . "⬢") ;; hexagon
                          ("☆" . "★")
                          ("⬠" . "⬟") ;; white pentagon and black (this is large)
                          ;; ("🟕" . "🟖") ;; circle triangle and negative
                          ;; ("🟗" . "🟘") ;; circle square and negative
                          ))
(setq org-modern-hide-stars 'leading
	org-modern-priority
	(quote ((?A . "")
					 (?B . "")
					 (?C . "󰈿")
					 (?D . "")
					 (?E . "󱗼")
					 (?F . "󱗾")
					 (?G . "󰇙")))
	org-modern-keyword
	(quote (("options" . "🔧")
					 ("tag" . "")
					 ("#+" . "➤")
					 (t . t))))
'(org-modern-list'(("+" . "➤") (?- . "✦") (?* . "•")))
