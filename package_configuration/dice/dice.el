;;; nixos/editors/.doom.d/package_configuration/dice/dice.el -*- lexical-binding: t; -*-

(require 'seq)

(defun my/org-roam-dice (start end)
  "Select a random item from the current region with a slot-machine effect.
The function parses lines in the visual selection, animates a 'rolling'
process in the echo area, and finally moves point to the winning item."
  (interactive "r")
  (let* ((text (buffer-substring-no-properties start end))
         ;; Split into lines and remove empty ones
         (lines (seq-filter 
                 (lambda (l) (not (string-blank-p l)))
                 (split-string text "\n" t)))
         (count (length lines))
         (cycles (+ 15 (random 10))) ;; Randomize total spins (15-25)
         (winner-idx (random count)))

    (if (= count 0)
        (message "No items found in selection!")
      
      ;; 1. The "Gambling Machine" Animation Loop
      (dotimes (i cycles)
        (let* ((current-idx (mod i count)) ;; Cycle through items sequentially
               (item (nth current-idx lines))
               ;; Calculate delay: starts fast (0.05s), ends slow (0.4s)
               (progress (/ (float i) cycles))
               (delay (+ 0.05 (* 0.35 (expt progress 3))))) 
          
          ;; Display the "spinning" reel
          (message "🎰 Rolling... [%s] %s" 
                   (make-string (1+ (random 3)) ?.) ;; Little visual noise
                   (string-trim item))
          (sit-for delay)))

      ;; 2. Final Result Processing
      (let ((winning-line (nth winner-idx lines)))
        ;; Flash the winner
        (message "🎉 WINNER: %s" (string-trim winning-line))
        
        ;; Move cursor to the winning line in the buffer
        (goto-char start)
        (search-forward winning-line end t)
        (beginning-of-line)
        ;; Optional: Pulse the line for visual emphasis
        (when (fboundp 'pulse-momentary-highlight-one-line)
          (pulse-momentary-highlight-one-line (point)))))))

(require 'seq)

;; 1. Define custom faces for the visual effect
(defface my/dice-rolling-face
  '((t :background "#FFd700" :foreground "#FFd700" :weight bold))
  "Face used for the item currently being 'rolled' over.")

(defface my/dice-winner-face
  '((t :background "#FFd700" :foreground "white" :weight extra-bold :box t))
  "Face used for the winning item.")

(custom-set-faces!
 '(my/dice-rolling-face (t (:background "#FFd700" :foreground "#FFd700" :weight bold)))
 '(my/dice-winner-face (t (:background "#FFd700" :foreground "#FFd700" :weight extra-bold :box t)))
	)

(after! org-roam 
(map! :map org-mode-map :localleader :v "d" #'my/org-roam-dice-visual)
	)

(defun my/org-roam-dice-visual (start end)
  "Run a visual slot machine selection on lines in the region."
  (interactive "r")
  (let* ((text (buffer-substring-no-properties start end))
         ;; Calculate line positions relative to buffer
         (line-positions 
          (save-excursion
            (goto-char start)
            (let (positions)
              (while (< (point) end)
                (let ((line-start (line-beginning-position))
                      (line-end (line-end-position)))
                  (unless (string-blank-p (buffer-substring line-start line-end))
                    (push (cons line-start line-end) positions)))
                (forward-line 1))
              (nreverse positions))))
         (count (length line-positions)))
    
    (if (= count 0)
        (message "No items found!")
      
      ;; Create the overlay we will move around
      (let ((ov (make-overlay (point) (point)))
            (cycles (+ 15 (random 10))) ;; 15 to 25 spins
            (winner-idx (random count)))
        
        ;; Set initial rolling appearance
        (overlay-put ov 'face 'my/dice-rolling-face)
        
        ;; 2. The Animation Loop
        (dotimes (i cycles)
          (let* ((current-idx (mod i count))
                 (pos (nth current-idx line-positions))
                 ;; Ease-out math: start fast (0.05s), end slow (0.35s)
                 (progress (/ (float i) cycles))
                 (delay (+ 0.05 (* 0.30 (expt progress 4)))))
            
            ;; Move overlay to current line
            (move-overlay ov (car pos) (cdr pos))
            (sit-for delay))) ;; Force redisplay and wait

        ;; 3. Handle the Winner
        (let ((win-pos (nth winner-idx line-positions)))
          ;; Move overlay to winner and change to WINNER face
          (move-overlay ov (car win-pos) (cdr win-pos))
          (overlay-put ov 'face 'my/dice-winner-face)
          
          ;; Move actual cursor to the line
          (goto-char (car win-pos))
          
          ;; Keep the winner highlighted for 2 seconds, then delete overlay
          (sit-for 2.0)
          (delete-overlay ov))))))
