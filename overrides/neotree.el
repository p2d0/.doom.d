(defcustom neo-create-file-hook  nil
  "Hook called after file is created"
  :type 'hook
  :group 'neotree)

(defun neotree-create-node (filename)
  "Create a file or directory use specified FILENAME in current node."
  (interactive
   (let* ((current-dir (neo-buffer--get-filename-current-line neo-buffer--start-node))
          (current-dir (neo-path--match-path-directory current-dir))
          (filename (read-file-name "Filename:" current-dir)))
     (if (file-directory-p filename)
         (setq filename (concat filename "/")))
     (list filename)))
  (catch 'rlt
    (let ((is-file nil))
      (when (= (length filename) 0)
        (throw 'rlt nil))
      (setq is-file (not (equal (substring filename -1) "/")))
      (when (file-exists-p filename)
        (message "File %S already exists." filename)
        (throw 'rlt nil))
      (when (and is-file
                 (funcall neo-confirm-create-file (format "Do you want to create file %S ?"
                                                          filename)))
        ;; ensure parent directory exist before saving
        (mkdir (substring filename 0 (+ 1 (cl-position ?/ filename :from-end t))) t)
        ;; NOTE: create a empty file
        (write-region "" nil filename)
        (neo-buffer--save-cursor-pos filename)
        (neo-buffer--refresh nil)
        (run-hook-with-args 'neo-create-file-hook filename)
        (if neo-create-file-auto-open
            (find-file-other-window filename)))
      (when (and (not is-file)
                 (funcall neo-confirm-create-directory (format "Do you want to create directory %S?"
                                                               filename)))
        (mkdir filename t)
        (neo-buffer--save-cursor-pos filename)
        (neo-buffer--refresh nil)))))
