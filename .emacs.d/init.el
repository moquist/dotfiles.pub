;; Self-installing/configuring. Nothing else needed to get emacs working for
;; a vimmy clojurer.

(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'cider)
  (package-refresh-contents)
  (package-install 'dash) 
  (package-install 'evil) 
  (package-install 'pkg-info) 
  (package-install 'clojure-mode) 
  (package-install 'ido-ubiquitous)
  (package-install 'smex)
  (package-install 'better-defaults)
  (package-install 'paredit)
  (package-install 'cider))

(remove-hook 'clojure-mode-hook 'esk-pretty-fn)
(add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
(setq nrepl-hide-special-buffers t)
;(setq cider-repl-display-in-current-window f)
(setq cider-repl-wrap-history t)
(setq cider-repl-history-size 4000) ; the default is 500
(setq cider-repl-history-file "~/.emacs.d/repl-history")
(setq cider-popup-stacktraces nil)
(add-hook 'cider-repl-mode-hook 'paredit-mode)
(add-hook 'clojure-mode-hook 'paredit-mode)

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
