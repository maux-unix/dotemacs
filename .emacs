;;; Maulana Ali (C) 2024
;;; Emacs Configuration

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; INITIALIZATION
(package-initialize)
(setq custom-file "~/.emacs.custom.el")

(add-to-list 'load-path "~/.emacs.local/")

(load "~/.emacs.local/custom/rc.el")
(load "~/.emacs.local/custom/misc-rc.el")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; APPEARANCE
(defun rc/get-default-font ()
  (cond
   ((eq system-type 'windows-nt) "Consolas-13")
   ((eq system-type 'gnu/linux) "Iosevka-22")))

;; Install ttc-iosevka in your Linux Package Manager
(add-to-list 'default-frame-alist `(font . ,(rc/get-default-font))) 

(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)
(setq-default display-line-numbers 'relative)

(rc/require-theme 'gruber-darker)
;; (rc/require-theme 'zenburn)
;; (load-theme 'adwaita t)

(eval-after-load 'zenburn
  (set-face-attribute 'line-number nil :inherit 'default))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; KEYBINDINGS

;; undo-redo
(global-set-key (kbd "C-z") 'undo-only)
(global-set-key (kbd "C-S-z") 'undo-redo)

;; window-hopping
(defun prev-window ()
  (interactive)
  (other-window -1))

(global-set-key (kbd "C-;") #'other-window)
(global-set-key (kbd "C-'") #'prev-window)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; INSTALL PACKAGES THAT DON'T NEED EXTRA CONFIGURATION

(rc/require
 'fireplace
 'zig-mode
 'rust-mode
 'markdown-mode
 )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PACKAGES' CONFIGURATION

;; always use simpc-mode because cc-mode is f*cking slow
(require 'simpc-mode)
(add-to-list 'auto-mode-alist '("\\.[hc]\\(pp\\)?\\'" . simpc-mode))

;; ido + smex
(rc/require 'smex 'ido-completing-read+)

(require 'ido-completing-read+)

(ido-mode 1)
(ido-everywhere 1)
(ido-ubiquitous-mode 1)

(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;; move-text
(rc/require 'move-text)
(global-set-key (kbd "M-[") 'move-text-up)
(global-set-key (kbd "M-]") 'move-text-down)

;; multiple-cursor
(rc/require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
(global-set-key (kbd "C-\"") 'mc/skip-to-next-like-this)
(global-set-key (kbd "C-:") 'mc/skip-to-previous-like-this)

;; company -> autocompletion
(rc/require 'company)
(require 'company)
(global-company-mode)

(rc/require 'company-c-headers)
(add-to-list 'company-backends 'company-c-headers)
(with-eval-after-load 'company-c-headers
  (define-key simpc-mode-map [(tab)] 'company-complete)
  (define-key c++-mode-map [(tab)] 'company-complete))

;; eglot -> a f*cking simple LSP
(rc/require 'eglot)

(with-eval-after-load 'eglot
  (define-key eglot-mode-map (kbd "<f2>") 'eglot-rename)
  (add-to-list 'eglot-server-programs
               '(simpc-mode . ("ccls"))
               '(c++-mode . ("ccls"))))

(add-hook 'simpc-mode-hook 'eglot-ensure)
(add-hook 'c++-mode-hook 'eglot-ensure)
(add-hook 'java-mode-hook 'eglot-ensure)

;; eglot-java
(rc/require 'eglot-java)
(add-hook 'java-mode-hook 'eglot-java-mode)
(with-eval-after-load 'eglot-java
  (define-key eglot-java-mode-map (kbd "C-c l n") #'eglot-java-file-new)
  (define-key eglot-java-mode-map (kbd "C-c l x") #'eglot-java-run-main)
  (define-key eglot-java-mode-map (kbd "C-c l t") #'eglot-java-run-test)
  (define-key eglot-java-mode-map (kbd "C-c l N") #'eglot-java-project-new)
  (define-key eglot-java-mode-map (kbd "C-c l T") #'eglot-java-project-build-task)
  (define-key eglot-java-mode-map (kbd "C-c l R") #'eglot-java-project-build-refresh))


;;; whitespace mode
(defun rc/set-up-whitespace-handling ()
  (interactive)
  (whitespace-mode 1)
  (add-to-list 'write-file-functions 'delete-trailing-whitespace))

(add-hook 'simpc-mode 'rc/set-up-whitespace-handling)
(add-hook 'c++-mode 'rc/set-up-whitespace-handling)
(add-hook 'java-mode 'rc/set-up-whitespace-handling)
(add-hook 'rust-mode 'rc/set-up-whitespace-handling)

