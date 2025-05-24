;;; nixos/editors/.doom.d/package_configuration/org/org-visibility.el -*- lexical-binding: t; -*-

(defun org-fold-show-children (&optional level)
  "Show all direct subheadings of this heading.
Prefix arg LEVEL is how many levels below the current level should be
shown. If direct subheadings are deeper than LEVEL, they are still
displayed.
When `org-cycle-include-plain-lists' is 'integrate, this function
will also fold plain lists within the body of the current heading
and its direct children to show only their top-level items."
  (interactive "p")
  (unless (org-before-first-heading-p)
    (save-excursion
      ;; Go to the beginning of the current heading.
      (org-with-limited-levels (org-back-to-heading t))
      (let* ((parent-hd-start (point)) ; Capture start of parent heading
             (current-level (funcall outline-level))
             (parent-level current-level)
             (max-level (org-get-valid-level
                         parent-level
                         (if level (prefix-numeric-value level) 1)))
             (min-level-direct-child most-positive-fixnum)
             ;; Determine the end of the entire subtree for the current heading
             (subtree-end (save-excursion (org-end-of-subtree t t)))
             (regexp-fmt "^\\*\\{%d,%s\\}\\(?: \\|$\\)")
             ;; Regex to find child headings
             (re (format regexp-fmt
                         current-level ; parent-level stars
                         (cond ; Max stars for child (related to inlinetasks)
                          ((not (featurep 'org-inlinetask)) "")
                          (org-odd-levels-only (- (* 2 org-inlinetask-min-level) 3))
                          (t (1- org-inlinetask-min-level))))))

        ;; Display parent heading body.
        (org-fold-heading nil)
        (forward-line) ; Move past heading line into the body.

        ;; Display children headings and their bodies.
        ;; Loop through direct child headings until the end of the parent's subtree.
        (let ((search-limit subtree-end))
          (while (re-search-forward re search-limit t)
            (setq current-level (funcall outline-level))
            ;; Adjust regex if the first child found is deeper than expected,
            ;; ensuring we still see it but then only look for its siblings.
            (when (< current-level min-level-direct-child)
              (setq min-level-direct-child current-level
                    re (format regexp-fmt
                               parent-level
                               (max min-level-direct-child max-level))))
            ;; Reveal this child heading and its body.
            (org-fold-heading nil)))

        ;; If 'integrate' is set for plain lists, fold all lists in the parent's subtree.
        (when (eq org-cycle-include-plain-lists 'integrate)
          (save-excursion
            ;; Start from the parent heading whose children were just shown.
            (goto-char parent-hd-start)
            ;; `subtree-end` is the boundary for list searching (equivalent to `eos`).
            (let ((eos subtree-end))
              ;; Search for plain list items within the current heading's subtree.
              (while (org-list-search-forward (org-item-beginning-re) eos t)
                ;; `org-list-search-forward` moves point to the start of the item.
                ;; Ensure we are at the beginning of the line for `org-list-struct`.
                (beginning-of-line)
                (let* ((struct (org-list-struct))
                       (prevs (org-list-prevs-alist struct))
                       ;; Determine the end of the current list.
                       (list-bottom (org-list-get-bottom-point struct)))
                  ;; Fold all items in this list to show only top-level ones.
                  (dolist (e (org-list-get-all-items (point) struct prevs))
                    (org-list-set-item-visibility e struct 'folded))
                  ;; Move point past the currently processed list to continue searching.
                  ;; If list-bottom is nil or beyond eos, goto eos to be safe.
                  (goto-char (if (and list-bottom (< list-bottom eos))
                                 list-bottom
                               eos)))))))))))

(defun org-cycle-internal-local ()
  "Do the local cycling action."
  (let ((goal-column 0) eoh eol eos has-children children-skipped struct)
    ;; First, determine end of headline (EOH), end of subtree or item
    ;; (EOS), and if item or heading has children (HAS-CHILDREN).
    (save-excursion
      (if (org-at-item-p)
	  (progn
	    (forward-line 0)
	    (setq struct (org-list-struct))
	    (setq eoh (line-end-position))
	    (setq eos (org-list-get-item-end-before-blank (point) struct))
	    (setq has-children (org-list-has-child-p (point) struct)))
	(org-back-to-heading)
	(setq eoh (save-excursion (outline-end-of-heading) (point)))
	(setq eos (save-excursion
		    (org-end-of-subtree t t)
		    (unless (eobp) (forward-char -1))
		    (point)))
	(setq has-children
	      (or
	       (save-excursion
		 (let ((level (funcall outline-level)))
		   (outline-next-heading)
		   (and (org-at-heading-p)
			(> (funcall outline-level) level))))
	       (and (eq org-cycle-include-plain-lists 'integrate)
		    (save-excursion
		      (org-list-search-forward (org-item-beginning-re) eos t))))))
      ;; Determine end invisible part of buffer (EOL)
      (forward-line 1)
      (if (eq org-fold-core-style 'text-properties)
          (while (and (not (eobp))		;this is like `next-line'
		      (org-fold-folded-p (1- (point))))
	    (goto-char (org-fold-next-visibility-change nil nil t))
	    (and (eolp) (forward-line 1)))
        (while (and (not (eobp))		;this is like `next-line'
		    (get-char-property (1- (point)) 'invisible))
	  (goto-char (next-single-char-property-change (point) 'invisible))
	  (and (eolp) (forward-line 1))))
      (setq eol (point)))
    ;; Find out what to do next and set `this-command'
    (cond
     ((= eos eoh)
      ;; Nothing is hidden behind this heading
      (unless (org-before-first-heading-p)
	(run-hook-with-args 'org-cycle-pre-hook 'empty))
      (org-unlogged-message "EMPTY ENTRY")
      (setq org-cycle-subtree-status nil)
      (save-excursion
	(goto-char eos)
        (org-with-limited-levels
	 (outline-next-heading))
	(when (org-invisible-p) (org-fold-heading nil))))
     ((and (or (>= eol eos)
	       (save-excursion (goto-char eol) (skip-chars-forward "[:space:]" eos) (= (point) eos)))
	   (or has-children
	       (not (setq children-skipped
			org-cycle-skip-children-state-if-no-children))))
      ;; Entire subtree is hidden in one line: children view
      (unless (org-before-first-heading-p)
        (org-with-limited-levels
	 (run-hook-with-args 'org-cycle-pre-hook 'children)))
      (if (org-at-item-p)
	  (org-list-set-item-visibility (line-beginning-position) struct 'children)
	(org-fold-show-entry)
	(org-with-limited-levels (org-fold-show-children))
	(org-fold-show-set-visibility 'tree)
	;; Fold every list in subtree to top-level items.
	(when (eq org-cycle-include-plain-lists 'integrate)
	  (save-excursion
	    (org-back-to-heading)
	    (while (org-list-search-forward (org-item-beginning-re) eos t)
	      (forward-line 0)
	      (let* ((struct (org-list-struct))
		     (prevs (org-list-prevs-alist struct))
		     (end (org-list-get-bottom-point struct)))
		(dolist (e (org-list-get-all-items (point) struct prevs))
		  (org-list-set-item-visibility e struct 'folded))
		(goto-char (if (< end eos) end eos)))))))
      (org-unlogged-message "CHILDREN")
      (save-excursion
	(goto-char eos)
        (org-with-limited-levels
	 (outline-next-heading))
	(when (and
               ;; Subtree does not end at the end of visible section of the
               ;; buffer.
               (< (point) (point-max))
               (org-invisible-p))
          ;; Reveal the following heading line.
          (org-fold-heading nil)))
      (setq org-cycle-subtree-status 'children)
      (unless (org-before-first-heading-p)
	(run-hook-with-args 'org-cycle-hook 'children)))
     ((or children-skipped
	  (and (eq last-command this-command)
	       (eq org-cycle-subtree-status 'children)))
      ;; We just showed the children, or no children are there,
      ;; now show everything.
      (unless (org-before-first-heading-p)
	(run-hook-with-args 'org-pre-cycle-hook 'subtree))
      (org-fold-region eoh eos nil 'outline)
      (org-unlogged-message
       (if children-skipped "SUBTREE (NO CHILDREN)" "SUBTREE"))
      (setq org-cycle-subtree-status 'subtree)
      (unless (org-before-first-heading-p)
	(run-hook-with-args 'org-cycle-hook 'subtree)))
     (t
      ;; Default action: hide the subtree.
      (run-hook-with-args 'org-cycle-pre-hook 'folded)
      (org-fold-region eoh eos t 'outline)
      (org-unlogged-message "FOLDED")
      (setq org-cycle-subtree-status 'folded)
      (unless (org-before-first-heading-p)
	(run-hook-with-args 'org-cycle-hook 'folded))))))
