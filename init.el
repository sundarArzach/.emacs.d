;;; init --- Andrew Schwartzmeyer's Emacs init file

;; Emacs Lisp prefer newer
(setq load-prefer-newer t)

;;; package setup
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(package-initialize)

(defun install-use-package ()
  (when (not (package-installed-p 'use-package))
    (package-install 'use-package)))

(condition-case nil
    (install-use-package)
  (error
   (package-refresh-contents)
   (install-use-package)))

(setq use-package-verbose t
      use-package-always-ensure t)

(eval-when-compile
  (require 'use-package))

(use-package diminish)
(use-package bind-key)
(use-package dash)

(use-package auto-compile
  :config
  (progn
    (auto-compile-on-load-mode)
    (auto-compile-on-save-mode)))

;; for f-expand
(use-package f)

;;; bindings
;; miscellaneous
(bind-key "C-c l" 'align-regexp)
(bind-key "C-c x" 'eval-buffer)
(bind-key "C-c q" 'auto-fill-mode)
(bind-key "C-c v" 'visual-line-mode)
(bind-key "C-c b" 'find-library)

;; isearch
(bind-key "C-s" 'isearch-forward-regexp)
(bind-key "C-r" 'isearch-backward-regexp)
(bind-key "C-M-s" 'isearch-forward)
(bind-key "C-M-r" 'isearch-backward)

;; window management
(bind-key* "M-1" 'delete-other-windows)
(bind-key* "M-2" 'split-window-vertically)
(bind-key* "M-3" 'split-window-horizontally)
(bind-key* "M-0" 'delete-window)

;;; appearance
;; theme (zenburn in terminal, Solarized otherwise)
(use-package solarized-theme
  :ensure nil
  :load-path "lisp/solarized-emacs"
  :if (display-graphic-p)
  :config
  (progn
    ;; disable toolbar and scrollbar
    (tool-bar-mode 0)
    (scroll-bar-mode 0)
    ;; use smooth scrolling
    (use-package smooth-scroll
      :diminish smooth-scroll-mode
      :config
      (progn
	(setq smooth-scroll/vscroll-step-size 8)
	(smooth-scroll-mode)))
    ;; adjust Solarized
    (setq solarized-use-variable-pitch nil
	  solarized-scale-org-headlines nil)
    (load-theme 'solarized-dark t)))

;; line/column numbers in mode-line
(line-number-mode)
(column-number-mode)

;; status
(display-time-mode)
(display-battery-mode)

;; y/n for yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; quit prompt
(setq confirm-kill-emacs 'y-or-n-p)

;; start week on Monday
(setq calendar-week-start-day 1)

;; cursor settings
(blink-cursor-mode)

;; visually wrap lines
(setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))

;; matching parentheses
(show-paren-mode)

;; window undo/redo
(winner-mode)

;;; settings
;; enable all commands
(setq disabled-command-function nil)

;; default truncate lines
(set-default 'truncate-lines t)

;; longer commit summaries
(setq git-commit-summary-max-length 72)

;; disable bell
(setq ring-bell-function 'ignore
      visible-bell t)

;; increase garbage collection threshold
(setq gc-cons-threshold 20000000)

;; inhibit startup message
(setq inhibit-startup-message t)

;; kill settings
(setq save-interprogram-paste-before-kill t
      kill-append-merge-undo t
      kill-do-not-save-duplicates t
      kill-whole-line t)

;; remove selected region if typing
(delete-selection-mode)

;; prefer UTF8
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; set terminfo
(setq system-uses-terminfo nil)

;;; files
;; backups
(setq backup-by-copying t
      delete-old-versions t
      kept-new-versions 4
      kept-old-versions 2
      version-control t
      backup-directory-alist `(("." . ,(f-expand
                                        "backups" user-emacs-directory))))

;; recent files
(setq recentf-max-saved-items 256)
(recentf-mode)

;; final-newline
(setq require-final-newline 't)

;; set auto revert of buffers if file is changed externally
(global-auto-revert-mode)

;; symlink version-control follow
(setq vc-follow-symlinks t)

;; add more modes
(add-to-list 'auto-mode-alist '("\\.ino\\'" . c-mode))
(add-to-list 'auto-mode-alist '("\\.vcsh\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.zsh\\'" . sh-mode))
(add-to-list 'magic-mode-alist '(";;; " . emacs-lisp-mode))

;; dired
(setq dired-dwim-target t ; enable side-by-side dired buffer targets
      dired-recursive-copies 'always ; better recursion in dired
      dired-recursive-deletes 'top
      dired-listing-switches "-lahp")

;; compilation
(setq compilation-ask-about-save nil
      compilation-always-kill t)

;;; functions
;; select whole line
(defun select-whole-line ()
  "Select whole line which has the cursor."
  (interactive)
  (end-of-line)
  (set-mark (line-beginning-position)))
(bind-key "C-c w" 'select-whole-line)

(defun compile-init ()
  "Byte recompile user emacs directory."
  (interactive)
  (byte-recompile-directory user-emacs-directory))

;;; load local settings
(use-package local
  :ensure nil
  :load-path "site-lisp/")

;; load OS X configurations
(use-package osx
  :ensure nil
  :load-path "lisp/"
  :if (eq system-type 'darwin))

;;; extensions
;; ace-jump-mode
(use-package ace-jump-mode
  :functions ace-jump-mode-enable-mark-sync
  :bind (("C-." . ace-jump-mode)
         ("C-," . ace-jump-mode-pop-mark))
  :config (ace-jump-mode-enable-mark-sync))

;; ace-window
(use-package ace-window
  :bind* ("M-s" . ace-window)
  :config (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

;; ag - the silver searcher
(use-package ag
  :commands (ag ag-files ag-regexp ag-project ag-dired helm-ag)
  :config (setq ag-highlight-search t
		ag-reuse-buffers t))

(use-package helm-ag
  :bind ("C-c s" . helm-ag))

;; Mercurial
(use-package ahg
  :commands ahg-status)

;; anzu - number of search matches in modeline
(use-package anzu
  :diminish anzu-mode
  :commands (isearch-forward-regexp isearch-backward-regexp)
  :config (global-anzu-mode))

(use-package auto-package-update
  :config
  (progn
    (setq auto-package-update-interval 1)
    (when (and (apu--should-update-packages-p)
	       (not (string= (getenv "CI") "true"))
	       (y-or-n-p-with-timeout "Update packages?" 5 nil))
      (auto-package-update-now))))

;; bison
(use-package bison-mode
  :mode ("\\.y\\'" "\\.l\\'"))

;; company "complete anything"
(use-package company
  :commands (company-mode)
  :config
  (progn
    (use-package company-c-headers)
    (push '(company-clang
	    :with company-semantic
	    :with company-yasnippet
	    :with company-c-headers)
          company-backends)
    (setq company-minimum-prefix-length 2
          company-idle-delay nil
	  company-global-modes '(not gud-mode))))

(use-package helm-company
  :bind ("<backtab>" . helm-company)
  :commands (helm-company)
  :config
  (progn
    (company-mode)
    (define-key company-mode-map (kbd "C-:") 'helm-company)
    (define-key company-active-map (kbd "C-:") 'helm-company)))

;; crontab
(use-package crontab-mode
  :mode "\\.cron\\(tab\\)?\\'")

;; activate expand-region
(use-package expand-region
  :bind ("C-=" . er/expand-region))

;; flycheck
(use-package flycheck
  :bind ("C-c ! c" . flycheck-buffer)
  :config (global-flycheck-mode))

(use-package helm-flycheck
  :bind ("C-c ! h" . helm-flycheck)
  :config (global-flycheck-mode))

;; flyspell - use aspell instead of ispell
(use-package flyspell
  :commands (flyspell-mode flyspell-prog-mode)
  :config (setq ispell-program-name (executable-find "aspell")
                ispell-extra-args '("--sug-mode=ultra")))

;; git modes
(use-package git-commit-mode)
(use-package gitattributes-mode)
(use-package gitconfig-mode)
(use-package gitignore-mode)

;; gnuplot
(use-package gnuplot
  :commands (gnuplot-mode gnuplot-make-buffer))

;; guide key
(use-package guide-key
  :diminish guide-key-mode
  :config
  (progn
    (setq guide-key/guide-key-sequence t
	  guide-key/idle-delay 2)
    (guide-key-mode)))

;; handlebars
(use-package handlebars-mode)

;; haskell
(use-package haskell-mode
  :mode "\\.\\(?:[gh]s\\|hi\\)\\'"
  :interpreter ("runghc" "runhaskell"))

;; helm
(use-package helm
  :diminish helm-mode
  :bind* (("M-x" . helm-M-x)
	  ("C-c M-x" . execute-extended-command)
	  ("M-]" . helm-command-prefix)
	  ("M-y" . helm-show-kill-ring)
	  ("C-x C-b" . helm-buffers-list)
	  ("C-x b" . helm-mini)
	  ("C-x C-f" . helm-find-files))
  :config
  (progn
    (require 'helm-config)
    (bind-key "C-c !" 'helm-toggle-suspend-update helm-map)
    (bind-key "<tab>" 'helm-execute-persistent-action helm-map)
    (bind-key "C-i" 'helm-execute-persistent-action helm-map)
    (bind-key "C-z" 'helm-select-action helm-map)
    (setq helm-M-x-fuzzy-match t
	  helm-recentf-fuzzy-match t
	  helm-buffers-fuzzy-matching t
	  helm-semantic-fuzzy-match t
	  helm-imenu-fuzzy-match t
	  helm-apropos-fuzzy-match t
	  helm-lisp-fuzzy-completion t
	  helm-move-to-line-cycle-in-source t
	  helm-ff-file-name-history-use-recentf t
	  helm-ff-auto-update-initial-value nil
	  helm-tramp-verbose 9)
    (helm-mode)
    (helm-autoresize-mode t)))

;; ledger
(use-package ledger-mode
  :mode "\\.ledger\\'"
  :config (use-package "flycheck-ledger"))

(use-package less-css-mode)

;; magit
(use-package magit
  :ensure nil
  :load-path "lisp/magit"
  :commands magit-status
  :functions (magit-define-popup-option)
  :config
  (progn
    (setq magit-log-arguments '("--graph" "--decorate" "--show-signature"))
    (magit-define-popup-option 'magit-patch-popup
			       ?S "Subject Prefix" "--subject-prefix=")
    (magit-define-popup-option 'magit-merge-popup
			       ?X "Strategy Option" "--strategy-option=")
    (setq magit-popup-use-prefix-argument 'default
	  magit-revert-buffers t)))

;; markdown
(use-package markdown-mode
  :mode ("\\.markdown\\'" "\\.mk?d\\'" "\\.text\\'"))

(use-package matlab-mode)

;; multi-term
(use-package multi-term
  :commands (multi-term)
  :config
  (progn
    (setq multi-term-program "zsh"
	  term-buffer-maximum-size 10000)
    (add-to-list 'term-bind-key-alist '("M-DEL" . term-send-backward-kill-word))
    (add-to-list 'term-bind-key-alist '("M-d" . term-send-forward-kill-word))))

;; multiple-cursors
(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

(use-package nginx-mode)

;; org mode extensions
(use-package org-plus-contrib
  :mode (("\\.org\\'" . org-mode) ("[0-9]\\{8\\}\\'" . org-mode))
  :init
  (progn
    (use-package org-journal
      :bind ("C-c j" . org-journal-new-entry))
    (use-package org-pomodoro
      :commands (org-pomodoro))
    (add-hook 'org-mode-hook 'turn-on-auto-fill)
    (setq org-latex-listings t
	  org-pretty-entities t
          org-completion-use-ido t
	  org-latex-custom-lang-environments '((C "lstlisting"))
          org-entities-user '(("join" "\\Join" nil "&#9285;" "" "" "⋈")
                              ("reals" "\\mathbb{R}" t "&#8477;" "" "" "ℝ")
                              ("ints" "\\mathbb{Z}" t "&#8484;" "" "" "ℤ")
                              ("complex" "\\mathbb{C}" t "&#2102;" "" "" "ℂ")
                              ("models" "\\models" nil "&#8872;" "" "" "⊧"))
          org-export-backends '(html beamer ascii latex md))
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((emacs-lisp . t) (gnuplot . t) (C . t) (emacs-lisp . t) (haskell . t)
       (latex . t) (ledger . t) (python . t) (ruby . t) (sh . t)))))

;; code folding
(use-package origami
  :bind* ("C-S-o" . origami-mode)
  :config
  (progn
    (add-to-list 'origami-parser-alist '(processing-mode . origami-c-style-parser))
    (bind-keys :prefix-map origami-prefix-map
	       :prefix "C-o"
	       ("o" . origami-recursively-toggle-node)
	       ("a" . origami-toggle-all-nodes)
	       ("c" . origami-show-only-node))))

;; popwin
(use-package popwin
  :config
  (progn
    (popwin-mode)
    ;; cannot use :bind for keymap
    (global-set-key (kbd "C-z") popwin:keymap)))

(use-package powershell)

(use-package processing-mode
  :mode "\\.pde$"
  :config (use-package processing-snippets))

;; projectile
(use-package projectile
  :diminish projectile-mode
  :bind* ("M-[" . projectile-command-map)
  :demand
  :config
  (progn
    (setq projectile-completion-system 'helm
	  projectile-switch-project-action 'helm-projectile
	  projectile-enable-caching t
	  projectile-file-exists-remote-cache-expire (* 10 60))
    (use-package helm-projectile
      :config (helm-projectile-on))
    (projectile-global-mode)))

;; puppet
(use-package puppet-mode)

;; regex tool
(use-package regex-tool
  :commands (regex-tool))

(use-package rust-mode)

;; save kill ring
(use-package savekill)

;; saveplace
(use-package saveplace
  :config
  (setq-default save-place t
                save-place-file (f-expand "saved-places" user-emacs-directory)))
;; scratch
(use-package scratch
  :commands (scratch))

;; use a Lisp commented fortune for the initial scratch message
(when (executable-find "fortune")
  (setq initial-scratch-message
	(concat
	 (mapconcat
	  (lambda (x) (concat ";; " x))
	  (split-string (shell-command-to-string "fortune") "\n" t) "\n")
	 "\n\n")))

;; slime
(use-package sly
  :commands (sly)
  :config (setq inferior-lisp-program (executable-find "sbcl")))

;; smart-mode-line
(use-package smart-mode-line
  :config
  (progn
    (setq sml/theme nil
	  sml/shorten-directory t
	  sml/name-width '(32 . 48)
	  sml/shorten-modes t
	  sml/use-projectile-p 'before-prefixes
	  sml/projectile-replacement-format "[%s]")
    (sml/setup)))

;; smart tabs
(use-package smart-tabs-mode
  :config (smart-tabs-insinuate 'c 'c++ 'python 'ruby))

;; activate smartparens
(use-package smartparens
  :diminish smartparens-mode
  :config
  (progn
    (require 'smartparens-config)
    (smartparens-global-mode)
    (show-smartparens-global-mode)))

(use-package try
  :commands try)

;; undo-tree
(use-package undo-tree
  :diminish undo-tree-mode
  :config
  (progn
    (global-undo-tree-mode)
    (add-to-list 'undo-tree-history-directory-alist
                 `("." . ,(f-expand "undo-tree" user-emacs-directory)))
    (setq undo-tree-auto-save-history t)))

;; unfill autofill
(use-package unfill
  :commands (unfill-region unfill-paragraph toggle-fill-unfill))

;; uniquify
(use-package uniquify
  :ensure nil
  :config (setq uniquify-buffer-name-style 'forward))

;; setup virtualenvwrapper
(use-package virtualenvwrapper
  :commands (venv-workon))

;; way better regexp
(use-package visual-regexp
  :bind ("M-%" . vr/query-replace))

;; whitespace
(use-package whitespace
  :commands (whitespace-mode)
  :config
  (setq whitespace-style '(face tabs spaces newline empty
                                trailing tab-mark newline-mark)))

(use-package whitespace-cleanup-mode
  :diminish whitespace-cleanup-mode
  :config (global-whitespace-cleanup-mode))

;; yaml
(use-package yaml-mode
  :mode "\\.ya?ml\'")

;; yasnippet
(use-package yasnippet
  :commands (yas-expand yas-insert-snippet)
  :config
  (progn
    (use-package java-snippets)
    (yas-minor-mode)))

;;; start server
(server-start)

;;; provide init package
(provide 'init)

;;; init.el ends here
