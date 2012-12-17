;;; wxwidgets-help.el --- Look up wxWidgets API by using local html manual

;; Copyright (C) 2012 Chen Bin
;; Author: Chen Bin <chenbin.sh@gmail.com>
;; URL: http://github.com/redguardtoo/wxwidgets-help
;; Keywords: wxWidgets C++ manual
;; Version: 0.0.1

;; This file is not part of GNU Emacs.

;; This file is free software (GPLv3 License)

;; How to set it up:
;; See README.org which is distributed with this file

;;; Code:
(defvar wxhelp-hash (make-hash-table :test 'equal ))
(defun wxhelp-init-hash ()
  (clrhash wxhelp-hash)
  (puthash "a" "functions_0x61.html" wxhelp-hash)
  (puthash "b" "functions_0x62.html" wxhelp-hash)
  (puthash "c" "functions_0x63.html" wxhelp-hash)
  (puthash "d" "functions_0x64.html" wxhelp-hash)
  (puthash "e" "functions_0x65.html" wxhelp-hash)
  (puthash "f" "functions_0x66.html" wxhelp-hash)
  (puthash "g" "functions_0x67.html" wxhelp-hash)
  (puthash "h" "functions_0x68.html" wxhelp-hash)
  (puthash "i" "functions_0x69.html" wxhelp-hash)
  (puthash "j" "functions_0x6a.html" wxhelp-hash)
  (puthash "k" "functions_0x6b.html" wxhelp-hash)
  (puthash "l" "functions_0x6c.html" wxhelp-hash)
  (puthash "m" "functions_0x6d.html" wxhelp-hash)
  (puthash "n" "functions_0x6e.html" wxhelp-hash)
  (puthash "o" "functions_0x6f.html" wxhelp-hash)
  (puthash "p" "functions_0x70.html" wxhelp-hash)
  (puthash "q" "functions_0x71.html" wxhelp-hash)
  (puthash "r" "functions_0x72.html" wxhelp-hash)
  (puthash "s" "functions_0x73.html" wxhelp-hash)
  (puthash "t" "functions_0x74.html" wxhelp-hash)
  (puthash "u" "functions_0x75.html" wxhelp-hash)
  (puthash "v" "functions_0x76.html" wxhelp-hash)
  (puthash "w" "functions_0x77.html" wxhelp-hash)
  (puthash "x" "functions_0x78.html" wxhelp-hash)
  (puthash "y" "functions_0x79.html" wxhelp-hash)
  (puthash "z" "functions_0x7a.html" wxhelp-hash)
  (puthash "~" "functions_0x7e.html" wxhelp-hash)
  (puthash "_" "functions.html" wxhelp-hash)
  )

(defun wxhelp-root-dir ()
  (let ((rd (getenv "WXWIN")))
    (if (not rd)
        (setq rd (getenv "WXWIDGETS"))
        )
    rd
    )
  )

;;;###autoload
(defun wxhelp-api-index ()
  "List wxWidgets API in its default HTML manual"
  (interactive)
  (let ((rd (wx-root-dir)))
    (when rd
      (w3m-browse-url (concat rd "/docs/doxygen/out/html/group__group__funcmacro.html"))
      )
    )
  )

;;;###autoload
(defun wxhelp-class-index ()
  "List wxWidgets class in its default HTML manual"
  (interactive)
  (let ((rd (wx-root-dir)))
    (when rd
      (w3m-browse-url (concat rd "/docs/doxygen/out/html/group__group__class.html"))
      )
    )
  )

(defun wxhelp-match-strs (s)
  (let ((cs case-fold-search) v r l (i 0))
    (setq case-fold-search nil) ;case sensitive search
    (while (setq i (string-match "\\([A-Z][a-z]*\\)" s i))
      (setq r (downcase (match-string 1 s)))
      (setq l (concat l "_" r))
      (setq i (+ i (length r) ))
      )
    ;restore
    (setq case-fold-search cs)
    l
    )
  )

(defun wxhelp-readlines (fPath)
    "Return a list of lines of a file at fPath."
      (with-temp-buffer
            (insert-file-contents fPath)
                (split-string (buffer-string) "\n" t)))

(defun wxhelp-query-var (f re)
  (let (v lines)
    (setq lines (wxhelp-readlines f))
    (catch 'brk
      (dolist (l lines)
        (when (string-match re l)
          (setq v (match-string 1 l))
          (throw 'brk t)
          )
        )
      )
    v
    )
  )

;;;###autoload
(defun wxhelp-browse-api (k)
  (interactive "sAPI or Macro: ")
  (wxhelp-init-hash)
  (let ((c (gethash (downcase (substring k 0 1)) wxhelp-hash))
        hlp
        )
    (when (and c (wx-root-dir))
      (setq hlp (concat (wx-root-dir) "/docs/doxygen/out/html/" c))
      (if (wxhelp-query-var hlp (concat "<li>\\(" k "\\)"))
          (w3m-browse-url hlp)
        ; maybe it's just in gidcmn.h
        (setq hlp (concat (wx-root-dir) "/docs/doxygen/out/html/" "gdicmn_8h.html"))
        (w3m-browse-url hlp)
        )
      (kill-new k)
      (message "%s => clipboard" k)
      )
    )
  )

;;;###autoload
(defun wxhelp-browse-class-or-api (k)
  (interactive "sKeyword: ")
  (let ((rd (wx-root-dir))
        ;; class?
        hlp
        )
    (when rd
      (setq hlp (concat rd "/docs/doxygen/out/html/classwx" (wx-match-strs k) ".html"))
      (if (file-exists-p hlp)
        (w3m-browse-url hlp)
        ;; general topic?
        (setq hlp (concat rd "/docs/doxygen/out/html/group__group__class__" (downcase k) ".html"))
        (if (file-exists-p hlp)
            (w3m-browse-url hlp)
            ;; API or macro?
            (wxhelp-browse-api k)
          )
        )
      )
    )
  )

(provide 'wxhelp)
