;;; nixos/editors/.doom.d/package_configuration/org-roam/eww.el -*- lexical-binding: t; -*-

;; Load the built-in JSON library
(require 'json)

;; 1. Centralized Configuration
;; To add, remove, or change a category, you only need to edit this list.
;; The format is an alist: '((HEADING . MAX-LEVEL) (HEADING . MAX-LEVEL) ...).
(defconst my-eww-task-categories
  '(("Repeatable" . 12)
    ("Speedruns"  . 3)
    ;; To add your new category, just add the line below:
    ("LONG TODOS"       . 4)
    ;; Add more categories here in the future!
    ; ("AnotherCategory" . 5)
    )
  "Alist of Org categories to display in the Eww todo widget.
Each element is a cons cell of the form (HEADING . MAX-LEVEL).")

(defconst my-eww-task-categories-after-10-30
  '(("Repeatable" . 12)
    ("Other progress / Distractions"  . 10)
    ;; To add your new category, just add the line below:
    ;; ("Speedruns"  . 3)
    ("Doable"       . 6)
    ;; Add more categories here in the future!
    ; ("AnotherCategory" . 5)
    )

  "Alist of Org categories to display in the Eww todo widget.
Each element is a cons cell of the form (HEADING . MAX-LEVEL).")

;; 2. The Updated Function
;; This function now reads from the configuration list above.
(defun my-eww-get-todos-json ()
  "Fetch unfinished Org tasks and print them as a JSON string for eww.
This function is data-driven, configured by `my-eww-task-categories`."
  (interactive) ; For easier testing with M-x my-eww-get-todos-json
  ;; Ensure the daily file exists, if that's part of your workflow

  ;; (when (and (fboundp 'my-get-todays-daily-path)
  ;;            (not (file-exists-p (my-get-todays-daily-path))))
  ;;   (org-roam-dailies-capture-today))

  (let* (;; This `mapcar` iterates through our config list and builds the data
         (task-data
          (mapcar
           (lambda (category-config)
             (let* ((heading (car category-config))
                    (max-level (cdr category-config))
                    ;; The JSON key should be lowercase to match your original JSON
                    (json-key heading)
                    ;; Fetch the tasks for the current category
                    ;; FIX: Ensure we return an empty vector if nil, so JSON encodes it as [] instead of null
                    (tasks (or (my-get-unfinished-tasks-under-heading heading max-level)
                               (vector))))
               ;; Create the final alist pair for this category: ("key" . [tasks...])
               (cons json-key tasks)))
           (let* ((current-time (decode-time))
                  (hour (nth 2 current-time))
                  (minute (nth 1 current-time)))
             (if (or (> hour 10) (and (= hour 10) (>= minute 30)))
                 my-eww-task-categories-after-10-30
               my-eww-task-categories))))

         ;; This setting ensures JSON keys are strings ("key") not keywords (:key)
         (json-key-type 'string))

    ;; Encode the final data and print it to stdout for eww
    (json-encode task-data)))

(defun my-eww-get-todays-json ()
  "Fetch unfinished Org tasks and print them as a JSON string for eww.
This function is data-driven, configured by `my-eww-task-categories`."
  (interactive) ; For easier testing with M-x my-eww-get-todos-json
  ;; Ensure the daily file exists, if that's part of your workflow

  ;; (when (and (fboundp 'my-get-todays-daily-path)
  ;;            (not (file-exists-p (my-get-todays-daily-path))))
  ;;   (org-roam-dailies-capture-today))

  (let* ((task-data `((week-points . ,(get-total-story-points-done-last-week))
                      (todays-points . ,(get-total-story-points-done-today))
                      (median-points . ,(get-median-total-story-points-done-last-week)))))

    ;; Encode the final data and print it to stdout for eww
    (json-encode task-data)))
