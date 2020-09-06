;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

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

(set-face-foreground 'font-lock-comment-face "red")

(setq org-directory "~/org/")


;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

(setq which-key-idle-delay 0.20)

(after! treemacs
  (treemacs-follow-mode t))

;; set indentation to tabs instead of spaces
(setq indent-tabs-mode t)

(load! "map.el")
(mapc 'load (file-expand-wildcards "~/.doom.d/overrides/*.el"))
(mapc 'load (file-expand-wildcards "~/.doom.d/package_configuration/*.el"))
(mapc 'load (file-expand-wildcards "~/.doom.d/packages/*/*.el"))

(add-to-list 'auto-mode-alist '("\\.cshtml$" . web-mode))
(add-to-list 'auto-mode-alist '("\\.csproj$" . xml-mode))

(after! lsp-mode
  (setq lsp-mode-hook
        (remq '+lsp-init-company-h lsp-mode-hook)))

(after! omnisharp
  (set-company-backend! 'omnisharp-mode
    '(company-omnisharp :with company-yasnippet)))

(setq-default company-backends '((company-yasnippet :separate company-capf)))


(setq company-tooltip-idle-delay 0.1)
(setq company-idle-delay 0.1)

(after! sh-script
  (set-company-backend! 'sh-mode
    '(company-shell :with company-yasnippet)))


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
