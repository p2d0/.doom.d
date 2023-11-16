;;; editors/.doom.d/package_configuration/run-command/run-command.el -*- lexical-binding: t; -*-
;; Examples
;; ls[lulz]
;; https://github.com/bard/emacs-run-command/tree/master/examples
;; Replacing path
;; :command-line "ls -al | sed 's/bashrc//'" NOTE Doesnt work
;; (setq directory-abbrev-alist '(("/var/www/html" . "..."))) NOTE Works
;; DOCKER:
;; :command-line
;; (lambda ()
;;   (setq directory-abbrev-alist '(("/var/www/html" . "...")))
;;   "...")
;;  CACHING:


(defvar run-command--last nil)
(defvar run-command-recipe-dir-locals-fn nil)


(defun run-command-recipe-dir-locals ()
  (when run-command-recipe-dir-locals-fn
    (funcall run-command-recipe-dir-locals-fn)))

(load! "run-command-recipe-package-json.el")
(load! "run-command-recipes.el")

                                        ; Run a script from the project's package.json file. Supports both npm and yarn.
                                        ; Run package.json scripts END

(defun run-command-rerun ()
  (interactive)
  (when run-command--last
    (setq-local run-command--rerun t)
    (run-command-core-run run-command--last)))

(defun docker-example-recipe ()
  (list
    (list :command-name "pwd inside docker container"
      ;; should return /
      ;; but returns my home folder with term
      :command-line "pwd"
      :working-dir "/docker:example1:/"
      )
    )
  )

(defun run-command--cache (orig command-spec)
  (setq cache-variables (plist-get  command-spec :cache-variables))
	(apply orig (list command-spec))
	(setq cache-variables nil)
  (setq run-command--last command-spec))
(defun eat--clear-buffer (&rest args)
	(erase-buffer)
	)

(defun eat--scroll-down (&rest args)
	(set-window-point (get-buffer-window (current-buffer)) (point-max)))

(after! run-command
  ;; (require 'term)
  (add-hook! 'eat-exit-hook #'compilation-minor-mode)
	(add-hook! 'eat-exit-hook #'eat--scroll-down)
	(add-hook! 'eat-exec-hook #'eat--clear-buffer)
  (setq run-command-default-runner 'run-command-runner-eat)
  (setq shell-file-name "/bin/sh")
  (advice-add #'run-command-core-run :around #'run-command--cache
    )
  ;; *rebuild-default[/etc/nixos/modules/nixos/editors/.doom.d/package_configuration/run-command/]*
  ;; (advice-add #'run-command-core-run :after (lambda (command-spec) (setq run-command--last command-spec)))
  ;; *rebuild-default[/etc/nixos/]*
  ;; *rebuild-default[/etc/nixos/modules/nixos/editors/.doom.d/package_configuration/run-command/]*
  (set-popup-rule! "*.+\\[.+\\]*"
    :size 20
    :quit t)
  ;; (set-popup-rule! "^.+\\[.+\\]$"
  ;;   :size 16
  ;;   :quit t)
  (setq run-command-recipes '(build-nix-file-recipe run-command-recipe-dir-locals run-command-recipe-package-json)))

(map!
  :leader
  "cc" #'run-command
  "cC" #'run-command-rerun
  )
