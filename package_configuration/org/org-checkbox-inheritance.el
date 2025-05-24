;;; nixos/editors/.doom.d/package_configuration/org/org-checkbox-inheritance.el -*- lexical-binding: t; -*-

(defadvice org-list-struct-fix-box (around md/noop last activate)
    "Turn org-list-struct-fix-box into a no-op.

By default, if an org list item is checked using the square-bracket
syntax [X], then org will look for a parent checkbox, and if all child items are
checked, it will set [X] on the parent too. This isn't how I personally use
child items -- I'll often use child checkboxes as subtasks, but it's almost
never an exhaustive list of everything that has to be done to close out the
parent -- and so I'd prefer to just control the parent checkbox state manually.

AFAICT org-mode doesn't provide a way to customise this behaviour, /but/ the
behaviour all seems to be implemented in 'org-list-struct-fix-box'. And so I'm
trying something out by turning it into a no-op. It seems to work nicely initially,
but I won't be surprised if it causes an issue at some point because it's very
hacky."
nil)
