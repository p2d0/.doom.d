;;; nixos/editors/.doom.d/package_configuration/org/org-visibility.el -*- lexical-binding: t; -*-

(defun org-fold-show-children-fixed (&optional level)
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

(advice-add 'org-fold-show-children :override #'org-fold-show-children-fixed)
