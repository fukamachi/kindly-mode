# Kindly Mode for Emacs

Kindly Mode provides Amazon Kindle-like view mode to Emacs.

Before using Kindly Mode, you must eval or add the following code into your .emacs:

    (require 'kindly-mode)

As Kindly Mode doesn't have specific relations to any file extensions, it won't be enabled until you enable it explicitly -- by M-x kindly-mode :).

## Install

I don't know how to install Emacs extensions other than [Auto Install](http://www.emacswiki.org/AutoInstall).

    (auto-install-from-url "https://raw.github.com/fukamachi/kindly-mode/master/kindly-mode.el")

## Screenshot

![](http://cdn-ak.f.st-hatena.com/images/fotolife/n/nitro_idiot/20130215/20130215210713_original.png?1360930043)

## Features

* Better appearance to read.
* vi-like key bindings.
* Puts a bookmark automatically when Emacs is idling.
