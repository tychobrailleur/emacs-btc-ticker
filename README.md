Emacs btc-ticker-mode
=====================

Emacs minor-mode to display current Bitcoin price on the
mode-line.

![Screenshot](https://github.com/pennersr/emacs-btc-ticker/blob/master/images/screenshot.png?raw=true)

![Screenshot](https://github.com/pennersr/emacs-btc-ticker/blob/master/images/screenshot2.png?raw=true)

Installation
------------

Your `.emacs` file should look like:

    (require 'btc-ticker)

    ;;Optional: You can setup the fetch interval
    ;;default: 30 secs
    (setq btc-ticker-api-poll-interval 10)

    ;;Enable btc-ticker-mode
    (btc-ticker-mode 1)


Configuration
-------------

`btc-ticker` supports two currencies: dollar and euro.  To set the
currency, you can change the `btc-ticker-currency`.  Its default
value is `euro`.

By default, the value displayed is the conversion of BTC 1 into the
target currency set in `btc-ticker-currency`.  You can change the base
amount to convert by setting the `btc-ticker-amount` variable.
