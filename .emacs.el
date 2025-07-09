;; -*- mode:emacs-lisp; coding:utf-8; lexical-binding: t; -*-


;; INITIALIZATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(package-initialize)
(setq custom-file "~/.emacs.custom.el")
(add-to-list 'load-path "~/.emacs.local/")
(load "~/.emacs.local/custom/rc.el")
(load "~/.emacs.local/custom/misc-rc.el")



;; APPEARANCE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; (1) Consolas is the default font for code in Win 10/11
;;; (2) Install ttc-iosevka in your GNU/Linux Package Manager
;;; (3) Install SF Mono from https://developer.apple.com/fonts/

(defun rc/get-default-font ()
  (cond
   ((eq system-type 'windows-nt) "Consolas-14")  ; (1)
   ((eq system-type 'gnu/linux)  "Iosevka-22")   ; (2)
   ((eq system-type 'darwin)     "SF Mono-20"))) ; (3)

(add-to-list 'default-frame-alist `(font . ,(rc/get-default-font)))

(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)
(setq-default display-line-numbers 'relative)

(rc/require-theme 'gruber-darker)



;; KEYBINDINGS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; undo-redo -> making a sane undo-redo mechanism in Emacs
(global-set-key (kbd "C-z")   'undo-only)
(global-set-key (kbd "C-S-z") 'undo-redo)

;;; window-hopping -> switching mechanism between windows
(defun prev-window ()
  (interactive)
  (other-window -1))

(global-set-key (kbd "C-;")  #'other-window)
(global-set-key (kbd "C-'")  #'prev-window)



;; INSTALL PACKAGES THAT DON'T NEED EXTRA CONFIGURATION ;;;;;;;;;;;;;;;;;;;;;;;;

(rc/require
 'fireplace
 'zig-mode
 'rust-mode
 'markdown-mode
 'lua-mode
 )



;; PACKAGES' CONFIGURATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; gcmh -> using garbage magic hack
;; (rc/require 'gcmh)
;; (gcmh-mode 1)

;; dashboard -> beautiful startup page
(rc/require 'dashboard)

(setq dashboard-display-icons-p t)
(setq dashboard-icon-type 'nerd-icons)
(setq dashboard-set-file-icons t)
(setq dashboard-set-heading-icons t)
(setq dashboard-banner-logo-title "Welcome to Emacs Dashboard")
(setq dashboard-startup-banner 'logo)
(setq dashboard-center-content t)
(setq dashboard-vertically-center-content t)
(setq dashboard-footer-messages '("Welcome to the Church of Emacs"))

(dashboard-setup-startup-hook)
(setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))


;; nerd-icons -> for pretty looks
(rc/require 'nerd-icons)
(rc/require 'nerd-icons-dired)
(when (display-graphic-p)
  (add-hook 'dired-mode-hook #'nerd-icons-dired-mode))

;;; simpc-mode -> an alternative to the slow cc-mode
(require 'simpc-mode)
(add-to-list 'auto-mode-alist '("\\.[hc]\\(pp\\)?\\'" . simpc-mode))

;;; ido + smex -> built-in minibuffer interfaces + M-x enhancements
(rc/require 'smex 'ido-completing-read+)

(require 'ido-completing-read+)

(ido-mode 1)
(ido-everywhere 1)
(ido-ubiquitous-mode 1)

(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;;; move-text -> moving between lines
(rc/require 'move-text)
(global-set-key (kbd "M-[") 'move-text-up)
(global-set-key (kbd "M-]") 'move-text-down)

;;; multiple-cursor -> making cursors for sane editing
(rc/require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
(global-set-key (kbd "C-\"") 'mc/skip-to-next-like-this)
(global-set-key (kbd "C-:") 'mc/skip-to-previous-like-this)

;;; company -> autocompletion for Emacs
(rc/require 'company)
(require 'company)
(global-company-mode)

;;; eglot -> a sane LSP for Emacs (sometimes I personally  disabled this)
(rc/require 'eglot)

(with-eval-after-load 'eglot
  (define-key eglot-mode-map (kbd "<f2>") 'eglot-rename)
  (add-to-list 'eglot-server-programs
               '(simpc-mode . ("clangd"))
               '(c++-mode   . ("clangd"))
               ))

(add-hook 'simpc-mode-hook 'eglot-ensure)
(add-hook 'c++-mode-hook   'eglot-ensure)
(add-hook 'java-mode-hook  'eglot-ensure)


;;; whitespace mode -> to handle noisy whitespace & clean code formatting
(defun rc/set-up-whitespace-handling ()
  (interactive)
  (whitespace-mode 1)
  (add-to-list 'write-file-functions 'delete-trailing-whitespace))

(add-hook 'simpc-mode 'rc/set-up-whitespace-handling)
(add-hook 'c++-mode 'rc/set-up-whitespace-handling)
(add-hook 'java-mode 'rc/set-up-whitespace-handling)
(add-hook 'rust-mode 'rc/set-up-whitespace-handling)
(add-hook 'f90-mode 'rc/set-up-whitespace-handling)


;;; auctex + pdf-tools -> for LaTeX editing and preview
(rc/require 'auctex)
(rc/require 'pdf-tools)

(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)

(defun reload-pdf ()
  (interactive
  (let* ((fname buffer-file-name)
        (fname-no-ext (substring fname 0 -4))
        (pdf-file (concat fname-no-ext ".pdf"))
        (cmd (format "pdflatex %s" fname)))
    (delete-other-windows)
    (split-window-horizontally)
    (split-window-vertically)
    (shell-command cmd)
    (other-window 2)
    (find-file pdf-file)
    (balance-windows))))

;; (global-set-key "\C-x\p" 'reload-pdf)

;;; magit -> Git client, works like Magick
(rc/require 'magit)


;;; yasnippet -> for creating code snippets
(rc/require 'yasnippet)
(require 'yasnippet)

(setq yas/triggers-in-field nil)
(setq yas-snippet-dirs '("~/.emacs.local/snippets/"))

(yas-global-mode 1)
