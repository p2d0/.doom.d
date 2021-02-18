;;; package_configuration/dap-mode.el -*- lexical-binding: t; -*-

(require 'dap-netcore)

(setq dap-auto-configure-features '(sessions locals controls tooltip))

(dap-mode 1)

;; The modes below are optional

(dap-ui-mode 1)
;; enables mouse hover support
(dap-tooltip-mode 1)
;; use tooltips for mouse hover
;; if it is not enabled `dap-mode' will use the minibuffer.
(tooltip-mode 1)
;; displays floating panel with debug buttons
;; requies emacs 26+
(dap-ui-controls-mode 1)

(add-hook 'dap-stopped-hook
          (lambda (arg) (call-interactively #'dap-hydra)))


(require 'dap-firefox)
(require 'dap-python)

(defun find-process-by-args (args)
  (seq-find (lambda (val)
	      (string-match-p args (alist-get 'args (process-attributes val)) ))
    (list-system-processes)))

(defun get-dotnet-process-to-attach ()
  (find-process-by-args "dotnet exec.+?\\.dll" ))

(defun get-test-dotnet-process-to-attach ()
  (find-process-by-args "dotnet exec.+?telemetry" ))

(defun +dap-mode/dap-netcore--populate-args (conf)
  "Populate CONF with arguments to launch or attach netcoredbg."
  (dap--put-if-absent conf :dap-server-path (list (dap-netcore--debugger-locate-or-install) "--interpreter=vscode"))
  (pcase (plist-get conf :mode)
    ("attach-to-test"
      (dap--put-if-absent conf :processId (get-test-dotnet-process-to-attach)))
    ("attach"
      (dap--put-if-absent conf :processId (get-dotnet-process-to-attach)))))

(dap-register-debug-provider
 "netcoredebugger"
 '+dap-mode/dap-netcore--populate-args)

(dap-register-debug-template
  "NetCoreDbg::Attach to test dotnet process"
  (list :type "netcoredebugger"
	:environment-variables '(("VSTEST_HOST_DEBUG" . "1"))
        :request "attach"
        :mode "attach-to-test"
        :name "Launch test debug"))

(dap-register-debug-template
  "NetCoreDbg::Attach to dotnet process"
  (list :type "netcoredebugger"
        :request "attach"
        :mode "attach"
        :name "NetCoreDbg::Attach"))
