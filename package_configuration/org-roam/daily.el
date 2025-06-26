;;; nixos/editors/.doom.d/package_configuration/org-roam/daily.el -*- lexical-binding: t; -*-
(require 's)
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
                           (lambda (head) (if (s-contains? heading (org-element-property :raw-value head))
																						(org-element-extract head)
																						))
                           nil t)) ; return the first match
          (reset-check  (org-element-map first-heading 'item
											  	 (lambda (head)
											  		 (when (funcall predicate head)
															 (if (org-element-type-p (org-element-parent (org-element-parent head)) 'section)
																 (org-element-put-property head :checkbox 'off)
																 (progn
																	 (org-element-put-property head :checkbox 'off)
																	 nil)))))))
    (org-element-interpret-data reset-check)))

;; (defun get-text-before-first-heading ()
;; 	(org-element-map (org-element-parse-buffer) 'section
;; 		(lambda (section)
;; 			(prin1 section)
;; 			(org-element-map section t (lambda (s)
;; 																					 (org-element-property :value s) ))
;; 			;; (org-element-property :value section)
;; 			) nil t)
;; 	)

(defun get-text-before-first-heading ()
  "Return the text before the first heading in the buffer."
  (interactive)
  (let* ((data (org-element-parse-buffer)) ; parse the buffer
					(first-heading (org-element-map data 'headline ; find the first headline
                           #'identity
                           nil t)) ; return the first match
					(property-drawer (org-element-map data 'property-drawer ; find the first headline
														 #'identity
														 nil t))
					(text-begin (org-element-property :end property-drawer)) ; start from the beginning of the buffer
					(text-end (org-element-property :begin first-heading))) ; get the beginning of the first heading
    (buffer-substring text-begin text-end)
		))

(defun org-get-last-daily-text-before-first-heading ()
	(with-current-buffer (find-file-noselect (get-last-daily-path)) ; use the helper function
    (string-trim (get-text-before-first-heading))))

(defun get-total-minutes-done ()
	(let* ((data (org-element-parse-buffer)) ; parse the buffer
					(first-heading (org-element-map data 'headline ; find the first headline
                           (lambda (item)
														 ;; (prin1 item)
														 (when (and
																		 (s-contains? "Minute" (org-element-property :raw-value item))
																		 (s-equals? "done" (org-element-property :todo-type item)) )
															 (org-element-property :raw-value item )
															 )
														 )
                           nil)))
		(apply '+ (mapcar (lambda (item)
												(string-to-number (car (s-split "-" item))))
								first-heading))
		)
	)

(defun get-total-story-points-done ()
  "Sum the story points from checked items in the Org-mode buffer.
Items must have a checkbox marked as [X] and contain 'S<number>' in their text."
  (let ((data (org-element-parse-buffer)))
    (apply '+ (org-element-map data 'item
                (lambda (item)
                  (when (eq (org-element-property :checkbox item) 'on)
                    (let* ((begin (org-element-property :begin item))
                           (end (org-element-property :end item))
                           (text (buffer-substring-no-properties
                                  (save-excursion
                                    (goto-char begin)
                                    (re-search-forward "\\[.\\]\\s-+" end)
                                    (point))
                                  end)))
                      (when (and text (string-match "S\\([[:digit:]]+\\)" text))
                        (string-to-number (match-string 1 text))))))
                nil nil))))

(defun get-total-story-points-done-today ()
	(with-current-buffer (find-file-noselect (my-get-todays-daily-path)) ; use the helper function
		(get-total-story-points-done)))

(defun org-get-unfinished-under (heading)
  "Get the unfinished headlines under a given heading."
  (org-find-headlines-under heading ; use the helper function

    (lambda (head)
			(member (org-element-property :checkbox head) '(off trans))))) ; predicate for unfinished headlines

(defun org-get-dailies-under (heading)
  "Get the daily headlines under a given heading."
  (org-find-headlines-under heading ; use the helper function
    (lambda (head)
			(org-element-property :checkbox head)))) ; predicate for any headlines with a todo type

(defun org-get-text-under (heading)
  ""
  (let* ((data (org-element-parse-buffer)) ; parse the buffer
					(first-heading (org-element-map data 'headline ; find the first headline
													 (lambda (head) (when (s-contains? heading (org-element-property :raw-value head))
																						head))
													 nil t)) ; return the first match
					(text-begin (org-element-property :contents-begin first-heading)) ; get the beginning of the text
					(text-end (org-element-property :contents-end first-heading))) ; get the end of the text
    (buffer-substring-no-properties text-begin text-end)))


(defun get-last-modified-file (directory)
  "Return the path of the most recently modified file in the given DIRECTORY."
  (let ((files (directory-files-and-attributes directory t "^[^.]" t)))
    (car (car (sort files (lambda (a b)
                            (time-less-p (nth 5 b) (nth 5 a))))))))

(defun update-total-minutes ()
  (interactive)
  (save-excursion
		(goto-char (point-min))
    (let ((total-minutes (get-total-minutes-done)))
      (when (and (re-search-forward "TOTAL TODAY: =\\([0-9]+\\) Minutes=" nil t)
							(not (= (string-to-number (match-string 1)) total-minutes)))
        (replace-match (format "TOTAL TODAY: =%d Minutes=" total-minutes))))))

(defun update-total-story-points ()
  (interactive)
  (save-excursion
		(goto-char (point-min))
    (let ((total-minutes (get-total-story-points-done)))
      (when (and (re-search-forward "TOTAL SP TODAY: =\\([0-9]+\\) Points=" nil t)
							(not (= (string-to-number (match-string 1)) total-minutes)))
        (replace-match (format "TOTAL SP TODAY: =%d Points=" total-minutes))))))

(defun get-last-daily-path (&optional days)
  "Return the path of the most recent existing daily file in the org-roam-dailies-directory.
When DAYS is non-nil, look back that many days from today."
  (let* ((days (or days 1))
         (date (format-time-string "%Y-%m-%d" 
                                 (time-subtract (current-time) (days-to-time days))))
         (file (expand-file-name (concat date ".org")
                               (expand-file-name org-roam-dailies-directory org-roam-directory))))
    (cond
     ((file-exists-p file) file)
     ((< days 30) (get-last-daily-path (1+ days)))
     (t nil))))

;; (defun get-previous-daily-path ()
;;   "Return the path of the previous daily file."
;; 	(prin1 )
;;   ;; (let ((current-daily-date (get-current-daily-date))) ; use the helper function
;;   ;;   (when current-daily-date
;;   ;;     (let* ((current-daily-time (org-current-time) ) ; convert the date string to time object
;; 	;; 						(previous-daily-time (time-add current-daily-time (* -1 86400))) ; subtract one day from the current time
;; 	;; 						(previous-daily-date (format-time-string "%Y-%m-%d" previous-daily-time))) ; convert the time object back to date string
;;   ;;       (expand-file-name (concat previous-daily-date ".org") (concat org-roam-directory org-roam-dailies-directory)))))
;; 	) ; expand the file name like get-last-daily-path

(defmacro with-last-daily-file (&rest body)
  "Execute BODY in the context of the last daily file.
Automatically handles file opening/closing and string trimming."
  `(with-current-buffer (find-file-noselect (get-last-daily-path))
     (string-trim ,@body)))

(defun get-last-daily-test-under-first-heading ()
  "Return the text under the first heading of type \"Test\" in the last daily file."
  (with-last-daily-file (get-text-under-first-heading)))

(defun get-last-daily-unfinished ()
  "Return the unfinished headlines under the heading \"TODOS TODAY\" in the last daily file."
  (with-last-daily-file (org-get-unfinished-under "TODOS TODAY")))

(defun get-last-daily-total-minutes-done ()
  "Return the total minutes done in the last daily file."
  (with-last-daily-file (number-to-string (get-total-minutes-done))))

(defun get-last-daily-total-story-points-done ()
  "Return the total story points done in the last daily file."
  (with-last-daily-file (number-to-string (get-total-story-points-done))))

(defun get-last-daily-unfinished-under (todo)
  "Return the unfinished headlines under the given TODO heading in the last daily file."
  (with-last-daily-file (org-get-unfinished-under todo)))

(defun org-get-last-daily-dailies ()
  "Return the dailies under \"NORMAL DAILIES\" in the last daily file."
  (with-last-daily-file (org-get-dailies-under "NORMAL DAILIES")))

(defun org-get-last-daily-under (todo)
  "Return content under the given TODO heading in the last daily file."
  (with-last-daily-file (org-get-dailies-under todo)))

(defun get-weather ()
	(let* ((url "https://api.open-meteo.com/v1/forecast?latitude=55.7522&longitude=37.6156&daily=temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min&timezone=Europe%2FMoscow&forecast_days=1")
					(buffer (url-retrieve-synchronously url))
					(json-array-type 'list))
    (with-current-buffer buffer
      (goto-char url-http-end-of-headers)
			;; (prin1 (json-read))
			(let-alist (json-read)
				(format "MIN: %s (%s) MAX: %s (%s)"
					(car .daily.temperature_2m_min)
					(car .daily.apparent_temperature_min)
					(car .daily.temperature_2m_max)
					(car .daily.apparent_temperature_max)
					))
			)))

(defun get-weather-for-today-daily ()
	(let* ((url
					 (format "https://api.open-meteo.com/v1/forecast?latitude=55.7522&longitude=37.6156&daily=temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min&timezone=Europe%%2FMoscow&start_date=%s&end_date=%s"
						 (format-time-string "%Y-%m-%d" (time-add (* -1 86400) (org-capture-get :default-time)))
						 (format-time-string "%Y-%m-%d" (time-add (* -1 86400) (org-capture-get :default-time)))))
					(buffer (url-retrieve-synchronously url))
					(json-array-type 'list))
		(with-current-buffer buffer
			(goto-char url-http-end-of-headers)
			;; (prin1 (json-read))
			(let-alist (json-read)
				(format "MIN: %s (%s) MAX: %s (%s)"
					(car .daily.temperature_2m_min)
					(car .daily.apparent_temperature_min)
					(car .daily.temperature_2m_max)
					(car .daily.apparent_temperature_max)
					))
			))
	)

(defun get-current-daily-date ()
	(let ((filename (file-relative-name (buffer-file-name))))
		(when filename
			(substring filename 0 10))))

(defun get-weather-for-daily ()
	(let* ((url
					 (format "https://api.open-meteo.com/v1/forecast?latitude=55.7522&longitude=37.6156&daily=temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min&timezone=Europe%%2FMoscow&start_date=%s&end_date=%s"
						 (get-current-daily-date)
						 (get-current-daily-date)))
					(buffer (url-retrieve-synchronously url))
					(json-array-type 'list))
		(with-current-buffer buffer
			(goto-char url-http-end-of-headers)
			;; (prin1 (json-read))
			(let-alist (json-read)
				(format "MIN: %s (%s) MAX: %s (%s)"
					(car .daily.temperature_2m_min)
					(car .daily.apparent_temperature_min)
					(car .daily.temperature_2m_max)
					(car .daily.apparent_temperature_max)
					))
			))
	)

(defun get-last-daily-text-under (heading)
  "Return the text under a given heading in the last daily file."
  (with-current-buffer (find-file-noselect (get-last-daily-path)) ; use the helper function
    (string-trim (org-get-text-under heading))))

(defun get-total-minutes-done-last-week ()
  "Return the total minutes done in the last 7 days."
  (let ((total 0))
    (dotimes (i 7 total)
      (let* ((date (format-time-string "%Y-%m-%d"
                                      (time-add (current-time) (* -86400 (1+ i)))))
             (file-path (expand-file-name (concat date ".org")
                                         (expand-file-name org-roam-dailies-directory org-roam-directory))))
        (when (file-exists-p file-path)
          (with-current-buffer (find-file-noselect file-path)
            (goto-char (point-min))
            (let ((buffer-total (get-total-minutes-done)))
              (setq total (+ total buffer-total)))))))
		(number-to-string total)
		))

(defun get-total-story-points-done-last-week ()
  "Return the total story points done in the last 7 days."
  (let ((total 0))
    (dotimes (i 7 total)
      (let* ((date (format-time-string "%Y-%m-%d"
                                      (time-add (current-time) (* -86400 (1+ i)))))
             (file-path (expand-file-name (concat date ".org")
                                         (expand-file-name org-roam-dailies-directory org-roam-directory))))
        (when (file-exists-p file-path)
          (with-current-buffer (find-file-noselect file-path)
            (goto-char (point-min))
            (let ((buffer-total (get-total-story-points-done)))
              (setq total (+ total buffer-total)))))))
		(number-to-string total)
		))

(defun get-average-total-story-points-done-last-week ()
	"Return the average total story points done in the last 7 days."
	(let ((total 0)
				(count 0))
		(dotimes (i 7 total)
			(let* ((date (format-time-string "%Y-%m-%d"
																			(time-add (current-time) (* -86400 (1+ i)))))
						 (file-path (expand-file-name (concat date ".org")
																				 (expand-file-name org-roam-dailies-directory org-roam-directory))))
				(when (file-exists-p file-path)
					(with-current-buffer (find-file-noselect file-path)
						(goto-char (point-min))
						(let ((buffer-total (get-total-story-points-done)))
							(setq total (+ total buffer-total))
							(setq count (+ count 1)))))))
		(if (> count 0)
				(format "%.0f" (/ total count))
			"0.00")
		))

(defun get-median-total-story-points-done-last-week ()
  "Return the median total story points done in the last 7 days."
  (let ((values '()))
    (dotimes (i 7)
      (let* ((date (format-time-string "%Y-%m-%d"
                                      (time-add (current-time) (* -86400 (1+ i)))))
             (file-path (expand-file-name (concat date ".org")
                                         (expand-file-name org-roam-dailies-directory org-roam-directory))))
        (when (file-exists-p file-path)
          (with-current-buffer (find-file-noselect file-path)
            (goto-char (point-min))
            (let ((buffer-total (get-total-story-points-done)))
              (push buffer-total values))))))
    (if (null values)
        "0"
      (let* ((sorted-values (sort values '<))
             (count (length sorted-values))
             (mid (floor count 2))
             (median (if (cl-oddp count)
                         (number-to-string (nth mid sorted-values))
                       (format "%.0f" (/ (+ (nth mid sorted-values) (nth (1- mid) sorted-values)) 2.0)))))
        median))))
