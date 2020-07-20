;; Disable evil-snipe F backwards with ,
(map! :map evil-snipe-parent-transient-map
      "," nil)

;; Map to : instead of ,
(map! :map evil-snipe-override-local-mode-map
      :m ":" #'evil-snipe-repeat-reverse)
