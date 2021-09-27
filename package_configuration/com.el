;;; package_configuration/com.el -*- lexical-binding: t; -*-


(set-popup-rule! "^\\*ttyUSB0" :side 'bottom :size 0.25)
(defun start-com ()
  (interactive)
	(require 'eshell)
  (let ((process-name "COM USB")
	 (process-buffer "*ttyUSB0*"))
    (when (buffer-live-p (get-buffer process-buffer))
      (kill-buffer process-buffer))
    (with-current-buffer (get-buffer-create process-buffer)
      (set (make-local-variable 'eshell-last-input-start) (point-marker))
      (set (make-local-variable 'eshell-last-input-end) (point-marker))
      (set (make-local-variable 'eshell-last-output-start) (point-marker))
      (set (make-local-variable 'eshell-last-output-end) (point-marker))
      (set (make-local-variable 'eshell-last-output-block-begin) (point)))
    (make-process
      :name process-name
      :buffer (get-buffer-create process-buffer)
      :command '("com" "/dev/ttyUSB0" "115200")
      :filter  (lambda (proc string)
		 (when (buffer-live-p (process-buffer proc))
		   (with-current-buffer (process-buffer proc)
		     (let ((moving (= (point) (process-mark proc))))
		       (save-excursion
			 (goto-char (process-mark proc))
			 (let ((inhibit-read-only t))
			   (eshell-output-filter proc string))
			 (set-marker (process-mark proc) (point)))
		       (if moving (goto-char (process-mark proc)))))))
      )
    (display-buffer process-buffer)))
