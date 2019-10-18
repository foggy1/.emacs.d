;;; init.el --- Load all the packages at emacs start

;; Copyright (C) 2019 Austin Lanari

;; Author: Austin Lanari
;; Maintainer: Austin Lanari <austin@jumanji.io>
;; Version: 1.0.0
;; Package-Requires: ((emacs "26.1"))

;;; Commentary:
;;
;; No idea what I'm doing!
;; This is my attempt at coniguring Emacs from scratch.
;; Only big frustration so far is linting unusued vars in Elixir.
;; I really only need on-the-fly linting support.
;; I want to try magit so it's there with the necessary libs.

;;; Code:

;; Not sure if option needed to be set to super
;; But the point of these two lines (esp. the latter) is to bind cmd to meta on mac
(setq mac-option-modifier 'super)
(setq mac-command-modifier 'meta)

;; Turn ido-mode on and make it aggressive for ubiquitous ido
(ido-mode 1)
(ido-everywhere 1)

;; Let's set a default theme!
;; I use this one the most, it's nice.
(load-theme 'misterioso t)

;; Remove trailing whitespace while saving
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; turn off the big yellow alarm when I'm doing bad stuff
(setq ring-bell-function 'ignore)

;; Allow C-v and M-v to reach top or bottom of buffer
(setq scroll-error-top-bottom t)

;; No tabs oh my goodness why
(setq-default indent-tabs-mode nil)

;; Only two tabs for indent in js-mode ugghhhh come on;
(setq js-indent-level 2)

;; Let's save the desktop all the time, fuck it; do it live
(desktop-save-mode 1)

;; smeeeeeex
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;; function that does the loading of libs
;; not sure how the autoload bit works yet, other than knowing my-autoload.el exists that bit does nothing
(defun pnh-reinit-libs ()
  (interactive)
  (let ((generated-autoload-file (concat user-emacs-directory "my-autoload.el")))
    (dolist (d (directory-files (concat user-emacs-directory "lib") t "^[^\.]"))
      (dolist (f (directory-files d t "\\.el$"))
        (byte-compile-file f))
      (update-directory-autoloads d))))

(dolist (l (directory-files (concat user-emacs-directory "lib") nil "^[^\.]"))
  (add-to-list 'load-path (concat user-emacs-directory "lib/" l))
  (autoload (intern l) (concat l ".el")))

(when (not (file-exists-p (concat user-emacs-directory "my-autoload.el")))
  (pnhfunctional
   -reinit-libs))

(load (concat user-emacs-directory "my-autoload.el"))
;; end loading func

;;; Requires!

(require 'better-defaults)
(require 'company)
;; For company
(global-company-mode 1)
(define-key company-active-map (kbd "C-n") 'company-select-next)
(define-key company-active-map (kbd "C-p") 'company-select-previous)
;; end for company

(require 'company-lsp) ;; for lsp-mode w/ company
;; For company-lsp
(push 'company-lsp company-backends)
;; end for company-lsp

(require 'dash) ;; for magit
(require 'dash-functional) ;; for lsp-ui
(require 'dockerfile-mode)
;; For dockerfile-mode
(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))
;; end for dockerfile-mode

(require 'elixir-mode)
(require 'epl) ;; for pkg-info
(require 'exec-path-from-shell)
;; For exec-path-from-shell
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))
;; end for exec-path-from-shell

(require 'f) ;; for lsp-ui
(require 'flycheck)
;; For flycheck
(add-hook 'after-init-hook 'global-flycheck-mode)
(setq flycheck-flake8rc ".flake8")
;; end for flycheck

(require 'flycheck-credo)
;; For flycheck-credo
(eval-after-load 'flycheck
  '(flycheck-credo-setup))
(add-hook 'elixir-mode-hook 'flycheck-mode)
(setq flycheck-elixir-credo-strict t)
;; end for flycheck-credo

(require 'groovy-mode)
;; Frankly we could just require this
;; I'm not sure we need the other benefits of terraform mode
(require 'hcl-mode) ;; for terraform-mode
(require 'ht) ;; for lsp-mode
(require 'ido-completing-read+)
;; For ido-completing-read+
(ido-ubiquitous-mode 1)
;; end for ido-completing-read+


(require 'js2-mode)
(require 'rjsx-mode)
(require 'libgit) ;; for magit
(require 'yasnippet) ;; for lsp-mode with snippets on
(use-package lsp-mode
  :commands lsp
  :diminish lsp-mode
  :hook
  (elixir-mode . lsp)
  :init)

;; Stop asking me root, damnit
(setq lsp-auto-guess-root t)
(setq lsp-file-watch-threshold nil)
;; end for lsp-mode

(require 'lsp-ui) ;; for lsp-mode (literally for it to have a ui)
;; For lsp-ui
;; lsp-ui-doc
;; This thing annoys me
;; In the future, we can allow peeking, I guess, but I don't want it in my face
(setq lsp-ui-doc-enable nil)
;; lsp-ui-flycheck
(setq lsp-ui-flycheck-enable nil)
(require 'magit)
;; For magit
(with-eval-after-load 'info
  (info-initialize)
  (add-to-list 'Info-directory-list
               "~/.emacs.d/lib/magit/Documentation/"))
;; end for magit

(require 'markdown-mode) ;; for lsp-mode and lsp-ui
(require 'pkg-info) ;; for elixir-mode
(require 'projectile)
;; For projectile
(projectile-mode +1)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
;; end for projectile

(require 's) ;; for lsp-ui
(require 'smartparens)
(require 'smartparens-config)
;; For smartparens
;; Turn on smartparens-mode globally by default
(smartparens-global-mode 1)
;; end for smartparens
(require 'smex)
(require 'spinner) ;; for lsp-mode
(require 'switch-window)
;; For switch-window
(setq-default switch-window-shortcut-style 'alphabet)
(setq-default switch-window-timeout nil)
(global-set-key (kbd "C-x o") 'switch-window)
;; end for switch-window

(require 'terraform-mode)
(require 'transient) ;; for magit
(require 'with-editor) ;; for magit
(require 'yaml-mode)


(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(initial-buffer-choice t)
 '(initial-scratch-message
   ";; \"Emacs Ahoy!\" or some shit, idk
(defun hello (name) (insert \"Hello \" name))
(hello \"FOGGY\")

"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
