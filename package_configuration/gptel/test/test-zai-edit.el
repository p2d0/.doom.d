;;; nixos/editors/.doom.d/package_configuration/gptel/test/test-zai-edit.el -*- lexical-binding: t; -*-
;; -*- no-byte-compile: t; -*-

;;; Buttercup tests for zai_edit.el — pure functions only, no network calls.

;; Capture the test directory at load-time (load-file-name is valid here).
(defvar my-zai-test-dir (file-name-directory load-file-name))

(defun my-zai-test--load-deps ()
  "Load aider_search.el and zai_edit.el relative to the test directory."
  (load-file (expand-file-name "../aider_search.el" my-zai-test-dir))
  (load-file (expand-file-name "../zai_edit.el"    my-zai-test-dir)))

;; ---------------------------------------------------------------------------

(describe "my-zai--build-edit-prompt"
	(before-all (my-zai-test--load-deps))
  (it "includes the filename"
    (let ((result (my-zai--build-edit-prompt "some code" "foo.el" "refactor")))
      (expect result :to-match "foo\\.el")))

  (it "includes the instruction"
    (let ((result (my-zai--build-edit-prompt "some code" "foo.el" "add docstrings")))
      (expect result :to-match "add docstrings")))

  (it "includes the buffer content"
    (let ((result (my-zai--build-edit-prompt "(defun hello ())" "foo.el" "refactor")))
      (expect result :to-match "(defun hello ())"))))

;; ---------------------------------------------------------------------------

(describe "my-zai--strip-outer-fence"
	(before-all (my-zai-test--load-deps))
  (it "returns text unchanged when no fence is present"
    (let ((text "filename.el\n<<<<<<< SEARCH\nold\n=======\nnew\n>>>>>>> REPLACE"))
      (expect (my-zai--strip-outer-fence text) :to-equal text)))

  (it "strips a plain triple-backtick fence"
    (let* ((inner "filename.el\n<<<<<<< SEARCH\nold\n=======\nnew\n>>>>>>> REPLACE")
						(fenced (concat "```\n" inner "\n```")))
      (expect (my-zai--strip-outer-fence fenced) :to-equal inner)))

  (it "strips a fence with a language tag"
    (let* ((inner "filename.el\n<<<<<<< SEARCH\nold\n=======\nnew\n>>>>>>> REPLACE")
						(fenced (concat "```elisp\n" inner "\n```")))
      (expect (my-zai--strip-outer-fence fenced) :to-equal inner)))

  (it "does not strip inner fences when outer fence is absent"
    (let ((text "some line\n```\ninner\n```\nmore"))
      (expect (my-zai--strip-outer-fence text) :to-equal text))))

;; ---------------------------------------------------------------------------

(describe "my-aider--parse-sr-blocks (round-trip)"
	(before-all (my-zai-test--load-deps))
  (it "parses a single-file S/R block"
    (let* ((response "myfile.el\n<<<<<<< SEARCH\nold line\n=======\nnew line\n>>>>>>> REPLACE\n")
						(result (my-aider--parse-sr-blocks response)))
      (expect (length result) :to-equal 1)
      (expect (car (car result)) :to-equal "myfile.el")))

  (it "parses multiple hunks for the same file into one entry"
    (let* ((response (concat "foo.el\n<<<<<<< SEARCH\na\n=======\nb\n>>>>>>> REPLACE\n"
                       "foo.el\n<<<<<<< SEARCH\nc\n=======\nd\n>>>>>>> REPLACE\n"))
						(result (my-aider--parse-sr-blocks response)))
      (expect (length result) :to-equal 1)
      (expect (length (cdr (car result))) :to-equal 2)))

  (it "parses hunks for different files into separate entries"
    (let* ((response (concat "a.el\n<<<<<<< SEARCH\nold\n=======\nnew\n>>>>>>> REPLACE\n"
                       "b.el\n<<<<<<< SEARCH\nold\n=======\nnew\n>>>>>>> REPLACE\n"))
						(result (my-aider--parse-sr-blocks response)))
      (expect (length result) :to-equal 2)))

  (it "returns nil for text with no S/R blocks"
    (expect (my-aider--parse-sr-blocks "just some plain text") :to-equal nil))

  (it "works on output stripped by my-zai--strip-outer-fence"
    (let* ((inner "myfile.el\n<<<<<<< SEARCH\nold\n=======\nnew\n>>>>>>> REPLACE\n")
						(fenced (concat "```\n" inner "\n```"))
						(result (my-aider--parse-sr-blocks (my-zai--strip-outer-fence fenced))))
      (expect (length result) :to-equal 1)
      (expect (car (car result)) :to-equal "myfile.el"))))
