;;; editors/.doom.d/package_configuration/dired/dired.el -*- lexical-binding: t; -*-

(defun dired--do-shell (command-string)
  (interactive)
  (dired-do-shell-command
   command-string current-prefix-arg
   (dired-get-marked-files t current-prefix-arg)))

(defun dired-jpg-down-to ()
	(interactive)
	(dired--do-shell (s-concat "jpegoptim -S " (read-string "Size in Kb default 768: " nil nil "768") " ?" )))

(defun my/dired-paste-image (filename)
  "Save clipboard image to FILENAME. 
If extension is .jpg or .jpeg, it converts the PNG clipboard data using ImageMagick.
Works with Wayland (wl-paste) and X11 (xclip)."
  (interactive "sEnter filename (e.g. image.png or image.jpg): ")
  (let* ((dir (dired-current-directory))
         ;; 1. Determine format and ensure extension
         (is-jpg (string-match-p "\\.jpe?g$" filename))
         (extension (if is-jpg ".jpg" ".png"))
         (final-name (if (string-match-p "\\.\\(png\\|jpe?g\\)$" filename)
                         filename
                       (concat filename extension)))
         (full-path (expand-file-name final-name dir))
         
         ;; 2. Detect Session Type
         (is-wayland (or (string= (getenv "XDG_SESSION_TYPE") "wayland")
                         (getenv "WAYLAND_DISPLAY")))
         
         ;; 3. Build the clipboard command (Flameshot puts PNG in clipboard)
         (paste-bin (if is-wayland "wl-paste" "xclip -selection clipboard -o"))
         (mimetype "image/png") ;; Most tools use PNG for clipboard
         
         ;; 4. Construct the shell pipeline
         (cmd (if is-jpg
                  ;; If JPG requested, pipe PNG clipboard data through ImageMagick
                  (format "%s -t %s | convert - %s" 
                          paste-bin mimetype (shell-quote-argument full-path))
                ;; Otherwise just save directly
                (format "%s -t %s > %s" 
                        paste-bin mimetype (shell-quote-argument full-path)))))

    ;; 5. Execute
    (if (zerop (shell-command cmd))
        (progn
          (revert-buffer)
          (message "Saved image as: %s" final-name))
      (progn
        (when (file-exists-p full-path) (delete-file full-path))
        (error "Failed to paste image. Is ImageMagick installed? (for jpg) / Is there an image in clipboard?")))))

(after! dired-preview
	(setq dired-preview-delay 0.2)
	(map! :map dired-mode-map
		:leader "p" #'my/dired-paste-image
		)
	(map! :map dired-mode-map
		:n "C-d" #'dired-preview-page-down
		:n "C-u" #'dired-preview-page-up
		)
	)
