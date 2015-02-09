;; https://gist.github.com/dzaharee/257476c8ecdf69a471f9
(defun ensure-clj-repl ()
  "Start a clojure repl using inferior-lisp mode"
  (inferior-lisp "clojure-repl")
  ;; (rename-buffer "*clj-repl*") ; Dave experimented with renaming the buffer. I'm experimenting with not doing that.
  (set-syntax-table clojure-mode-syntax-table)
  (clojure-font-lock-setup)
  (supplement-clojure-font-lock))

(defun clj-repl ()
  "Switch to existing clojure repl or start a new one"
  (interactive)
  (let ((repl-window (get-buffer-window "*inferior-lisp*")))
    (if repl-window
        (select-window repl-window)
      (split-window nil nil 'left)))
  (ensure-clj-repl))

(add-hook 'inferior-lisp-mode-hook 'paredit-mode)
(add-hook 'inferior-lisp-mode-hook
          (lambda ()
            (set-syntax-table clojure-mode-syntax-table)))


