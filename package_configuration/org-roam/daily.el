;;; nixos/editors/.doom.d/package_configuration/org-roam/daily.el -*- lexical-binding: t; -*-

(defun get-text-under-first-heading ()
  "Return the text under the first heading of type \"Test\"."
  (interactive)
  (let* ((data (org-element-parse-buffer)) ; parse the buffer
					(first-heading (org-element-map data 'headline ; find the first headline
													 #'identity
													 nil t)) ; return the first match
					(text-begin (org-element-property :contents-begin first-heading)) ; get the beginning of the text
					(text-end (org-element-property :contents-end first-heading))) ; get the end of the text
    (buffer-substring-no-properties text-begin text-end))) ; return the text as a string

(defun org-find-headlines-under (heading predicate)
  "Find the headlines under a given heading that satisfy a predicate."
  (let* ((data (org-element-parse-buffer)) ; parse the buffer
          (first-heading (org-element-map data 'headline ; find the first headline
                           (lambda (head) (when (s-contains? heading (org-element-property :raw-value head))
                                       head))
                           nil t)) ; return the first match
          (headlines (org-element-map first-heading 'headline ; find the headlines under the first heading
                       (lambda (head)
                         (when (funcall predicate head) ; apply the predicate
                           (s-concat "** [ ] " (org-element-property :raw-value head) "\n")))
                       nil)))
    (apply #'s-concat headlines)))

(defun org-get-unfinished-under (heading)
  "Get the unfinished headlines under a given heading."
  (org-find-headlines-under heading ; use the helper function
    (lambda (head) (s-equals? "todo" (org-element-property :todo-type head))))) ; predicate for unfinished headlines

(defun org-get-dailies-under (heading)
  "Get the daily headlines under a given heading."
  (org-find-headlines-under heading ; use the helper function
    (lambda (head) (org-element-property :todo-type head)))) ; predicate for any headlines with a todo type
(defun org-get-text-under (heading)
  ""
  (let* ((data (org-element-parse-buffer)) ; parse the buffer
					(first-heading (org-element-map data 'headline ; find the first headline
													 (lambda (head) (when (s-contains? heading (org-element-property :raw-value head))
																			 head))
													 nil t)) ; return the first match
					(text-begin (org-element-property :contents-begin first-heading)) ; get the beginning of the text
					(text-end (org-element-property :contents-end first-heading))) ; get the end of the text
    (buffer-substring-no-properties text-begin text-end))	)

(defun get-last-daily-path ()
  "Return the path of the last daily file."
  (expand-file-name (format-time-string "%Y-%m-%d.org" (time-add (* -1 86400) (current-time))) (concat org-roam-directory org-roam-dailies-directory)))

(defun get-last-daily-test-under-first-heading ()
  "Return the text under the first heading of type \"Test\" in the last daily file."
  (with-current-buffer (find-file-noselect (get-last-daily-path)) ; use the helper function
    (string-trim (get-text-under-first-heading))))

(defun get-last-daily-unfinished ()
  "Return the unfinished headlines under the heading \"TODOS TODAY\" in the last daily file."
  (with-current-buffer (find-file-noselect (get-last-daily-path)) ; use the helper function
    (string-trim (org-get-unfinished-under "TODOS TODAY"))))

(defun org-get-last-daily-dailies ()
	(with-current-buffer (find-file-noselect (get-last-daily-path)) ; use the helper function
    (string-trim (org-get-dailies-under "DAILIES")))
	)

(defun get-last-daily-text-under (heading)
  "Return the text under a given heading in the last daily file."
  (with-current-buffer (find-file-noselect (get-last-daily-path)) ; use the helper function
    (string-trim (org-get-text-under heading))))
