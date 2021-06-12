;;; org-status.el --- Tweet using `org-mode's capture functionality.
;; Author: Neil Smithline
;; Maintainer: 
;; Copyright (C) 2012, Neil Smithline, all rights reserved.
;; Created: Sun May 27 09:24:41 2012 (-0400)
;; Version: 1.0-alpha1
;; Last-Updated: 
;;           By: 
;;     Update #: 0
;; URL: https://github.com/neil-smithline-elisp/org-status
;; Keywords: org-mode, twitter, tweet
;; Compatibility: Wherever org is.
;; 
;; Features that might be required by this library:
;;
;;   defhook
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Commentary: 
;; 
;; Sorry but I'm tired. For now, see the README: http://bit.ly/MoGKYU
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Change Log:
;; 
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Code:

(require 'defhook)

(define-minor-mode org-status-minor-mode
  "Post status updates to social sites."
  nil
  " OrgStat"
  :group    'org-status
  :global   nil
  (defhook org-auto-status-updates (write-file-functions :local t)
      "Run `org-status-updates' before saving the current buffer.
This must return nil or the file is considered saved. See
`write-file-functions' for more info."
      (when org-status-minor-mode
        (org-status-updates))
      nil))

(defgroup org-status nil
  "Settings for `org-status-update' commands."
  :group 'org)

(defcustom org-status-twitter-command "/usr/local/Cellar/ruby/1.9.3-p0/bin/t"
  "Full path to the installed `t' command on your system.

See https://github.com/sferik/t for instructions on installing `t'."
  :type '(file :must match t)
  :risky t
  :safe nil
  :group 'org-status)

(defcustom org-status-output-buffer "*Org Status Output*"
  "Status buffer from `org-status-update' commands."
  :type 'string
  :safe t
  :risky nil
  :group 'org-status)

(defcustom org-status-output-file-regexp ".*-status\.org"
  "Files matching regexp will go into `org-status-update-minor-mode'.
An `org-mode' buffer will automatically enable
`org-status-update-minor-mode' when the file path matches this
regexp."
  :type 'string
  :safe t
  :risky nil
  :group 'org-status)

(defhook enable-org-status-update-minor-mode (org-mode-hook)
  "Determine if `org-status-minor-mode' should be enabled in this buffer.
If the full pathname of the file of this buffer matches
`org-status-output-file-regexp', then
`org-status-update-minor-mode' will be enabled when `org-mode' is
entered."
  (when (and buffer-file-name
             (string-match org-status-output-file-regexp buffer-file-name))
    (org-status-minor-mode 1)))

(defun org-status-tweet ()
  "Do a tweet for the current headline."
  (interactive)
  (message "ding")
  (beginning-of-line 1)
  (let* ((status-props      (org-agenda-get-some-entry-text
                             (point-marker) 9999))
         (status            (substring-no-properties status-props))
         (headline          (nth 4 (org-heading-components))))
    (message "Tweeting %s . . ." headline)
    (assert (<= (length status) 140) t)
    (get-buffer-create org-status-output-buffer)
    (let ((success (shell-command 
                    (format "%s update %s"
                            org-status-twitter-command
                            (shell-quote-argument status))
                    org-status-output-buffer
                    org-status-output-buffer))
          (output (save-excursion
                     (set-buffer org-status-output-buffer)
		     (let* (
			    (buffermsg (buffer-substring-no-properties (point-min)
								       (point-max)))
			    (match org-status-twitter-command)
			    (matchpos (string-match-p match buffermsg)))
		       (substring buffermsg (if (null match) (+ (length match) matchpos) 0))))))
      (if (zerop success)
          (let* ((tags (org-get-tags))
                 (new (cons "TWEETED_NS" (remove "TWEET_NS" tags))))
            (message "old=%s, new=%s." tags new)
            (org-set-tags-to new)
	    (org-set-property "TWEET_ID" (when (string-match "[0-9]+" output)
					   (match-string 0 output)))
            (org-agenda-align-tags)
            output)
        ;; Remove trailing newline and period for error messages.
        (let ((error-string (substring output 0 (- (length output) 2))))
          (error "Error (%s): %s: `%s'"
                 success error-string headline))))))

(defun org-status-updates ()
  "Loop through entries looking for status updates."
  (message "dong")
  (interactive)
  (let ((results (org-map-entries #'org-status-tweet
                                  "TWEET_NS" 'file)))
   (when results
     (with-output-to-temp-buffer org-status-output-buffer
      (set-buffer org-status-output-buffer)
      (print-elements-of-list results)))))

(provide 'org-status)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; org-status.el ends here
