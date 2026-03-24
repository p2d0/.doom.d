# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Doom Emacs configuration managed as a NixOS module. The config lives at `/etc/nixos/modules/nixos/editors/.doom.d/` and is symlinked to `~/.doom.d/` — both paths refer to the same files.

## Running tests

Tests use **buttercup** (BDD framework). There is no shell script runner; tests are run via `emacsclient`:

```elisp
;; Run a specific test file (reset suites first to avoid accumulation from prior runs)
(progn
  (setq buttercup-suites nil)
  (load-file "/home/andrew/.doom.d/package_configuration/gptel/test/test-zai-edit.el")
  (my-zai-test--load-deps)   ;; load deps if the test file defines this helper
  (buttercup-run))
```

From the shell:
```bash
emacsclient --eval "(progn (setq buttercup-suites nil) (require 'buttercup) (load-file \"/home/andrew/.doom.d/package_configuration/MODULE/test/test-FILE.el\") (buttercup-run))"
```

Test files live in `MODULE/test/` or `MODULE/tests/` subdirectories. `buttercup-suites` accumulates across loads in a live session — always reset it before running.

## How modules are loaded

`config.el` line 189 glob-loads every `.el` file one level deep under `package_configuration/`:

```elisp
(mapc 'load (file-expand-wildcards "~/.doom.d/package_configuration/*/*.el"))
```

There is no explicit require chain — dropping a `.el` file into any `package_configuration/SUBDIR/` directory is sufficient for it to be loaded on next Doom restart. Files in `test/` subdirs are **not** auto-loaded (they're two levels deep).

## Architecture of `gptel/` (the most active module)

The gptel directory is a suite of AI editing tools, each handling a different LLM output format:

| File | Purpose |
|------|---------|
| `gptel_2.el` | Backend config: OpenRouter + z.ai via `gptel-make-openai` |
| `cursor.el` | `C-k` inline streaming edits; `SPC ae` context export |
| `aider_search.el` | Parse/apply Aider `<<<<<<< SEARCH / >>>>>>> REPLACE` blocks via ediff |
| `aider_udiff.el` | Parse/apply unified diff (`@@ ... @@`) blocks via ediff |
| `aider_whole.el` | Parse/apply whole-file fenced replacements via ediff |
| `zai_edit.el` | Send buffer to z.ai (glm-4.7), get S/R blocks back, feed into aider_search pipeline |
| `gptel-dired.el` | Dired integration for managing gptel context files |

All "aider" apply functions use the same pattern: parse → clone buffer → apply hunks → `ediff-buffers` → cleanup hook chains the next file.

### Adding a new LLM backend

```elisp
(gptel-make-openai "NAME"
  :host "HOST"
  :endpoint "/path/to/chat/completions"
  :stream t   ;; or nil if you need the full response before processing
  :key (lambda () (with-temp-buffer (insert-file-contents "~/key-file") (string-trim (buffer-string))))
  :models '(model-name))
```

API keys are stored as plain text in files (`.env` for OpenRouter, `~/Dropbox/zai.txt` for z.ai) and read at call time via `insert-file-contents`.

## Doom Emacs patterns used throughout

**Keybindings** — always use `map!`, never `global-set-key`:
```elisp
(map! "C-k" #'my-fn)               ;; global
(map! :n "C-k" #'my-fn)            ;; normal mode
(map! :i "C-k" #'my-fn)            ;; insert mode
(map! (:leader (:n "az" #'my-fn))) ;; SPC az in normal mode
(map! :map some-mode-map :n "q" #'quit-window)
```

**Deferred loading** — wrap anything that depends on a package in `after!`:
```elisp
(after! gptel
  (setq gptel-model 'some-model))
```

**Lexical binding** — every file must start with:
```elisp
;;; path/to/file.el -*- lexical-binding: t; -*-
```

## Test file conventions

```elisp
;; Capture test dir at load-time (load-file-name is nil when called from buttercup-run)
(defvar my-module-test-dir (file-name-directory load-file-name))

(defun my-module-test--load-deps ()
  (load-file (expand-file-name "../module.el" my-module-test-dir)))

(describe "suite name"
  (before-all (my-module-test--load-deps))
  (it "does something"
    (expect (my-fn "input") :to-equal "expected")))
```

The `load-file-name` trick is required because `before-all` runs lazily during `buttercup-run`, at which point `load-file-name` is `nil`.
