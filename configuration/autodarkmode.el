;;; editors/.doom.d/configuration/autodarkmode.el -*- lexical-binding: t; -*-
(require 'dbus)
(defun get-color-scheme ()
  (car (car (condition-case nil
							(dbus-call-method :session "org.freedesktop.portal.Desktop" "/org/freedesktop/portal/desktop" "org.freedesktop.portal.Settings"  "Read" :timeout 1000 "org.freedesktop.appearance" "color-scheme")
							(dbus-error '((1)))))))

(defun theme--handle-dbus-event (a setting values)
  "Handler for FreeDesktop theme changes."
  (when (string= setting "color-scheme")
    (let ((scheme (car values)))
      (cond
        ((= 1 scheme)
	  (use-package doom-themes
	    :custom-face
	    (font-lock-comment-face ((t (:foreground "red"))))
	    ;; DRACULA
	    (+org-todo-active    ((t (:background "#1E2029"))))
	    (+org-todo-cancel    ((t (:background "#1E2029"))))
	    (+org-todo-onhold    ((t (:background "#1E2029"))))
	    (+org-todo-project    ((t (:background "#1E2029"))))
	    (org-todo    ((t (:background "#1E2029"))))
			(org-done    ((t (:background "#1E2029"))))
	    (window-divider   ((t (:foreground "#1E2029" :background "#1E2029"))))
	    (solaire-default-face   ((t (:background "#1E2029"))))
	    (internal-border   ((t (:foreground "#1E2029" :background "#1E2029"))))
	    (doom-nano-modeline-evil-emacs-state-face    ((t ())))
	    (doom-nano-modeline-evil-insert-state-face  ((t ())))
	    (doom-nano-modeline-evil-motion-state-face  ((t ())))
	    (doom-nano-modeline-evil-normal-state-face  ((t ())))
	    (doom-nano-modeline-evil-operator-state-face((t ())))
	    (doom-nano-modeline-evil-replace-state-face ((t ())))
	    (doom-nano-modeline-evil-visual-state-face  ((t ())))
	    (doom-nano-modeline-inactive-face           ((t ())))
	    :config
	    (setq doom-themes-enable-bold nil)
	    (load-theme +dark-theme+ t)
	    )
          (load-theme +dark-theme+ t)

	  ) ;; my custom function that sets a dark theme
        ((= 2 scheme)
          ;; (load-theme +light-theme+ t)
	  (use-package doom-themes
	    :custom-face
	    (font-lock-comment-face ((t (:foreground "red"))))
	    ;; NORD
	    (internal-border   ((t (:foreground "#c3d0e1" :background "#c3d0e1"))))
	    (window-divider   ((t (:foreground "#c3d0e1" :background "#c3d0e1"))))
	    (solaire-default-face  ((t (:inherit 'default :background "#c3d0e1" ))))
	    (+org-todo-active    ((t (:background "#E5E9F0"))))
	    (+org-todo-cancel    ((t (:background "#E5E9F0"))))
	    (+org-todo-onhold    ((t (:background "#E5E9F0"))))
	    (+org-todo-project    ((t (:background "#E5E9F0"))))
	    (org-todo    ((t ( :background "#E5E9F0"))))
			(org-done    ((t ( :background "#E5E9F0"))))
	    (doom-nano-modeline-evil-emacs-state-face    ((t (:foreground "#FFFFFF" :background "#90A4AE"))))
	    (doom-nano-modeline-evil-insert-state-face   ((t (:foreground "#FFFFFF" :background "#FFAB91"))))
	    (doom-nano-modeline-evil-motion-state-face   ((t (:foreground "#FFFFFF" :background "#90A4AE"))))
	    (doom-nano-modeline-evil-normal-state-face   ((t (:foreground "#FFFFFF" :background "#90A4AE"))))
	    (doom-nano-modeline-evil-operator-state-face ((t (:foreground "#FFFFFF" :background "#90A4AE"))))
	    (doom-nano-modeline-evil-replace-state-face  ((t (:foreground "#FFFFFF" :background "#FF6F00"))))
	    (doom-nano-modeline-evil-visual-state-face   ((t (:foreground "#FFFFFF" :background "#673AB7"))))
	    (doom-nano-modeline-inactive-face            ((t (:foreground "#90A4AE" :background "#E5E9F0"))))

	    :config
	    (setq doom-themes-enable-bold nil)
	    (load-theme +light-theme+ t)
	    )
	  ) ;; 1000 internet points to whoever guesses what this does
        (t (message "I don't know how to handle scheme: %s" scheme))))))

(dbus-register-signal :session
  "org.freedesktop.portal"
  "/org/freedesktop/portal/desktop"
  "org.freedesktop.impl.portal.Settings"
  "SettingChanged"
  #'theme--handle-dbus-event)

