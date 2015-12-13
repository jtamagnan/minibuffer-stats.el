;;; minibuffer-stats.el --- Create a more minimal editing experience and use the modeline to its potential  -*- lexical-binding: t; -*-

;; Copyright (C) 2015  Free Software Foundation, Inc.

;; Author: Jules Tamagnan <jtamagnan@gmail.com>
;; Keywords:
;; Version: 0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package lets you display various status information in the minibuffer
;; window instead of the mode-line.  Of course, this is only displayed when the
;; minibuffer window is not already used for other things (e.g. a minibuffer or
;; an each area message).
;;
;; The contents and aspect is controlled by the `minibuffer-stats-format'
;; variable and the `minibuffer-stats' face.  Their current default kind of
;; sucks: suggestions for improvements welcome.

;;; Code:

(defgroup minibuffer-stats ()
  "Use the idle minibuffer window to display status information
and optionally remove the modeline from view."
  :group 'mode-line)

(defcustom minibuffer-stats-format nil
  "Specification of the contents of the minibuffer-line.
Uses the same format and defaults to `mode-line-format'."
  :type 'sexp)

(defun minibuffer-stats-function ()
  "The function to be called, it must return something which can be inserted such as a string."
  (minibuffer-stats--default-function))

(defcustom minibuffer-stats-refresh-interval 1
  "The frequency at which the minibuffer-stats is updated, in seconds."
  :type 'integer)

(defcustom minibuffer-stats-zap-mode-line t
  "If the mode-line should be zapped."
  :type 'boolean)

(defcustom minibuffer-stats-mode-line-height 0.5
  "The height of the minimized minibuffer."
  :type 'float)

(defface minibuffer-stats-mode-line-active
  '((t (:inherit mode-line :background "#cc6666")))
  "Face to use for the active zapped mode-line.")

(defface minibuffer-stats-mode-line-inactive
  `((t (:inherit mode-line-inactive
		 :background ,(face-attribute 'fringe :background))))
  "Face to use for the zapped inactive mode-line.")

(defconst minibuffer-stats--buffer " *Minibuf-0*")

(defvar minibuffer-stats--timer nil)
(defvar minibuffer-stats--zapped-mode-line nil)
(defvar minibuffer-stats--old-format nil)

(defun minibuffer-stats--default-function ()
  "The default function for minibuffer-stats."
  (format-mode-line minibuffer-stats-format))

(defun minibuffer-stats--update ()
  "Update the minibuffer, executes minibuffer-stats-function."
  (with-current-buffer minibuffer-stats--buffer
    (erase-buffer)
    (insert (minibuffer-stats-function))))

;;;###autoload
(define-minor-mode minibuffer-stats-mode
  "Display status info in the minibuffer window."
  :global t
  (with-current-buffer minibuffer-stats--buffer
    (erase-buffer))
  ;; Turn off
  (when minibuffer-stats--timer
    (when minibuffer-stats--zapped-mode-line
      (copy-face 'minibuffer-stats--old-mode-line 'mode-line)
      (copy-face 'minibuffer-stats--old-mode-line-inactive 'mode-line-inactive)
      (setq minibuffer-stats--zapped-mode-line nil)
      (when minibuffer-stats--old-format
	(setq mode-line-format minibuffer-stats--old-format)))
    (cancel-timer minibuffer-stats--timer)
    (setq minibuffer-stats--timer nil))
  ;; Turn on
  (when minibuffer-stats-mode
    (when minibuffer-stats-zap-mode-line
      (setq minibuffer-stats--zapped-mode-line t)
      (copy-face 'mode-line 'minibuffer-stats--old-mode-line)
      (copy-face 'mode-line-inactive 'minibuffer-stats--old-mode-line-inactive)
      (copy-face 'minibuffer-stats-mode-line-active 'mode-line)
      (copy-face 'minibuffer-stats-mode-line-inactive 'mode-line-inactive)
      (set-face-attribute 'mode-line nil :height minibuffer-stats-mode-line-height)
      (set-face-attribute 'mode-line-inactive nil :height minibuffer-stats-mode-line-height)
      (unless minibuffer-stats--old-format
	(setq minibuffer-stats-format mode-line-format)
	(setq minibuffer-stats--old-format mode-line-format)
	(setq mode-line-format ""))
      )
    (setq minibuffer-stats--timer
          (run-with-timer t minibuffer-stats-refresh-interval
                          #'minibuffer-stats--update))
    (minibuffer-stats--update)))

(provide 'minibuffer-stats)
;;; minibuffer-stats.el ends here
