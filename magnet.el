;;; magnet.el --- one config and one data directory for Emacs

;; Copyright (C) 2012  Jonas Bernoulli

;; Author: Jonas Bernoulli <jonas@bernoul.li>
;; Created: 20120624
;; Version: 1.0.2
;; Homepage: https://github.com/tarsius/magnet
;; Keywords: convenience

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; The default paths used to store configuration files and persistent
;; data are not consistent across Emacs packages.  This isn't just a
;; problem with third-party packages but even with built-in packages.

;; Some packages put these files directly in `user-emacs-directory' or
;; $HOME or in a subdirectory of either of the two or elsewhere.
;; Furthermore sometimes file names are used that don't provide any
;; insight into what mode might have created them.

;; This package sets out to fix this by changing the values of path
;; variables to put files in either `magnet-etc-directory' or
;; `magnet-var-directory', using subdirectories when appropriate and
;; descriptive file names.  In a way this is similar to a color-theme
;; - a path-theme if you will.  Except that there is no way to unload
;; it - that wouldn't make any sense.  This package also does not
;; provide any mode, all work is done when `magnet.el' is loaded and
;; any configuration has to happen before doing so.

;; One of the variables changed by this package is `custom-file', so
;; we cannot use Customize to configure `magnet'.  Instead the
;; following variables before loading `magnet.el' using `setq'.

;; * `magnet-etc-directory'       (default ~/.emacs.d/etc/)
;;    Hopefully the only location where Emacs config files are stored.
;;    Config files are stored either directly in this directory or in
;;    a subdirectory.
;;
;; * `magnet-var-directory'       (default ~/.emacs.d/var/)
;;    Hopefully the only location where Emacs data files are stored.
;;    Data files are stored either directly in this directory or in
;;    a subdirectory.
;;
;; * `magnet-set-defaults'        (default t)
;;    Whether magnet sets the default values using `set-default'.
;;    When nil use `set' instead.  This affects whether Customize
;;    thinks a variable has been customized or not after `magnet'
;;    has been loaded.
;;
;; * `magnet-load-custom-file'    (default t)
;;    Whether loading `magnet.el' also loads the `custom-file'.
;;    One shouldn't set `custom-file' (as loading `magnet.el' does)
;;    without ensuring that it is also loaded.
;;
;; * `magnet-add-to-magnetized-custom-groups'  (default t)
;;    Whether loading `magnet.el' adds modified options to a
;;    `magnetized' Custom group.")

;; Status:
;;
;; This is work in progress and very incomplete at the moment.  Only
;; very few packages have been themed so far.  Eventually all built-in
;; and many popular third-party packages should be themed.
;;
;; This is a pre-release.  Version numbers are inspired by how Emacs
;; is versioned.  1.1.0 will be the first stable version theming an
;; acceptable number of packages.

;; Conventions:
;;
;; This is not set in stone.
;;
;; * Packages are customized completely or not at all.
;; * If a default value satisfies our needs it is still repeated here.
;; * Emacs lisp files end with ".el".
;; * If a package has several files of a kind then it is placed in a
;;   suitably named subdirectory of it's own.

;; Contributing:
;;
;; Please send me pull requests with your additions and corrections:
;;
;;   https://github.com/tarsius/magnet/pulls
;;
;; For a list of people who have contributed see:
;;
;;   https://github.com/tarsius/magnet/graphs/contributors

;;; Code:

(defvar magnet-etc-directory
  (or (bound-and-true-p epkg-etc-directory)
      (expand-file-name (file-name-as-directory "etc") user-emacs-directory))
  "Hopefully the only location where Emacs config files are stored.")

(defvar magnet-var-directory
  (or (bound-and-true-p epkg-var-directory)
      (expand-file-name (file-name-as-directory "var") user-emacs-directory))
  "Hopefully the only location where Emacs data files are stored.")

(defvar magnet-set-defaults t
  "Whether magnet sets the default values using `set-default'.
When nil use `set' instead.  This affects whether Customize
thinks a variable has been customized or not after `magnet' has
been loaded.")

(defvar magnet-load-custom-file t
  "Whether loading `magnet.el' also loads the `custom-file'.")

(defvar magnet-add-to-magnetized-custom-groups t
  "Whether modified options are added to a `magnetized' Custom group.")

(defun magnet-etc (value)
  (expand-file-name (convert-standard-filename value) magnet-etc-directory))

(defun magnet-var (value)
  (expand-file-name (convert-standard-filename value) magnet-var-directory))

(defmacro magnet-etc-set (symbol value)
  "Set SYMBOL to VALUE with `magnet-etc-directory' prepended.
SYMBOL isn't evaluated.  If VALUE is a string expand it at run
time as a filename in `magnet-etc-directory' and use the result
as SYMBOL's new value.  If VALUE isn't a string evaluate it at
compile time; the result is not furthur expanded as a filename."
  `(prog1
       (funcall
        (if magnet-set-defaults 'set-default 'set)
        ',symbol
        ,(if (stringp value)
             `(magnet-etc ,value)
           value))
     (and magnet-add-to-magnetized-custom-groups
          (user-variable-p ',symbol)
          (custom-add-to-group 'magnetized-config-files
                               ',symbol 'custom-variable))))

(defmacro magnet-var-set (symbol value)
  "Set SYMBOL to VALUE with `magnet-var-directory' prepended.
SYMBOL isn't evaluated.  If VALUE is a string expand it at run
time as a filename in `magnet-var-directory' and use the result
as SYMBOL's new value.  If VALUE isn't a string evaluate it at
compile time; the result is not furthur expanded as a filename."
  `(prog1
       (funcall
        (if magnet-set-defaults 'set-default 'set)
        ',symbol
        ,(if (stringp value)
             `(magnet-var ,value)
           value))
     (and magnet-add-to-magnetized-custom-groups
          (user-variable-p ',symbol)
          (custom-add-to-group 'magnetized-persistent-files
                               ',symbol 'custom-variable))))

(eval-when-compile (require 'cl))
(eval-when (load eval)

;;; Built-in.

;; `auto-insert'
(magnet-var-set auto-insert-directory          "auto-insert/")
;; `auto-save'
;; It is intentional that no common directory is used.
(magnet-var-set auto-save-list-file-prefix     "auto-saves/")
(magnet-var-set trash-directory                "trash/")
;; `backup'
;; It is intentional that we depart from the default behaviour
;; of littering where ever we go.
(magnet-var-set backup-directory-alist         `(("." . ,(magnet-var "backups/"))))
;; `bookmark'
(magnet-var-set bookmark-default-file          "bookmarks/default.el")
;; `custom'
(magnet-etc-set custom-file                    "custom/custom-file.el")
(magnet-etc-set custom-theme-directory         "custom/themes/")
;; `newsticker'
(magnet-var-set newsticker-cache-filename      "newsticker/cache") ; TODO .el ?
(magnet-var-set newsticker-dir                 "newsticker/")
;; `recentf'
(magnet-var-set recentf-save-file              "recentf.el")
;; `savehist'
(magnet-var-set savehist-file                  "savehist.el")
;; `saveplace'
(magnet-var-set save-place-file                "saveplace.el")
;; `tramp'
(magnet-var-set tramp-persistency-file-name    "tramp/history.el")
;; The default values of these variables is nil; setting them
;; changes the behaviour of `tramp', so we don't do it.
;; (magnet-var-set tramp-auto-save-directory   "tramp/auto-saves/")
;; (magnet-var-set tramp-auto-save-directory   backup-directory-alist)
;; `url'
(magnet-var-set url-configuration-directory    "url/")
(magnet-var-set url-cookie-file                "url/cookies.el")
(magnet-var-set url-history-file               "url/history.el")


;;; Third-party.

;; `yaoddmuse'
(magnet-var-set yaoddmuse-directory            "yaoddmuse/")


;;; Custom groups.

(when magnet-add-to-magnetized-custom-groups

(defgroup magnetized nil
  "Path options whose values were changed by `magnet'.
These options are define in unrelated packages but have in common
that they define the location of config and persistend files and
directories used by their respective packages."
  :group 'convenience
  :link '(emacs-commentary-link "magnet.el"))

(defgroup magnetized-config-files nil
  "Path options whose values were changed by `magnet'.
These options are define in unrelated packages but have in common
that they define the location of config files and directories
used by their respective packages."
  :group 'magnetized
  :link '(emacs-commentary-link "magnet.el"))

(defgroup magnetized-persistent-files nil
  "Path options whose values were changed by `magnet'.
These options are define in unrelated packages but have in common
that they define the location of persistent files and directories
used by their respective packages."
  :group 'magnetized
  :link '(emacs-commentary-link "magnet.el"))

) ; magnet-add-to-magnetized-custom-groups ends here


;;; Load `custom-file'.

(and magnet-load-custom-file
     (file-exists-p custom-file)
     (load custom-file))

) ; magnet-initialize ends here

(provide 'magnet)
;; Local Variables:
;; indent-tabs-mode: nil
;; End:
;;; magnet.el ends here
