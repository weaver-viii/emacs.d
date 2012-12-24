(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/mu4e")
(require 'mu4e)

(setq
 user-mail-address           "toby@tcrawley.org"
 user-full-name              "Toby Crawley"
 message-kill-buffer-on-exit t
 message-send-mail-function  'smtpmail-send-it
 mail-user-agent             'mu4e-user-agent
 mu4e-maildir                "~/Maildir"
 mu4e-attachment-dir         "~/Downloads"
 mu4e-user-mail-address-list '("toby@tcrawley.org" "tcrawley@gmail.com" "tcrawley@redhat.com")
 mu4e-html2text-command      "html2text -utf8 -width 72"
 mu4e-get-mail-command       "offlineimap"
 tc/default-trash-folder     "/tcrawley.org/INBOX.Trash"
 tc/default-refile-folder    "/tcrawley.org/INBOX.Archive"
 mu4e-sent-folder            "/tcrawley.org/INBOX.Sent" ;; always overridden, but mu4e needs a default
 mu4e-drafts-folder          "/tcrawley.org/INBOX.Drafts" ;; always overridden, but mu4e needs a default
 mu4e-maildir-shortcuts      '(("/gmail.com/INBOX"    . ?g)
                               ("/tcrawley.org/INBOX" . ?t)
                               ("/redhat.com/INBOX"   . ?r))
 mu4e-bookmarks              '(("maildir:/tcrawley.org/INBOX OR maildir:/gmail.com/INBOX OR maildir:/redhat.com/INBOX"
                                "Combined inbox"   ?i)
                               ("flag:unread AND NOT flag:trashed"
                                "Unread messages"  ?u)
                               ("date:today..now"
                                "Today's messages" ?t)
                               ("date:7d..now"
                                "Last 7 days"      ?w)))

(defun tc/maildir-match-p (re msg)
  (string-match-p
   re
   (mu4e-message-field msg :maildir)))

(defun tc/recip-matches-p (re msg)
  (or (mu4e-message-contact-field-matches msg :to re)
      (mu4e-message-contact-field-matches msg :cc re)
      (mu4e-message-contact-field-matches msg :bcc re)))

(setq mu4e-trash-folder
      (lambda (msg)
        (cond
         ((tc/maildir-match-p "gmail" msg) "/gmail.com/[Gmail].Trash")
         ((tc/maildir-match-p "redhat" msg) "/redhat.com/Trash")
         (t tc/default-trash-folder))))

(setq mu4e-refile-folder
      (lambda (msg)
        (cond
         ((tc/recip-matches-p "clojure@googlegroups.com" msg) "/tcrawley.org/INBOX.Lists.clojure.clojure")
         ((tc/recip-matches-p "clojure-dev@googlegroups.com" msg) "/tcrawley.org/INBOX.Lists.clojure.clojure-dev")
         ((tc/maildir-match-p "gmail" msg) "/gmail.com/[Gmail].Archive")
         ((tc/maildir-match-p "redhat" msg) "/redhat.com/Archive.2012")
         (t tc/default-refile-folder))))

;; Set values based on sending account. based on:
;; https://groups.google.com/d/msg/mu-discuss/FngEnN8u4NI/30lcyEWTaSgJ
(setq tc/mu4e-account-alist

      '(("tcrawley.org"
         (user-mail-address           "toby@tcrawley.org")
         (mu4e-sent-folder            "/tcrawley.org/INBOX.Sent")
         (mu4e-drafts-folder          "/tcrawley.org/INBOX.Drafts")
         (mu4e-sent-messages-behavior sent)
         (smtpmail-stream-type        ssl)
         (smtpmail-smtp-server        "mail.tcrawley.org")
         (smtpmail-smtp-service       465)
         (starttls-extra-arguments    nil)
         (message-signature           "Toby Crawley\nhttp://immutant.org | http://torquebox.org"))

        ("gmail.com"
         (user-mail-address           "tcrawley@gmail.com")
         (mu4e-sent-folder            "/gmail.com/[Gmail].Sent Messages")
         (mu4e-drafts-folder          "/gmail.com/[Gmail].Drafts")
         (mu4e-sent-messages-behavior delete)
         (smtpmail-stream-type        starttls)
         (smtpmail-smtp-server        "smtp.gmail.com")
         (smtpmail-smtp-service       587)
         (starttls-extra-arguments    ("--no-ca-verification"))
         (message-signature           nil))

        ("redhat.com"
         (user-mail-address           "tcrawley@redhat.com")
         (mu4e-sent-folder            "/redhat.com/Sent")
         (mu4e-drafts-folder          "/redhat.com/Drafts")
         (mu4e-sent-messages-behavior sent)
         (smtpmail-stream-type        starttls)
         (smtpmail-smtp-server        "smtp.corp.redhat.com")
         (smtpmail-smtp-service       25)
         (starttls-extra-arguments    ("--no-ca-verification"))
         (message-signature           "Toby Crawley\nRed Hat, Inc | http://immutant.org | http://torquebox.org"))))

(add-hook
 'mu4e-compose-pre-hook
 (lambda ()
   (let* ((account
           (if mu4e-compose-parent-message
               (let ((maildir (mu4e-msg-field mu4e-compose-parent-message :maildir)))
                 (string-match "/\\(.*?\\)/" maildir)
                 (match-string 1 maildir))
             (completing-read (format "Compose with account: (%s) "
                                      (mapconcat #'(lambda (var) (car var)) tc/mu4e-account-alist "/"))
                              (mapcar #'(lambda (var) (car var)) tc/mu4e-account-alist)
                              nil t nil nil (caar tc/mu4e-account-alist))))
          (account-vars (cdr (assoc account tc/mu4e-account-alist))))
     (if account-vars
         (mapc #'(lambda (var)
                   (set (car var) (cadr var)))
               account-vars)))))

