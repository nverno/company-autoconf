;;; company-autoconf --- completion for autoconf script

;; Author: Noah Peart <noah.v.peart@gmail.com>
;; URL: https://github.com/nverno/company-autoconf
;; Package-Requires: 
;; Copyright (C) 2016, Noah Peart, all rights reserved.
;; Created: 21 September 2016

;; This file is not part of GNU Emacs.
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

;;; Commentary:

;;; Description:

;;  Emacs company completion backend for autoconf files.  Currently completes
;;  for autoconf/automake macros and jumps html documentation for company doc-buffer.

;;; Code:
(eval-when-compile
  (require 'cl-lib))
(require 'company)

(defgroup company-autoconf nil
  "Company backend for autoconf completion."
  :group 'company
  :prefix "company-autoconf-")

(defvar company-autoconf-data-file "macros.dat")

;; ------------------------------------------------------------
;;* Internal
(defvar company-autoconf-urls)
(defvar company-autoconf-dir)
(setq company-autoconf-dir
      (when load-file-name (file-name-directory load-file-name)))

(defun company-autoconf-load (file)
  (with-temp-buffer
    (insert-file-contents file)
    (car (read-from-string (buffer-substring-no-properties (point-min)
                                                           (point-max))))))

(defvar company-autoconf-keywords
  (let ((data (company-autoconf-load
               (expand-file-name company-autoconf-data-file company-autoconf-dir))))
    (setq company-autoconf-urls 
          (cl-loop for url across (cdr (assoc-string "roots" data))
             collect (concat (car (split-string url "html_node")) "html_node/")))
    (sort
     (cl-loop for (k . v) in data
        unless (string= k "roots")
        do
          (put-text-property 0 1 'annot (aref v 1) k)
          (put-text-property 0 1 'href (aref v 0) k)
          (put-text-property 0 1 'index (aref v 2) k)
        collect k)
     'string<)))

(defun company-autoconf-prefix ()
  (and (eq major-mode 'autoconf-mode)
       (not (company-in-string-or-comment))
       (company-grab-symbol)))

;; retrieval methods

(defun company-autoconf-candidates (arg)
  (all-completions arg company-autoconf-keywords))

(defun company-autoconf-annotation (candidate)
  (or (get-text-property 0 'annot candidate) ""))

(defun company-autoconf-location (candidate)
  "Jump to CANDIDATE documentation in browser."
  (browse-url
   (concat (nth (get-text-property 0 'index candidate) company-autoconf-urls)
           (get-text-property 0 'href candidate))))

;;;###autoload
(defun company-autoconf (command &optional arg &rest _args)
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-autoconf))
    (prefix (company-autoconf-prefix))
    (annotation (company-autoconf-annotation arg))
    (candidates (company-autoconf-candidates arg))
    (doc-buffer (company-autoconf-location arg))
    (sorted t)))

(provide 'company-autoconf)

;;; company-autoconf.el ends here
