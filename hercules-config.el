;;; ~/.doom.d/hydra-config.el -*- lexical-binding: t; -*-


;; (defhydra hydra-paste (:color red
;;                        :hint nil)
;;   "\n[%s(length kill-ring-yank-pointer)/%s(length kill-ring)] \
;;  [_C-j_/_C-k_] cycles through yanked text, [_p_/_P_] pastes the same text \
;;  above or below. Anything else exits."
;;   ("C-j" evil-paste-pop)
;;   ("C-k" evil-paste-pop-next)
;;   ("p" evil-paste-after)
;;   ("P" evil-paste-before))

(general-def
  :prefix-map 'custom-paste-map
  "C-j" #'evil-paste-pop-next
  "C-k" #'evil-paste-pop)

(hercules-def
 :show-funs '(evil-paste-after evil-paste-before)
 :keymap 'custom-paste-map
 :transient t)
