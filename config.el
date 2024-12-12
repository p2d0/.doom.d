;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Andrew Cerkin"
  user-mail-address "cerkin-3@yandex.ru")

(require 's)
(defun dired-remove-bak-suffix ()
  "Remove '_bak' suffix from all marked files in the current dired buffer."
  (interactive)
  (let ((files (dired-get-marked-files t current-prefix-arg)))
    (dolist (file files)
      (when (stringp file)
        (let ((new-file (s-replace-regexp "_bak$" "" file)))
          (when (and (not (string= file new-file))
                  (not (file-exists-p new-file)))
            (message "Renaming %s to %s" file new-file)
            (rename-file file new-file t))
          (unless (string= file new-file)
            (message "No change needed for %s" file))))
      (unless (stringp file)
        (message "Invalid file: %s" file)))))


;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:

;; (setq +light-theme+ 'doom-nano-light)
;; (setq +dark-theme+ 'doom-nano-dark)

(setq +light-theme+ 'doom-nord-light)
(setq +dark-theme+ 'doom-dracula)

(setq lsp-python-ms-auto-install-server nil)
(setq lsp-python-ms-executable "/run/current-system/sw/bin/python-language-server")

(load! "nano")
(load! "use-packages")
;; (load! "configuration/autodarkmode")
;; (solaire-mode t)

(defun solaire-mode-real-buffer-except-treemacs-p ()
  "Return t if the current buffer is a real (file-visiting) buffer."
  (or (buffer-file-name (buffer-base-buffer))
    (string-match "Treemacs" (buffer-name (current-buffer)))
    (string-match "*doom*" (buffer-name (current-buffer)))
    (string-match "magit:" (buffer-name (current-buffer)))
    ))

(after! solaire-mode
  (setq solaire-mode-real-buffer-fn #'solaire-mode-real-buffer-except-treemacs-p)
  )

;; (if (= (get-color-scheme) 1)
;; 	(load-theme +dark-theme+ t)
;; 	(load-theme +light-theme+ t))
(use-package doom-themes
  :custom-face
  (font-lock-comment-face ((t (:foreground "red"))))
  ;; DRACULA
  (window-divider   ((t (:foreground "#1E2029" :background "#1E2029"))))
  (solaire-default-face   ((t (:background "#1E2029"))))
  (internal-border   ((t (:foreground "#1E2029" :background "#1E2029"))))
  :config
  (setq doom-themes-enable-bold nil)
  (load-theme +dark-theme+ t)
  )

;; Fix comments in tpl mode

(setq large-file-warning-threshold 500000)

(setq buttercup-color nil)
;; doom-dracula
;; doom-one
;; doom-spacegrey
;; sanityinc-tomorrow-eighties
;; (font-spec :family "JetBrains Mono" :weight 'semibold
;; 									:size 13)

(setq doom-font (font-spec :family "Fira Code" :weight 'normal
		  :size 13))
(setq doom-themes-treemacs-enable-variable-pitch nil)

;; Fira Code
;; Fantasque Sans Mono
;; JetBrains Mono
(load! "configuration/xml-schemas")

(defun adb-logcat ()
  (interactive)
  (start-process "*adb-logcat*" "*adb-logcat*" "/bin/sh" "-c" "adb logcat cz.zdenekhorak.mibandtools:I *:S")
  (pop-to-buffer "*adb-logcat*")
  (buffer-disable-undo))

(setq doom-localleader-key ",")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type nil)

;; Disable show paren mode
(show-paren-mode nil)


;; VSYNC rendering
;; (add-to-list 'default-frame-alist '(inhibit-double-buffering . t))

(defun org-roam-everywhere ()
  (interactive)
  (org-roam-capture))

(defun encode-buffer ()
  (interactive))

(setq require-final-newline nil)

(setq which-key-idle-delay 0.3)
(setq company-tooltip-idle-delay 0.3)
(setq company-idle-delay 0.5)

(defun insert-iso-date () (interactive)
  (insert (shell-command-to-string "echo -n $(date +\"%Y-%m-%dT%H:%M:%S%z\")")))

;; TODO fix in nixos
(setq browse-url-browser-function 'browse-url-generic
  browse-url-generic-program "zen")

(setq indent-tabs-mode t)


(load! "map.el")
(load! "~/Dropbox/emacs/ssh.el" nil t)
(load! "util.el")
(mapc 'load (file-expand-wildcards "~/.doom.d/package_configuration/*/*.el"))
(setq +evil-want-o/O-to-continue-comments nil)

;; patch to emacs@28.0.50
;; https://www.reddit.com/r/emacs/comments/kqd9wi/changes_in_emacshead2828050_break_many_packages/
;; (defmacro define-obsolete-function-alias ( obsolete-name current-name
;; 					   &optional when docstring)
;;   "Set OBSOLETE-NAME's function definition to CURRENT-NAME and mark it obsolete.
;; \(define-obsolete-function-alias \\='old-fun \\='new-fun \"22.1\" \"old-fun's doc.\")
;; is equivalent to the following two lines of code:
;; \(defalias \\='old-fun \\='new-fun \"old-fun's doc.\")
;; \(make-obsolete \\='old-fun \\='new-fun \"22.1\")
;; WHEN should be a string indicating when the function was first
;; made obsolete, for example a date or a release number.
;; See the docstrings of `defalias' and `make-obsolete' for more details."
;;   (declare (doc-string 4)
;;     (advertised-calling-convention
;;       ;; New code should always provide the `when' argument
;;       (obsolete-name current-name when &optional docstring) "23.1"))
;;   `(progn
;;      (defalias ,obsolete-name ,current-name ,docstring)
;;      (make-obsolete ,obsolete-name ,current-name ,when)))

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
  )
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.

  '(web-mode-block-face ((t nil))))
