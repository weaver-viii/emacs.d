(deftheme sorta-blind
  "Created 2012-10-27.")

(custom-theme-set-faces
 'sorta-blind
 '(default ((t (:inherit nil :background "gray90" :foreground "#000000" :width normal :foundry "apple" :family "Monaco"))))
 '(cursor ((t (:background "dark cyan"))))
 '(fixed-pitch ((t (:family "Monospace"))))
 '(variable-pitch ((t (:family "Sans Serif"))))
 '(escape-glyph ((t (:foreground "brown"))))
 '(minibuffer-prompt ((t (:background "yellow" :foreground "#020697" :weight bold))))
 '(highlight ((t (:background "gray95"))))
 '(shadow ((t (:foreground "grey50"))))
 '(secondary-selection ((t (:background "yellow1"))))
 '(trailing-whitespace ((t (:background "red1"))))
 '(font-lock-builtin-face ((t (:foreground "#170ce4"))))
 '(font-lock-comment-delimiter-face ((t (:inherit font-lock-comment-face))))
 '(font-lock-comment-face ((t (:foreground "#777" :slant italic))))
 '(font-lock-constant-face ((t (:foreground "#030" :slant italic))))
 '(font-lock-doc-face ((t (:inherit font-lock-string-face))))
 '(font-lock-function-name-face ((t (:foreground "#0d27b5"))))
 '(font-lock-keyword-face ((t (:foreground "#063" weight: bold))))
 '(font-lock-negation-char-face ((t nil)))
 '(font-lock-preprocessor-face ((t (:inherit font-lock-builtin-face))))
 '(font-lock-regexp-grouping-backslash ((t (:inherit bold))))
 '(font-lock-regexp-grouping-construct ((t (:inherit bold))))
 '(font-lock-string-face ((t (:foreground "gray20" :slant italic))))
 '(font-lock-type-face ((t (:foreground "#0b7d07"))))
 '(font-lock-variable-name-face ((t (:foreground "#4f4047"))))
 '(font-lock-warning-face ((t (:inherit error :foreground "Red" :weight bold))))
 '(button ((t (:inherit link))))
 '(link ((t (:foreground "RoyalBlue3" :underline t))))
 '(link-visited ((t (:inherit link :foreground "magenta4"))))
 '(fringe ((t (:background "#ebebea"))))
 '(header-line ((t (:inherit mode-line :background "grey10" :foreground "grey90" :underline t :box nil))))
 '(tooltip ((t (:inherit variable-pitch :background "lightyellow" :foreground "black"))))
 '(mode-line ((t (:background "#3b6865" :foreground "#ffffff" :box (:line-width -1 :style released-button)))))
 '(mode-line-buffer-id ((t (:weight bold))))
 '(mode-line-emphasis ((t (:weight bold))))
 '(mode-line-highlight ((t (:box (:line-width 2 :color "grey40" :style released-button)))))
 '(mode-line-inactive ((t (:inherit mode-line :background "grey70" :foreground "grey20" :box (:line-width -1 :color "grey75") :weight light))))
 '(isearch ((t (:background "magenta3" :foreground "lightskyblue1"))))
 '(isearch-fail ((t (:background "RosyBrown1"))))
 '(lazy-highlight ((t (:background "paleturquoise"))))
 '(match ((t (:background "yellow1"))))
 '(next-error ((t (:inherit region))))
 '(erc-current-nick-face ((t (:background "yellow" :foreground "black" :weight bold))))
 '(erc-input-face ((t (:background "gray85" :foreground "black"))))
 '(erc-keyword-face ((t (:foreground "Red" :weight bold))))
 '(erc-notice-face ((t (:foreground "SlateGray" :height 0.8))))
 '(erc-pal-face ((t (:background "grey85" :foreground "blue" :weight normal))))
 '(erc-timestamp-face ((t (:foreground "black" :weight bold))))
 '(fg:erc-color-face10 ((t (:foreground "blue"))))
 '(flyspell-duplicate ((t (:foreground "DarkRed" :underline t :weight bold))))
 '(flyspell-incorrect ((t (:foreground "DarkRed" :underline t :weight bold))))
 '(idle-highlight ((t (:background "green1" :foreground "black"))))
 '(message-header-name ((t (:foreground "#093"))))
 '(mu4e-header-highlight-face ((t (:inherit region :foreground "black" :underline t :weight bold))))
 '(region ((t (:background "pale green" :foreground "black")))))
'(query-replace ((t (:inherit isearch))))

(provide-theme 'sorta-blind)
