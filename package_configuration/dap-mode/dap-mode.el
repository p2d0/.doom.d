;;; package_configuration/dap-mode.el -*- lexical-binding: t; -*-

;; (require 'dap-netcore)
;; (setq dap-auto-configure-features '(sessions locals controls tooltip))
;; (require 'dap-firefox)


(after! dap-mode
  (defvar-local dap-tooltip--bounds nil)
  (defun dap-tooltip-at-point (&optional pos)
    "Show information about the variable under point.
The result is displayed in a `treemacs' `posframe'. POS,
defaulting to `point', specifies where the cursor is and
consequently where to show the `posframe'."
    (interactive)
    (let ((debug-session (dap--cur-session))
	  (mouse-point (or pos (point))))
      (when (and (dap--session-running debug-session)
		 mouse-point)
	(-when-let* ((active-frame-id (-some->> debug-session
					dap--debug-session-active-frame
					(gethash "id")))
		     (bounds (dap-tooltip-thing-bounds mouse-point))
		     ((start . end) bounds)
		     (expression (s-trim (buffer-substring start end))))
	  (unless (equal dap-tooltip--bounds bounds)
	    (dap--send-message
	     (dap--make-request "evaluate"
				(list :expression expression
				      :frameId active-frame-id
				      :context "hover"))
	     (dap--resp-handler
	      (-lambda ((&hash "body" (&hash? "result"
					      "variablesReference" variables-reference)))
		(setq dap--tooltip-overlay
		      (-doto (make-overlay start end)
			(overlay-put 'mouse-face 'dap-mouse-eval-thing-face)))
		(setq dap-tooltip--bounds bounds)
		;; Show a dead buffer so that the `posframe' size is consistent.
		(when (get-buffer dap-mouse-buffer)
		  (kill-buffer dap-mouse-buffer))
		(unless (and (zerop variables-reference) (string-empty-p result))
		  (apply #'posframe-show dap-mouse-buffer
			 :position start
			 :accept-focus t
			 dap-mouse-posframe-properties)
		  (with-current-buffer (get-buffer-create dap-mouse-buffer)
		    (dap-ui-render-value debug-session expression
					 result variables-reference)))
		)
	      ;; TODO: hover failure will yield weird errors involving process
	      ;; filters, so I resorted to this hack; we should proably do proper
	      ;; error handling, with a whitelist of allowable errors.
	      #'ignore)
	     debug-session) )))))

  (setq! dap-mouse-posframe-properties
	 (list :min-width 100
	       :internal-border-width 2
	       :internal-border-color (face-attribute 'tooltip :background)
	       :min-height 10))

  (setq! dap-tooltip-echo-area t)

  (add-hook 'dap-tooltip-mode-hook
	    (lambda ()
	      (add-hook 'dap-terminated-hook (lambda (&rest args) (dap-tooltip-post-tooltip)) nil t)
	      (add-hook 'post-command-hook 'dap-tooltip-at-point nil t)))
  )
