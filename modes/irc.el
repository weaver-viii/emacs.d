(require 'erc)
(require 'erc-match)
(require 'notifications)
(require 'erc-hl-nicks)
(require 'erc-tweet)
(require 'erc-image)
(require 'erc-youtube)

;; load private data - this doesn't go into git
(load "private.el.gpg")

(setq
 erc-interpret-mirc-color        t
 erc-nicklist-use-icons          nil
 erc-fill-column                 96
 erc-track-exclude-types         '("JOIN" "NICK" "PART" "QUIT" "MODE"
                                   "324" "329" "332" "333" "353" "477")
 erc-track-exclude-server-buffer t
 erc-track-showcount             t
 erc-hide-list                   '("MODE" "KICK")
 erc-current-nick-highlight-type 'all
 erc-keyword-highlight-type      'all
 erc-pal-highlight-type          'all
 erc-log-matches-flag            t
 erc-auto-set-away               nil
 erc-email-userid                "tcrawley"
 erc-nick                        "tcrawley"
 erc-nick-uniquifier             "_"
 erc-system-name                 nil
 erc-user-full-name              nil
 erc-join-buffer                 'bury
 erc-modules                     '(autojoin button completion fill irccontrols
                                   keep-place list match menu move-to-prompt
                                   netsplit networks noncommands readonly ring
                                   stamp track hl-nicks tweet image youtube)
 erc-track-faces-priority-list   '(erc-error-face
                                   erc-current-nick-face
                                   erc-keyword-face
                                   erc-pal-face)
 erc-image-inline-rescale        300)

;; flyspell check as I type
(erc-spelling-mode 1)

(add-hook 'erc-join-hook 'tc/irc-channel-keywords)
(add-hook 'erc-join-hook 'tc/irc-channel-pals)

(defadvice erc-match-current-nick-p (around tc/erc-match-current-nick-p-sometimes activate)
  (and msg
       (not (string-match "\\*\\*\\* \\(Users on #\\|#.*: topic set\\)" msg))
       ad-do-it))

;; highlight queries in the mode line as if my nick is mentioned
(defadvice erc-track-find-face (around tc/erc-track-find-face-promote-query activate)
  (if (erc-query-buffer-p)
      (setq ad-return-value (intern "erc-current-nick-face"))
    ad-do-it))

;;; change header line face if disconnected
(defface erc-header-line-disconnected
  '((t (:foreground "black" :background "indianred")))
  "Face to use when ERC has been disconnected.")

(setq erc-header-line-face-method
      (lambda ()
        "Use a different face in the header-line when disconnected."
        (erc-with-server-buffer
          (cond ((erc-server-process-alive) 'erc-header-line)
                (t 'erc-header-line-disconnected)))))

;; replace original version to not use word boundaries around
;; nick. This allows "nick's" and parens, etc to match
(defun erc-match-current-nick-p (nickuserhost msg)
  "Check whether the current nickname is in MSG.
NICKUSERHOST will be ignored."
  (with-syntax-table erc-match-syntax-table
    (and msg
         (string-match (regexp-quote (erc-current-nick)) msg))))

;; display # of members in mode line
(define-minor-mode ncm-mode "" nil
  (:eval
   (let ((ops 0)
         (voices 0)
         (members 0))
     (maphash (lambda (key value)
                (when (erc-channel-user-op-p key)
                  (setq ops (1+ ops)))
                (when (erc-channel-user-voice-p key)
                  (setq voices (1+ voices)))
                (setq members (1+ members)))
              erc-channel-users)
     (format " %S" members))))

(defun tc/mostly-ignore-channels-except (watched-chans)
  "Minimal modeline notifications for all channels except WATCHED-CHANS"
  (setq erc-track-priority-faces-only
        (cl-set-difference
         (delq nil (mapcar (lambda (name)
                             (when (string-match "^#" name)
                               name))
                           (tc/buffers-for-mode 'erc-mode)))
         watched-chans
         :test 'equal)))

(defun tc/mostly-ignore-channels ()
  "Minimal modeline notifications for all channels except tc/private-watched-channels"
  (interactive)
  (tc/mostly-ignore-channels-except tc/private-watched-channels))

(add-hook 'erc-mode-hook 'ncm-mode)

(defun irc-connect-internal ()
  (interactive)
  (erc :server my-internal-irc-server :port 6667 :nick "tcrawley" )
  (tc/mostly-ignore-channels))

(defun irc-connect (server port)
  (if (not (erc-server-process-alive))
      (erc-tls :server server
               :port port
               :nick "tcrawley"
               :password my-bouncer-password))
  (tc/mostly-ignore-channels))

(defun irc-connect-bouncer ()
  (interactive)
  (irc-connect "bouncer" 6565))

(defun irc-connect-local ()
  (interactive)
  (irc-connect "localhost" 2020))

(defun irc-connect-all ()
  (interactive)
  (irc-connect-bouncer)
  (irc-connect-internal))

(defun tc/irc-notify (channel message)
  "Displays a message via libnotify."
  (let ((split-message (tc/irc-split-nick-and-message message)))
    (when split-message
      (notifications-notify
       :title (concat "<" (nth 0 split-message) "> on " channel)
       :body (tc/escape-html (nth 1 split-message))))))

(defun tc/irc-split-nick-and-message (msg)
  "Splits an irc message into nick and the rest of the message.
Assumes message is either of two forms: '* nick does something' or '<nick> says something'"
  (if (string-match "^[<\\*] ?\\(.*?\\)>? \\(.*\\)$" msg)
      (cons (match-string 1 msg)
            (cons (match-string 2 msg)
                  ()))
    ()))

(defun tc/irc-alert-on-message (channel msg)
  "Plays a sound and growl notifies a message."
  (and (string-match "^[*<][^*]" msg)
       (> (length msg) 0)
       (or (not (string-match "^#" channel)) ;; query
           (and (not (string-match "^*" msg)) ;; /me
                (string-match (erc-current-nick) msg)))
       (progn
         (tc/play-irc-alert-sound)
         (tc/irc-notify channel msg))))

(defun tc/irc-alert ()
  (save-excursion
    (tc/irc-alert-on-message (buffer-name) (buffer-substring (point-min) (point-max)))))

(add-hook 'erc-insert-post-hook 'tc/irc-alert)

(defun tc/play-irc-alert-sound ()
  (start-process-shell-command "alert-sound" nil
                               (if (eq system-type 'darwin)
                                   "say -v Zarvox -r 500 heyy"
                                 "ogg123 /usr/share/sounds/freedesktop/stereo/bell.oga")))

(defun tc/escape-html (str)
  "Escapes [<>&\n] from a string with html escape codes."
  (and str
       (replace-regexp-in-string "<" "&lt;"
         (replace-regexp-in-string ">" "&gt;"
           (replace-regexp-in-string "&" "&amp;"
             (replace-regexp-in-string "\n" "" str))))))

(define-key erc-mode-map (kbd "C-c q")
  (lambda (nick)
    (interactive (list (completing-read "Query nick: " erc-channel-users)))
    (erc-cmd-QUERY nick)))

(setq erc-prompt
      (lambda ()
        (if (and (boundp 'erc-default-recipients) (erc-default-target))
            (erc-propertize (concat (erc-default-target) ">") 'read-only t 'rear-nonsticky t 'front-nonsticky t)
          (erc-propertize (concat "ERC>") 'read-only t 'rear-nonsticky t 'front-nonsticky t))))

(define-key erc-mode-map (kbd "C-c m")
  (lambda (nick)
    (interactive (list (completing-read "Say 'morning!' to nick: " erc-channel-users)))
    (tc/say-morning nick)))

(defun tc/say-morning (nick)
  (erc-send-message (format "%s: morning!" nick)))

(defun tc/morning-all ()
  (interactive)
  (dolist (nick (tc/extract-hash-keys erc-channel-users))
    (when (not (string-match "ChanServ\\|projectodd\\|tcrawley\\|afk\\|away" nick))
      (tc/say-morning nick))))

(defun tc/yank-to-gist ()
  "yank from the top of the kill ring, create a gist from it, and insert the gist url at the point"
  (interactive)
  (save-excursion
    (let ((buffer (current-buffer)))
            (set-buffer (get-buffer-create "*yank-to-gist*"))
            (yank)
            (gist-region
             (point-min)
             (point-max)
             t
             (lexical-let ((buf buffer))
               (function (lambda (status)
                           (let ((location (cadr status)))
                             (set-buffer buf)
                             (message "Paste created: %s" location)
                             (insert location)
                             (kill-new location))))))
            (kill-buffer))))

(define-key erc-mode-map (kbd "C-c y") `tc/yank-to-gist)

(defun tc/ido-erc-buffer()
  (interactive)
  (tc/ido-for-mode "Channel:" 'erc-mode))

(global-set-key (kbd "C-x c") 'tc/ido-erc-buffer)
