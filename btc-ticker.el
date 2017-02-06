;;; btc-ticker.el --- Shows latest bitcoin price   -*- coding: utf-8 -*-

;; Copyright (C) 2014  Jorge Niedbalski R.
;; Copyright (c) 2017  Sébastien Le Callonnec

;; Author: Jorge Niedbalski R. <jnr@metaklass.org>
;; Version: 0.1
;; Package-Requires: ((json "1.2") (request "0.2.0"))
;; Keywords: news

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

;;; Code:

(require 'request)
(require 'json)

(defgroup btc-ticker nil
  "btc-ticker extension"
  :group 'comms
  :prefix "btc-ticker-")

(defcustom btc-ticker-currency
  "euro"
  "Ticker currency."
  :type '(choice (const :tag "euro" euro)
                 (const :tag "dollar" dollar))
  :group 'btc-ticker)

(defconst btc--currencies
  '(("euro" . '("eur" . "€"))
    ("dollar" . '("usd" . "$")))
  "List of supported currencies.")

(defcustom btc-ticker-amount 1
  "BTC amount to convert into `btc-ticker-currency'."
  :type 'float
  :group 'btc-ticker)

(defconst bitstamp-api-url "https://www.bitstamp.net/api/v2/ticker")

(defcustom btc-ticker-api-poll-interval 30
  "Default interval to poll to the bitstamp api"
  :type 'number
  :group 'btc-ticker)

(defvar btc-ticker-timer nil
  "Bitstamp API poll timer")

(defun btc-ticker--currency-symbol ()
  "Get the currency symbol for the chosen currency."
  (cdr (caddr (assoc btc-ticker-currency btc--currencies))))

(defvar btc-ticker-mode-line (format " %s0.00" (btc-ticker--currency-symbol))
  "Displayed on mode-line")
(put 'btc-ticker-mode-line 'risky-local-variable t)

(defvar btc-ticker--current-value nil)

(defun btc-ticker-start ()
  (unless btc-ticker-timer
    (setq btc-ticker-timer
          (run-at-time "0 sec"
                       btc-ticker-api-poll-interval
                       #'btc-ticker-fetch))
    (btc-ticker-update-status)))

(defun btc-ticker-stop ()
  (when btc-ticker-timer
    (cancel-timer btc-ticker-timer)
    (setq btc-ticker-timer nil)
    (if (boundp 'mode-line-modes)
        (delete '(t btc-ticker-mode-line) mode-line-modes))))

(defun btc-ticker-update-status ()
  (if (not (btc-ticker-mode))
      (if (boundp 'mode-line-modes)
          (add-to-list 'mode-line-modes '(t btc-ticker-mode-line) t))))

(defun btc-ticker--bitstamp-api-url ()
  (format "%s/btc%s" bitstamp-api-url
          (car (caddr (assoc btc-ticker-currency btc--currencies)))))

(defun btc-ticker--convert-to-currency (data)
  (* btc-ticker-amount (string-to-number (assoc-default 'last data))))

(defun btc-ticker--set-ticker-mode-line (new-value)
  (let ((value-str (format " %s%.2f" (btc-ticker--currency-symbol) new-value)))
    (cond
     ((not (numberp btc-ticker--current-value))
      (setq btc-ticker-mode-line value-str))
     ((= btc-ticker--current-value new-value)
      (setq btc-ticker-mode-line value-str))
     ((> new-value btc-ticker--current-value)
      (setq btc-ticker-mode-line (propertize value-str 'face '(:foreground "lime green"))))
     ((< new-value btc-ticker--current-value)
      (setq btc-ticker-mode-line (propertize value-str 'face '(:foreground "red")))))
    (setq btc-ticker--current-value new-value)))

(defun btc-ticker-fetch ()
  (request
   (btc-ticker--bitstamp-api-url)
   :parser 'json-read
   :success (function*
             (lambda (&key data &allow-other-keys)
               (btc-ticker--set-ticker-mode-line
                (btc-ticker--convert-to-currency data))))))


;;;###autoload
(define-minor-mode btc-ticker-mode
  "Minor mode to display the latest BTC price."
  :init-value nil
  :global t
  :lighter btc-ticker-mode-line
  (if btc-ticker-mode
      (btc-ticker-start)
    (btc-ticker-stop)))

(provide 'btc-ticker)
;;; btc-ticker.el ends here
