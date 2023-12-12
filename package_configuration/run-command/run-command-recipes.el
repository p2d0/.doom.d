;;; nixos/editors/.doom.d/package_configuration/run-command/run-command-recipes.el -*- lexical-binding: t; -*-


(defun build-nix-file-recipe ()
  (list
    (list
      :command-name "Build nix file"
      :display "Build nix file"
      :cache-variables `(:name ,(file-relative-name (buffer-file-name) ))
      :command-line (lambda ()
                      "test"
                      (format "nix-build %s" (plist-get cache-variables :name)))
      )
    )
  )

(defun build-nix-with-flake-recipe ()
  (list
    (list
      :command-name "Build nix with flake file"
      :display "Build nix with flake file"
      :cache-variables `(:name ,(file-relative-name (buffer-file-name) ))
      :command-line (lambda ()
                      "test"
                      (format "nix-build %s" (plist-get cache-variables :name)))
      )
    )
  )
