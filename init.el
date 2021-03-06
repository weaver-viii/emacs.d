(defconst tc/macos-p
  (eq system-type 'darwin)
  "Are we on MacOS?")

(defconst tc/presentation-mode-p
  (getenv "EMACS_PRESENTATION_MODE"))

(defconst tc/presentation-name
  (getenv "EMACS_PRESENTATION_NAME"))

(defconst tc/light-theme-p
  (getenv "EMACS_LIGHT_THEME"))

;; keep customize settings in their own file
(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file 'noerror)

;; setup and use the same path as zsh
(setenv "PATH" (shell-command-to-string "source ~/.path; echo -n $PATH"))
(setq exec-path (append exec-path (split-string (getenv "PATH") ":")))

;; install any needed packages
(load (concat user-emacs-directory "packages"))

;; once packages are loaded and on the load-path, prepend .emacs.d/ and lib/
(add-to-list 'load-path user-emacs-directory)
(add-to-list 'load-path (concat user-emacs-directory "lib"))

;; en/decrypt .gpg files automatically
(require 'epa-file)

;; get rid of ui cruft
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)

(when (display-graphic-p)
  ;; configure settings for use under a wm
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (mouse-wheel-mode t)
  (blink-cursor-mode -1)
  (global-hl-line-mode t)
  (mouse-avoidance-mode 'exile))

;; Split windows in Emacs 22 compatible way
(setq split-height-threshold nil
      split-width-threshold  most-positive-fixnum)

;; reduce the frequency of garbage collection by making it happen on
;; each 50MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold 50000000)

;; use the modeline to indicate the bell instead of sound or a big
;; black block in the middle of the screen (wtf wants that?)
(when (not tc/presentation-mode-p)
  (setq visible-bell t)
  (load "echo-area-bell"))

;; always show the column number in the mode line
(column-number-mode t)

;; save the bookmarks file every time I add one
(setq bookmark-save-flag 0)

;; prefer utf8
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; start with an empty scratch buffer
(setq initial-scratch-message nil
      inhibit-startup-message t)

;; ask if I want to quit
(setq confirm-kill-emacs 'y-or-n-p)

;; store backup files in one dir instead of littering the fs
(setq backup-directory-alist
      (list (cons "." (expand-file-name "backups" user-emacs-directory))))

;; don't create lock files (emacs 24.3 and up)
(setq create-lockfiles nil)

;; save my place in visited files
(require 'saveplace)
(setq save-place-file (concat user-emacs-directory "places"))
(set-default 'save-place t)

;; do a better job of making buffer names unique
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward)

;; Allow y for yes - I type enough as it is
(defalias 'yes-or-no-p 'y-or-n-p)

;; please don't insert tabs
(set-default 'indent-tabs-mode nil)

;; clean up whitespace before saving
(add-hook 'before-save-hook 'whitespace-cleanup)

;; auto-revert any open buffers if they change on disk, and do the
;; same for dired. In both cases, don't tell me every time
(global-auto-revert-mode t)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose                 nil)

;; repeat held down keys afer a tenth of a second delay
(setq echo-keystrokes 0.1)

;; show as much decoration as possible
(setq font-lock-maximum-decoration t)

;; allow typing to replace the selected region
(delete-selection-mode t)

;; kill entire line (including \n)
(setq kill-whole-line t)

;; always show empty lines at end of buffer
(set-default 'indicate-empty-lines t)

;; setup completion
(setq hippie-expand-try-functions-list
      '(try-expand-dabbrev
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-complete-file-name
        try-complete-lisp-symbol))

;; mac specific options
(when tc/macos-p
  ;; emacs 23 breaks the command -> meta mapping. This fixes it.
  (setq mac-option-key-is-meta nil
        mac-command-key-is-meta t
        mac-command-modifier 'meta
        mac-option-modifier nil)

  (setq-default ispell-program-name "aspell")

  ;; don't open a new frame when the os tells emacs to open a file
  (setq ns-pop-up-frames nil))

;; setup ido
(ido-mode t)
(ido-ubiquitous t)
(setq ido-enable-flex-matching          t
      ido-enable-last-directory-history nil)

;; make ido list files vertically
(require 'ido-vertical-mode)
(ido-vertical-mode)

;; start an emacs server
(require 'server)
(unless (server-running-p)
  (add-hook 'after-init-hook 'server-start))

;; disable upcase-region because I often fat-finger it. I could also
;; unbind C-x C-u I supppose.
(put 'upcase-region 'disabled nil)

;; Make dired less verbose
(require 'dired-details)
(setq-default dired-details-hidden-string "[...] ")
(setq-default dired-details-hide-link-targets nil)
(dired-details-install)

;; advise zap-to-char to delete *up to* char
(defadvice zap-to-char (after my-zap-to-char-advice (arg char) activate)
    "Kill up to the ARG'th occurence of CHAR, and leave CHAR. If
  you are deleting forward, the CHAR is replaced and the point is
  put before CHAR"
    (insert char)
    (if (< 0 arg) (forward-char -1)))

;; use a custom wrapper around zsh
(setenv "ESHELL" (expand-file-name "~/bin/eshell"))

;; Never background/iconify
(global-unset-key (kbd "C-z"))
(global-unset-key (kbd "C-x C-z"))

;; I often get the buffer list by accident
(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)

;; revert - this shadows ido-find-file-read-only, but why would I want
;; to edit a file as read-only?
(global-set-key (kbd "C-x C-r") 'revert-buffer)

(when (not tc/presentation-mode-p)
  ;; use ace-window to jump between windows
  (global-set-key (kbd "C-:") 'ace-window)
  (setq aw-keys
        '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

(global-set-key (kbd "C-x C-d") 'ido-dired)

;; alter the font size for the current buffer
(define-key global-map (kbd "C-+") 'text-scale-increase)
(define-key global-map (kbd "C--") 'text-scale-decrease)

;; lookup the word at point in the dict
(global-set-key (kbd "C-c s") 'ispell-word)

;; make renaming buffers easier
(global-set-key (kbd "C-c r") 'rename-buffer)

;; don't let the current window be used for a different buffer
(global-set-key (kbd "C-x p") 'tc/toggle-current-window-dedication)

;; jump to the begining of the text on the line. a second C-a jumps to
;; the beginning
(global-set-key (kbd "C-a") 'tc/smarter-move-beginning-of-line)

;; remember window configurations - walk through them with C-c left,
;; C-c right
(winner-mode 1)

;; quick search
(require 'helm-swoop)
(global-set-key (kbd "C-o") 'helm-swoop)
(global-set-key (kbd "M-o") 'helm-multi-swoop)
;;(setq swoop-font-size-change: nil)

;; smex - a better M-x
(require 'smex)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)

;; extra help fns - brought in for describe-keymap, mainly
(require 'help-fns+)

;; semantic region expansion
(require 'expand-region)
(global-set-key (kbd "M-2") 'er/expand-region)

;; indent after return
(define-key global-map (kbd "RET") 'newline-and-indent)

;; load everything else
(load "functions")
(load "theme")
(load "ftf")
(load "auto-complete-init")
(load "coding-utils")
(load "modes/clojure")
(load "modes/elisp")
(load "modes/java")
(load "modes/org")
(load "modes/ruby")
(load "modes/shell")
;;(load "modes/term")
(load "modes/text")
(load "modes/markdown")

(when (not tc/presentation-mode-p)
  (load "modes/irc")
  (when (require 'mu4e nil :noerror)
    (load "modes/mail")))

(when tc/presentation-mode-p
  (load "presentation")
  (when tc/presentation-name
    (load (concat "presentations/" tc/presentation-name))))

(when (display-graphic-p)
  (fullscreen))
