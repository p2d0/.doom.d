;;; package_configuration/dap-mode.el -*- lexical-binding: t; -*-

(require 'dap-netcore)
(after! dap-netcore
	(defun dap-netcore--populate-args (conf)
		"Populate CONF with arguments to launch or attach netcoredbg."
		(dap--put-if-absent conf :dap-server-path (list (dap-netcore--debugger-locate-or-install) "--interpreter=vscode"))
		(when (s-equals? (plist-get conf :program) "dotnet")
			(plist-put conf :program (seq-first (plist-get conf :args) ))
			(dap--put-if-absent conf :mode "launch")
			)
		(pcase (plist-get conf :mode)
			("launch"
				(dap--put-if-absent
					conf
					:program
					(let ((project-dir (f-full
															 (or
																 (dap-netcore--locate-dominating-file-wildcard
																	 default-directory "*.*proj")
																 (lsp-workspace-root)))))
						(save-mark-and-excursion
							(find-file (concat (f-slash project-dir) "*.*proj") t)
							(let ((res (if (libxml-available-p)
													 (libxml-parse-xml-region (point-min) (point-max))
													 (xml-parse-region (point-min) (point-max)))))
								(kill-buffer)
								(f-join project-dir "bin" "Debug"
									(dom-text (dom-by-tag res 'TargetFramework))
									(dom-text (dom-by-tag res 'RuntimeIdentifier))
									(concat (car (-take-last 1 (f-split project-dir))) ".dll")))))))
			("attach"
				(dap--put-if-absent conf :processId (string-to-number (read-string "Enter PID: " "2345")))))))
;; (require 'dap-firefox)

;; (defun dap-repl-eval-region (start end)
;;   (interactive "r")
;;   (dap-ui-input-sender "" (buffer-substring-no-properties start end)))

;; ;; (defun dap-eval-thing-at-point ()
;; ;;   "Eval and print EXPRESSION."
;; ;;   (interactive)
;; ;;   (dap-eval (thing-at-point 'symbol)))


(after! dap-variables
	(push '("\\`workspaceRoot\\'" . dap-variables-project-root)
		dap-variables-standard-variables))

(after! dap-mode
	(setq dap-netcore-install-dir (f-join user-emacs-directory ".cache" "lsp"))
	(setq dap-netcore-download-url "https://github.com/Samsung/netcoredbg/releases/download/3.1.2-1054/netcoredbg-linux-amd64.tar.gz")
	(setq dap-output-buffer-filter nil)
	(setq dap-python-debugger 'debugpy)
	(setq dap-ui-controls-mode nil)
	;; (setq dap-ui-buffer-configurations
	;; 	`((,dap-ui--locals-buffer . ((side . left) (slot . 1) (window-width . 0.20)))
	;; 		 (,dap-ui--expressions-buffer . ((side . left) (slot . 2) (window-width . ,treemacs-width)))
	;; 		 ;; (,dap-ui--sessions-buffer . ((side . right) (slot . 3) (window-width . 0.20)))
	;; 		 (,dap-ui--breakpoints-buffer . ((side . left) (slot . 3) (window-width . ,treemacs-width)))
	;; 		 ;; (,dap-ui--debug-window-buffer . ((side . bottom) (slot . 3) (window-width . 0.20)))
	;; 		 (,dap-ui--repl-buffer . ((side . right) (slot . 0) (window-width . 0.3)))))
	(setopt dap-ui-controls-screen-position 'posframe-poshandler-frame-top-right-corner)
	(setq dap-auto-configure-features '(repl locals expressions breakpoints))
	(setopt dap-auto-show-output t)

	(advice-add 'dap-ui-controls-mode :override #'ignore)

	(dap-register-debug-template
		"Php Debug appointments"
		(list :type "php"
			:request "launch"
			:name "Php Debug"
			:pathMappings (ht ("/var/www/html" "/mnt/md127/favoka2/prestashop_data/prestashop"))
			:sourceMaps t))
	(dap-register-debug-template "Rust::GDB Attach Configuration"
		(list :type "gdb"
			:request "attach"
			:executable "/nix/store/c8vs0m3pb43imkcbikg6q87wgmym95x4-rustlings/bin/rustlings"
			:name "GDB::Run"
			:gdbpath "rust-gdb"
			:target "103955"
			))
	)

;; ;; TODO fix tooltip
;; (after! dap-mode
;;   (defvar-local dap-tooltip--bounds nil)
;;   (defun dap-tooltip-at-point (&optional pos)
;;     "Show information about the variable under point.
;; The result is displayed in a `treemacs' `posframe'. POS,
;; defaulting to `point', specifies where the cursor is and
;; consequently where to show the `posframe'."
;;     (interactive)
;;     (let ((debug-session (dap--cur-session))
;; 	   (mouse-point (or pos (point))))
;;       (when (and (dap--session-running debug-session)
;; 	      mouse-point)
;; 	(-when-let* ((active-frame-id (-some->> debug-session
;; 					dap--debug-session-active-frame
;; 					(gethash "id")))
;; 		      (bounds (dap-tooltip-thing-bounds mouse-point))
;; 		      ((start . end) bounds)
;; 		      (expression (s-trim (buffer-substring start end))))
;; 	  (unless (equal dap-tooltip--bounds bounds)
;; 	    (dap--send-message
;; 	      (dap--make-request "evaluate"
;; 		(list :expression expression
;; 		  :frameId active-frame-id
;; 		  :context "hover"))
;; 	      (dap--resp-handler
;; 		(-lambda ((&hash "body" (&hash? "result"
;; 					  "variablesReference" variables-reference)))
;; 		  (setq dap--tooltip-overlay
;; 		    (-doto (make-overlay start end)
;; 		      (overlay-put 'mouse-face 'dap-mouse-eval-thing-face)))
;; 		  (setq dap-tooltip--bounds bounds)
;; 		  ;; Show a dead buffer so that the `posframe' size is consistent.
;; 		  (when (get-buffer dap-mouse-buffer)
;; 		    (kill-buffer dap-mouse-buffer))
;; 		  (unless (and (zerop variables-reference) (string-empty-p result))
;; 		    ;; (apply #'display-buffer dap-mouse-buffer
;; 		    ;;  :position start
;; 		    ;;  ;; :accept-focus t
;; 		    ;;  dap-mouse-posframe-properties)
;; 		    (with-current-buffer (get-buffer-create dap-mouse-buffer)
;; 		      (dap-ui-render-value debug-session expression
;; 			result variables-reference))
;; 		    (display-buffer dap-mouse-buffer)
;; 		    )
;; 		  )
;; 		;; TODO: hover failure will yield weird errors involving process
;; 		;; filters, so I resorted to this hack; we should proably do proper
;; 		;; error handling, with a whitelist of allowable errors.
;; 		#'ignore)
;; 	      debug-session) )))))

;;   (setq! dap-mouse-posframe-properties
;;     (list :min-width 100
;;       :internal-border-width 2
;;       :internal-border-color (face-attribute 'tooltip :background)
;;       :accept-focus t
;;       :min-height 10))

;;   (setq! dap-tooltip-echo-area t)
;;   (set-popup-rule! "^\\*dap-mouse\\*" :side 'bottom :size 0.3 :select 1)
;;   (set-popup-rule! "^\\*dap-ui-repl\\*" :side 'bottom :size 0.3 :select 1)

;;   ;; (add-hook 'dap-tooltip-mode-hook
;;   ;;     (lambda ()
;;   ;;       (add-hook 'dap-terminated-hook (lambda (&rest args) (dap-tooltip-post-tooltip)) nil t)
;;   ;;       (add-hook 'post-command-hook 'dap-tooltip-at-point nil t)))
;;   )
