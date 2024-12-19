;;; nixos/editors/.doom.d/package_configuration/org-roam/daily.el -*- lexical-binding: t; -*-

(describe "get-text-before-first-heading"
  (it "should get the heading before"
    (set-buffer (find-file-noselect "~/Dropbox/org/roam/daily/2024-12-19.org"))
    (let ((expected-text "=NOTICE I'LL BE INEFFICIENT, IF ONLY I HAD BETTER SLEEP QUALITY=\nCAREFUL ABOUT MOVING =GOALPOSTS= SOMEONE WHO SUCCEEDS SOMETIMES AND FAILS SOMETIMES\nDONT DEVALUE SMALL ACCOMPLISHMENTS\n=ACKNOWLEDGE= and possibly =APPRECIATE= others successes and advices and other stuff.\nlower your expectations of other people\n"))
      (expect (get-text-before-first-heading) :to-match expected-text)
      )
    )
  )
