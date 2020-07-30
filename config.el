;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Andrew Cerkin"
      user-mail-address "cerkin-3@yandex.ru")

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


(setq doom-font (font-spec :family "Fira Code" :size 15))
(setq doom-theme 'doom-one)

(setq doom-localleader-key ",")

(map! :leader
      :desc "Switch to previous buffer" "TAB" #'evil-switch-to-windows-last-buffer
      "`" nil)

(map! :v "s" #'evil-surround-region)

;; (add-to-list 'default-frame-alist '(fullscreen . fullscreen))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)
(setq which-key-idle-delay 0.15)

(after! treemacs
  (treemacs-follow-mode t))



;; set indentation to tabs instead of spaces
(setq indent-tabs-mode t)

(map! "M-p" #'counsel-yank-pop)
(map! :leader "0" #'treemacs-select-window)

(map! :localleader
			:map omnisharp-mode-map
      :prefix "r"
       "r" #'omnisharp-run-code-action-refactoring)

(map! :localleader
			:map omnisharp-mode-map
      :prefix "r"
      "R" #'omnisharp-rename)

(map! :leader
			"/" #'+default/search-project)


(load! "evil-snipe-config.el")
(load! "file-templates-config.el")
(load! "flycheck-config.el")
(load!  "magit-config.el")
(load! "winum-config.el")
(load! "evil-iedit-config.el")
(load! "hercules-config.el")
(load! "treemacs-config.el")

(mapc 'load (file-expand-wildcards "~/.doom.d/overrides/*.el"))
;; (winum-set-keymap-prefix "SPC")

(setq omnisharp-expected-server-version "1.35.2")
(add-to-list 'auto-mode-alist '("\\.cshtml$" . web-mode))
(add-to-list 'auto-mode-alist '("\\.csproj$" . xml-mode))

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
