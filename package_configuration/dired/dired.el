;;; editors/.doom.d/package_configuration/dired/dired.el -*- lexical-binding: t; -*-

(defun dired--do-shell (command-string)
  (interactive)
  (dired-do-shell-command
   command-string current-prefix-arg
   (dired-get-marked-files t current-prefix-arg)))

(defun dired-jpg-down-to ()
	(interactive)
	(dired--do-shell (s-concat "jpegoptim -S " (read-string "Size in Kb default 768: " nil nil "768") " ?" )))

(defun my/dired-paste-image ()
  "Save clipboard image to a timestamped file in the current Dired directory.
Does not prompt for a filename. Wayland and X11 compatible."
  (interactive)
  (let* ((dir (dired-current-directory))
         ;; 1. Generate a default filename with timestamp
         (filename (format-time-string "screenshot_%Y%m%d_%H%M%S.png"))
         (full-path (expand-file-name filename dir))
         ;; 2. Detect session type
         (is-wayland (or (string= (getenv "XDG_SESSION_TYPE") "wayland")
                         (getenv "WAYLAND_DISPLAY")))
         ;; 3. Prepare command
         (cmd (if is-wayland
                  (format "wl-paste -t image/png > %s" (shell-quote-argument full-path))
                (format "xclip -selection clipboard -t image/png -o > %s" (shell-quote-argument full-path)))))

    ;; 4. Execute
    (if (zerop (shell-command cmd))
        (progn
          (revert-buffer)
          (message "Saved: %s" filename))
      (progn
        ;; Cleanup if an empty file was created by the shell redirect
        (when (file-exists-p full-path) (delete-file full-path))
        (message "Error: No image found in clipboard!")))))

(map! :map dired-mode-map
  :localleader "p" #'my/dired-paste-image)

(after! dired-preview
	(setq dired-preview-delay 0.2)
	(map! :map dired-mode-map
		:localleader "p" #'my/dired-paste-image
		:n "C-d" #'dired-preview-page-down
		:n "C-u" #'dired-preview-page-up
		)
	)
