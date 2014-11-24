;; Note on interactive setq:
;; use M-:, which runs the command eval-expression

;; Self-installing/configuring. Nothing else needed to get emacs working for
;; a vimmy clojurer.

(require 'package)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa-stable.milkbox.net/packages/")))
(package-initialize)
(or (file-exists-p package-user-dir)
    (package-refresh-contents))

(defvar package-list '(evil ;; vimmy emacs
                       dash ;; required for clojure-mode
                       pkg-info
                       smex
                       ido-ubiquitous
                       clojure-mode
                       clojure-mode-extra-font-locking
                       better-defaults
                       paredit))
(dolist (p package-list)
  (when (not (package-installed-p p))
    (package-install p)))

(require 'evil)
(evil-mode 1)

(setq
 backup-by-copying t
 backup-directory-alist '(("." . "~/.bak.emacs"))
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control 1)

;;(setq inferior-lisp-load-command nil)
(setq clojure-inf-lisp-command "clojure-repl")

(require 'clojure-mode-extra-font-locking)
(defface clojure-special-chars
    '((t (:foreground "red")))
      "Used for clojure special characters `~@#'%")
(defface clojure-delimiter-chars
    '((t (:foreground "yellow")))
      "Used for clojure delimiters [](){}")
(defun supplement-clojure-font-lock ()
    "Add our extra clojure syntax highlighting"
    (font-lock-add-keywords nil '(("[`~@#'%]" . 'clojure-special-chars)
                                  ("[][(){}]" . 'clojure-delimiter-chars))))

(remove-hook 'clojure-mode-hook 'esk-pretty-fn)
(add-hook 'clojure-mode-hook 'paredit-mode)
(add-hook 'clojure-mode-hook 'supplement-clojure-font-lock)

(defun ensure-clj-repl ()
  "Start a clojure repl using inferior-lisp mode"
  (inferior-lisp "clojure-repl")
  (rename-buffer "*clj-repl*")
  (set-syntax-table clojure-mode-syntax-table)
  (clojure-font-lock-setup)
  (supplement-clojure-font-lock))

(defun clj-repl ()
  "Switch to existing clojure repl or start a new one"
  (interactive)
  (let ((repl-window (get-buffer-window "*clj-repl*")))
    (if repl-window
        (select-window repl-window)
      (split-window nil nil 'left)))
  (when (switch-to-buffer "*clj-repl*")
    (rename-buffer "*inferior-lisp*"))
  (ensure-clj-repl))


(eval-after-load 'paredit '(define-key paredit-mode-map (kbd "M-)") 'paredit-forward-slurp-sexp))
(eval-after-load 'paredit '(define-key paredit-mode-map (kbd "M-}") 'paredit-forward-barf-sexp))
(eval-after-load 'paredit '(define-key paredit-mode-map (kbd "M-(") 'paredit-backward-slurp-sexp))
(eval-after-load 'paredit '(define-key paredit-mode-map (kbd "M-{") 'paredit-backward-barf-sexp))

(add-to-list 'load-path "~/.emacs.d/")

;; Make C-u scroll up a page as in vim.
(setq evil-want-C-u-scroll t)

(setq scroll-conservatively 1)
(setq scroll-margin 3)

;; Define a Clojure style word. (should be limited to .clj files at
;; some point.)
(setq evil-word "-A-Za-z0-9:!#$%&*+<=>?@^_~")

;; Load Evil
(let* ((fname load-file-name)
       (fdir (file-name-directory fname)))
  (add-to-list 'load-path (concat fdir "/evil"))
  (add-to-list 'load-path (concat fdir "/evil/lib")))
(require 'evil)
(evil-mode 1)

;; Newer version of cider appears to take care of this.
;(setq auto-mode-alist  (cons ' ("\\.edn" . clojure-mode) auto-mode-alist))

(global-set-key  (kbd "M-z") 'suspend-emacs) ; Meta+z
(global-set-key  (kbd "M-x") 'smex)
(global-set-key  (kbd "M-X") 'smex-major-mode-commands)
