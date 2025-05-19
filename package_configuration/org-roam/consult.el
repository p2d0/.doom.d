;;; nixos/editors/.doom.d/package_configuration/org-roam/consult.el -*- lexical-binding: t; -*-

(use-package consult-org-roam
  :ensure t
  :after org-roam
  :init
  (require 'consult-org-roam)
  ;; Activate the minor mode
  (consult-org-roam-mode 1)
  :custom
  ;; Use `ripgrep' for searching with `consult-org-roam-search'
  (consult-org-roam-grep-func #'consult-ripgrep)
  ;; Configure a custom narrow key for `consult-buffer'
  (consult-org-roam-buffer-narrow-key ?r)
  ;; Display org-roam buffers right after non-org-roam buffers
  ;; in consult-buffer (and not down at the bottom)
  (consult-org-roam-buffer-after-buffers t)
  :config
  ;; Eventually suppress previewing for certain functions
  (consult-customize
    consult-org-roam-forward-links
    :preview-key "M-.")
  ;; :bind
  ;; ;; Define some convenient keybindings as an addition
  ;; ("C-c n e" . consult-org-roam-file-find)
  ;; ("C-c n b" . consult-org-roam-backlinks)
  ;; ("C-c n B" . consult-org-roam-backlinks-recursive)
  ;; ("C-c n l" . consult-org-roam-forward-links)
  ;; ("C-c n r" . consult-org-roam-search)
	)
(defvar consult--current-node "")

(defvar consult--previous-point nil
  "Location of point before entering minibuffer.
Used to preselect nearest headings and imenu items.")

(defvar vertico--previous-input nil
  "Previous vertico input so we can distinguish whether user is changing input string.")

(defun consult--set-previous-point (&rest _)
  "Save location of point. Used before entering the minibuffer."
  (setq vertico--previous-input nil)
	(setq consult--previous-cand (consult--vertico-candidate))
  (setq consult--previous-point (point)))

(defun consult--set-current-node (&rest _)
	"Save location of point. Used before entering the minibuffer."
	(if (org-roam-buffer-p)
		(setq consult--current-node (org-roam-node-id (org-roam-node-at-point)))))

;; (advice-add #'consult-org-heading :before #'consult--set-previous-point)
;; (advice-add #'consult-outline :before #'consult--set-previous-point)
;; (advice-add #'my/org-roam-find-node-custom :after #'consult--set-current-node)

;; (add-hook 'org-roam-find-file-hook #'consult--set-current-node -100)
(add-hook 'window-selection-change-functions #'consult--set-current-node)

(advice-add #'vertico--update :after #'consult-vertico--update-choose)

(defun consult-vertico--update-choose (&rest _)
  "Pick the nearest candidate rather than the first after updating candidates."
  (when (and (memq current-minibuffer-command
               '(consult-org-heading consult-outline my/org-roam-find-node-custom consult-org-roam-search))
					(or (not (boundp 'repositioned)) (not (equal vertico--input vertico--previous-input)))
					)
    (setq vertico--previous-input (copy-tree vertico--input))
    (let* ((pos (seq-position vertico--candidates 0
									(lambda (cand index)
										(cl-case current-minibuffer-command
											(my/org-roam-find-node-custom
												(when (org-roam-node-id (get-text-property 0 'node cand))
													(s-equals? consult--current-node (org-roam-node-id (get-text-property 0 'node cand))))))))))
			(when (< (or pos 0) (length vertico--candidates))
				(setq vertico--index (or pos 0))
				(setq-local repositioned t)
				)
			)))

(after! consult-org-roam
	(map!
		:leader "nrS" #'org-roam-db-sync
		:leader "nrs" #'consult-org-roam-search
		:leader "nrb" #'consult-org-roam-backlinks
		)

	)

(defun my/org-roam-remove-category (node)
	(not (s-contains? "daily/" (org-roam-node-file node))))

(defun my/org-roam-find-node-custom()
	(interactive)
	(org-roam-node-find nil nil 'my/org-roam-remove-category))

(map! :leader :desc "Roam Nodes" "nrf" #'my/org-roam-find-node-custom)
