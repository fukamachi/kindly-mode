;;;; kindly-mode.el --- Amazon Kindle-like view mode.

;; Copyright (C) 2013  Eitarow Fukamachi

;; Author: Eitarow Fukamachi <e.arrows@gmail.com>
;; Web Site: http://fukamachi.github.com/
;;
;; Created: Feb 15, 2013
;; Version: 0.1
;; Keywords: kindle

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Emacs is a good tool for reading texts as well as editing them.
;; Kindly Mode makes reading on Emacs comfortable by acting like Amazon Kindle.
;;
;; Before using Kindly Mode, you must eval or add the following code
;; into your .emacs:
;;
;;     (require 'kindly-mode)
;;
;; As Kindly Mode doesn't have specific relations to any file extensions,
;; it won't be enabled until you enable it explicitly -- by M-x kindly-mode :).

;;; Code:

(eval-when-compile
  (require 'cl))
(require 'bookmark)



;;
;; Customizable Variables

(defgroup kindly nil
  "Amazon Kindle-like view mode"
  :group 'convenience
  :prefix "kindly:")

(defcustom kindly:use-auto-bookmark-p t
  "Whether use auto-bookmarking during Emacs is idling."
  :type 'boolean
  :group 'kindly)

(defcustom kindly:auto-bookmark-interval 5
  "Interval seconds until auto-bookmarking."
  :type 'number
  :group 'kindly)

(defcustom kindly:line-spacing 0.3
  "`line-spacing' for Kindly Mode."
  :type 'number
  :group 'kindly)

(defcustom kindly:font-face '(:family "Times New Roman" :height 200 :width semi-condensed)
  "Font-face property list for Kindly Mode."
  :type 'list
  :group 'kindly)

(defvar kindly-mode-map
    (let ((map (make-sparse-keymap)))
      (loop for (key . fn) in
            `(("h" . backward-char)
              ("j" . next-line)
              ("k" . previous-line)
              ("l" . forward-char)
              (" " . scroll-up)
              ("b" . scroll-down)
              ("." . ,(lambda ()
                        (bookmark-set (kindly:bookmark-find-by-filename)))))
            do (define-key map key fn))
      map)
  "Kindly mode map.")

(defvar kindly-mode-hook nil
  "Hook for `kindly-mode'.")



;;
;; Functions

(defun kindly:bookmark-find-by-filename (&optional filename)
  (unless filename (setq filename (buffer-file-name)))
  (find-if (lambda (bm)
             (string= filename (expand-file-name (bookmark-get-filename bm))))
           bookmark-alist))

(defun kindly:bookmark-jump-for-file (&optional filename)
  (unless filename (setq filename (buffer-file-name)))
  (let ((bookmark (kindly:bookmark-find-by-filename filename)))
    (when bookmark
      (bookmark-jump bookmark))))

(defun kindly:bookmark-idle-saving ()
  (let ((bm (kindly:bookmark-find-by-filename)))
    (when (and bm
               (> (point) (bookmark-get-position bm)))
      (bookmark-set (car bm)))))

(defun kindly:auto-bookmark-timer (enablep &optional interval))
(lexical-let (timer)
  (defun kindly:auto-bookmark-timer (enablep &optional interval)
    (cond
      ((and enablep (not timer))
       (setq timer
             (run-with-idle-timer (or interval
                                      kindly:auto-bookmark-interval) t
                                  #'kindly:bookmark-idle-saving)))
      ((and (not enablep) timer)
       (cancel-timer timer)
       (setq timer nil)))))

(defun kindly:move-to-furthest ()
  (let* ((bookmark (kindly:bookmark-find-by-filename))
         (position (bookmark-get-position bookmark)))
    (when (and bookmark position
               (or (> (point) position)
                   (and (< (point) position)
                        (yes-or-no-p "Wanna move to the furthest read position? "))))
      (kindly:bookmark-jump-for-file))))



;;
;; Minor Mode

(defun enable-kindly-mode ())
(defun disable-kindly-mode ())
(lexical-let (saved-line-spacing)
  (defun enable-kindly-mode ()
    (setq saved-line-spacing line-spacing)
    (setq line-spacing kindly:line-spacing)
    (setq buffer-face-mode-face kindly:font-face)

    (when kindly:use-auto-bookmark-p
      (kindly:auto-bookmark-timer t)
      (kindly:move-to-furthest))

    (setq buffer-read-only t)

    (run-hooks 'kindly-mode-hook))

  (defun disable-kindly-mode ()
    (setq line-spacing saved-line-spacing)
    (kindly:auto-bookmark-timer nil)
    (setq buffer-read-only nil)))

(define-minor-mode kindly-mode ()
  :lighter " Kind"
  :keymap kindly-mode-map
  :group 'kindly

  (funcall (if kindly-mode
               'enable-kindly-mode
               'disable-kindly-mode))

  (buffer-face-mode)

  (run-hooks 'kindly-mode-hook))

(provide 'kindly-mode)
;;; kindly-mode.el ends here
