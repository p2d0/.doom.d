;;; nixos/editors/.doom.d/package_configuration/org-roam/daily.el -*- lexical-binding: t; -*-


;; my-tests.el

;; Make sure the functions we're testing are loaded.
;; Adjust the path to where your functions are defined.
(load-file "../notifications.el")
(require 's)

;; Define test data as variables to keep tests clean.
(defvar test-org-content-standard
  "* Progress
...
* Other progress / Distractions
...
* Repeatable
:PROPERTIES:
:VISIBILITY: children
:END:
- [ ] Task 1 (Unfinished)
- [X] Task 2 (Finished)
- [ ] Task 3 (Unfinished)
- [-] Task 4 (In-progress, counts as unfinished)
- [ ] Task 5 (Unfinished)
* Another Heading
- [ ] Some other task
" "Standard test case with mixed task statuses.")

(defvar test-org-content-all-done
  "* Repeatable
- [X] Task 1
- [X] Task 2
" "Test case where all tasks are completed.")

(defvar test-org-content-no-heading
  "* Some Other Heading
- [ ] A task
" "Test case where the target heading is missing.")

(defvar test-org-content-no-tasks
  "* Repeatable
This section has no list items.
" "Test case where the heading exists but has no tasks.")

(defvar test-org-content-nested
  "* Repeatable
- [ ] Top Level Task 1
  - [ ] Nested Task (should be ignored by our logic)
- [X] Top Level Task 2 (Done)
- [ ] Top Level Task 3
" "Test case with nested list items.")


;; --- Test Suite ---

(describe "Parsing unfinished Org tasks from a string"
  (describe "my-parse-unfinished-tasks-from-string"

    (it "should return the first 3 unfinished tasks"
      (expect (my-parse-unfinished-tasks-from-string test-org-content-standard "Repeatable" 3)
              :to-equal '("Task 1 (Unfinished)" "Task 3 (Unfinished)" "Task 4 (In-progress, counts as unfinished)")))

    (it "should return only 1 task when limit is 1"
      (expect (my-parse-unfinished-tasks-from-string test-org-content-standard "Repeatable" 1)
              :to-equal '("Task 1 (Unfinished)")))

    (it "should return all unfinished tasks if limit is higher than available"
      (expect (my-parse-unfinished-tasks-from-string test-org-content-standard "Repeatable" 10)
              :to-equal '("Task 1 (Unfinished)" "Task 3 (Unfinished)" "Task 4 (In-progress, counts as unfinished)" "Task 5 (Unfinished)")))

    (it "should return an empty list if the target heading does not exist"
      ;; --- FIX IS HERE ---
      (expect (my-parse-unfinished-tasks-from-string test-org-content-no-heading "Repeatable" 3)
              :to-equal '()))

    (it "should return an empty list if all tasks under heading are done"
      ;; --- FIX IS HERE ---
      (expect (my-parse-unfinished-tasks-from-string test-org-content-all-done "Repeatable" 3)
              :to-equal '()))

    (it "should return an empty list if heading exists but has no tasks"
      ;; --- FIX IS HERE ---
      (expect (my-parse-unfinished-tasks-from-string test-org-content-no-tasks "Repeatable" 3)
              :to-equal '()))

    (it "should correctly handle nested lists and only return top-level tasks"
      ;; The new logic correctly handles this by default.
      (expect (my-parse-unfinished-tasks-from-string test-org-content-nested "Repeatable" 3)
              :to-equal '("Top Level Task 1" "Top Level Task 3")))

    (it "should return an empty list for completely empty input"
      ;; --- FIX IS HERE ---
      (expect (my-parse-unfinished-tasks-from-string "" "Repeatable" 3)
              :to-equal '()))
    ))
