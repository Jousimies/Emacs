;; init.el --- Personal Emacs Configuration -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defvar my/init-start-time (current-time) "Time when init.el was started.")
(defvar my/section-start-time (current-time) "Time when section was started.")

;; https://github.com/seagle0128/.emacs.d/blob/master/init.el
(setq auto-mode-case-fold nil)

(unless (or (daemonp) noninteractive init-file-debug)
  (let ((old-file-name-handler-alist file-name-handler-alist))
    (setq file-name-handler-alist nil)
    (add-hook 'emacs-startup-hook
              (lambda ()
                "Recover file name handlers."
                (setq file-name-handler-alist
                      (delete-dups (append file-name-handler-alist
                                           old-file-name-handler-alist)))))))

;; Defer garbage collection further back in the startup process
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda ()
            "Recover GC values after startup."
            (setq gc-cons-threshold 800000)))

;; Suppress flashing at startup
(setq-default inhibit-redisplay t
              inhibit-message t)
(add-hook 'window-setup-hook
          (lambda ()
            (setq-default inhibit-redisplay nil
                          inhibit-message nil)
            (redisplay)))

;; (require 'package)
;; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; (package-initialize)
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
	(url-retrieve-synchronously
	 "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
	 'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'benchmark-init)
(require 'benchmark-init)
(add-hook 'after-init-hook 'benchmark-init/deactivate)

(straight-use-package 'esup)

(defvar my-cloud "~/Nextcloud"
  "This folder is My cloud.")
(defvar my-galaxy (expand-file-name "L.Personal.Galaxy" my-cloud)
  "This folder stores all the plain text files of my life.")
(defvar website-directory "~/Nextcloud/L.Personal.Galaxy/website"
  "The source folder of my blog")
(defvar my/publish-directory "~/shuyi.github.io")

(straight-use-package 'no-littering)

(require 'no-littering)

(straight-use-package 'epkg)
(straight-use-package 'compat)
(straight-use-package 'closql)
(straight-use-package 'emacsql-sqlite)
(straight-use-package 'epkg-marginalia)

(with-eval-after-load 'marginalia
  (cl-pushnew 'epkg-marginalia-annotate-package
        (alist-get 'package marginalia-annotator-registry)))

;; https://www.emacswiki.org/emacs/ExecPath
(defun set-exec-path-from-shell-PATH ()
  "Set up Emacs' `exec-path' and PATH environment variable to match
that used by the user's shell.

This is particularly useful under Mac OS X and macOS, where GUI
apps are not started from a shell."
  (interactive)
  (let ((path-from-shell (replace-regexp-in-string
              "[ \t\n]*$" "" (shell-command-to-string
                      "$SHELL --login -c 'echo $PATH'"
                            ))))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(set-exec-path-from-shell-PATH)

(straight-use-package 'evil)

(setq evil-want-keybinding nil)

(setq evil-undo-system 'undo-fu)

(evil-mode 1)

(straight-use-package 'general)

(straight-use-package 'evil-collection)
(add-hook 'after-init-hook 'evil-collection-init)

(straight-use-package 'which-key)

(which-key-mode 1)
(with-eval-after-load 'which-key
  (setq which-key-idle-delay 0.3))

(server-mode)

(straight-use-package 'restart-emacs)

(general-define-key
 :keymaps '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "q" '(:ignore t :wk "Quit/Restart")
 "qR" '(restart-emacs :wk "Restart emacs"))

(straight-use-package 'magit)

(straight-use-package 'org-auto-tangle)

(add-hook 'org-mode-hook 'org-auto-tangle-mode)

(add-hook 'after-init-hook 'recentf-mode)
(setq recentf-max-saved-items 1000)
(setq recentf-exclude nil)

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "ff" '(find-file :wk "Find file")
 "fr" '(recentf-open-files :wk "Recent files"))

(straight-use-package '(auto-save :type git :host github :repo "manateelazycat/auto-save"))
(require 'auto-save)
(setq auto-save-silent t)
(setq auto-save-delete-trailing-whitespace t)
(add-hook 'after-init-hook 'auto-save-enable)

(straight-use-package 'undo-fu)

(straight-use-package 'undo-fu-session)
(add-hook 'after-init-hook 'global-undo-fu-session-mode)

(straight-use-package 'vundo)
(with-eval-after-load 'vundo
  (setq vundo-glyph-alist vundo-unicode-symbols))
(global-set-key (kbd "C-x u") 'vundo)

(toggle-frame-fullscreen)

(set-frame-font "Iosevka Fixed 16" nil t)
(if (display-graphic-p)
    (dolist (charset '(kana han cjk-misc bopomofo))
      (set-fontset-font (frame-parameter nil 'font)
			charset (font-spec :family "Source Han Serif SC" :height 160))))

(straight-use-package 'doom-themes)
(defun my/apply-theme (appearance)
  "Load theme, taking current system APPEARANCE into consideration."
  (mapc #'disable-theme custom-enabled-themes)
  (pcase appearance
    ('light (load-theme 'doom-nord-light t))
    ('dark (load-theme 'doom-nord t))))
(add-hook 'ns-system-appearance-change-functions #'my/apply-theme)

(defun my/emacs-config ()
  "My literate Emacs configuration."
  (interactive)
  (find-file (expand-file-name "README.org" user-emacs-directory)))

(general-define-key
 :keymaps '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "f" '(:ignore t :wk "Files")
 "fi" '(my/emacs-config :wk "Emacs configuration"))

(defun switch-to-message ()
  "Quick switch to `*Message*' buffer."
  (interactive)
  (switch-to-buffer "*Messages*"))

(defun switch-to-scratch ()
  "Quick switch to `*Scratch*' buffer."
  (interactive)
  (switch-to-buffer "*scratch*"))

(general-define-key
 :keymaps '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "b" '(:ignore t :wk "Buffer/Bibtex")
 "bb" '(switch-to-buffer :wk "Switch buffer")
 "be" '(eval-buffer :wk "Eval buffer")
 "bs" '(switch-to-scratch :wk "Swtich to scratch")
 "bm" '(switch-to-message :wk "Swtich to message"))

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 ";e" '(epkg-describe-package :wk "Epkg"))

(defun toggle-proxy ()
  "Toggle proxy for the url.el library."
  (interactive)
  (if url-proxy-services
      (proxy-disable)
    (proxy-enable)))

(defun proxy-enable ()
  "Enable proxy."
  (interactive)
  (setq url-proxy-services
	  '(("http" . "127.0.0.1:8889")
	    ("https" . "127.0.0.1:8889")
	    ("no_proxy" . "0.0.0.0")))
  (message "Proxy enabled! %s" (car url-proxy-services)))

(defun proxy-disable ()
  "Disable proxy."
  (interactive)
  (if url-proxy-services
      (setq url-proxy-services nil))
  (message "Proxy disabled!"))

(proxy-enable)

(general-define-key
 :keymaps '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "t" '(:ignore t :wk "Toggles")
 "tp" '(proxy-enable :wk "Enable proxy")
 "tP" '(proxy-disable :wk "Disable proxy"))

(setq user-full-name "Duan Ning")
(setq user-mail-address "duan_n@outlook.com")

(message "Rudimentary Configuration: %.2fs"
         (float-time (time-subtract (current-time) my/section-start-time)))

(setq my/section-start-time (current-time))

(straight-use-package 'all-the-icons)

(when (display-graphic-p)
  (require 'all-the-icons))

(with-eval-after-load 'all-the-icons
  (set-fontset-font "fontset-default" 'unicode (font-spec :family "all-the-icons"))  ;;这里不能用 append，否则不工作。
  (set-fontset-font "fontset-default" 'unicode (font-spec :family "file-icons") nil 'append)
  (set-fontset-font "fontset-default" 'unicode (font-spec :family "Material Icons") nil 'append))

(straight-use-package 'all-the-icons-completion)

(all-the-icons-completion-mode)
(add-hook 'marginalia-mode-hook #'all-the-icons-completion-marginalia-setup)

(define-fringe-bitmap 'right-curly-arrow  [])
(define-fringe-bitmap 'left-curly-arrow  [])

(global-hl-line-mode)

(add-hook 'org-mode-hook 'menu-bar--wrap-long-lines-window-edge)
(add-hook 'text-mode-hook 'menu-bar--display-line-numbers-mode-relative)
(add-hook 'prog-mode-hook 'menu-bar--display-line-numbers-mode-relative)

(with-eval-after-load 'time
  (setq display-time-24hr-format t)
  (setq display-time-format "%m/%d %H:%M %a")
  (setq display-time-load-average-threshold nil))

(add-hook 'after-init-hook 'display-time-mode 20)

(straight-use-package 'doom-modeline)

(add-hook 'after-init-hook 'doom-modeline-mode)

(with-eval-after-load 'doom-modeline
  (setq doom-modeline-icon t)
  (setq doom-modeline-height 20))

(straight-use-package '(im-cursor-chg :type git :host github :repo "Jousimies/im-cursor-chg"))

(cursor-chg-mode)

(with-eval-after-load 'im-cursor-chg
  (setq im-cursor-color "red"))

(setq battery-load-critical 15)
(setq battery-mode-line-format " %b%p% ")
(add-hook 'after-init-hook 'display-battery-mode 10)

(straight-use-package 'beacon)

(add-hook 'after-init-hook 'beacon-mode)

(setq show-paren-style 'mixed)
(setq show-paren-context-when-offscreen 'overlay)

(add-hook 'text-mode-hook 'show-paren-mode)

(straight-use-package 'rainbow-mode)

(add-hook 'prog-mode-hook 'rainbow-mode)

(straight-use-package 'rainbow-delimiters)

(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

(add-hook 'text-mode-hook 'electric-pair-mode)

(setq prettify-symbols-alist '(("lambda" . ?λ)
                               ("function" . ?𝑓)))
(add-hook 'prog-mode-hook 'prettify-symbols-mode)

(straight-use-package 'dashboard)

(setq dashboard-startup-banner (expand-file-name "banner.txt" user-emacs-directory))
(setq dashboard-center-content t)
(setq dashboard-set-init-info t)
;; (setq dashboard-set-file-icons t)
;; (setq dashboard-items '((recents  . 5)
;;                         (bookmarks . 5)
;;                         (registers . 5)))
(setq dashboard-items nil)
;; (setq dashboard-set-navigator t)
(add-hook 'after-init-hook 'dashboard-setup-startup-hook)

(setq ring-bell-function 'ignore)
(setq use-short-answers t)
(setq read-process-output-max #x10000)
(setq message-kill-buffer-on-exit t)
(setq message-kill-buffer-query nil)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

(delete-selection-mode 1)

(setq auto-revert-verbose t)
(global-auto-revert-mode 1)

(setq history-length 1000)
(setq savehist-save-minibuffer-history 1)
(setq savehist-additional-variables '(kill-ring
				search-ring
				regexp-search-ring))
(setq history-delete-duplicates t)
(add-hook 'after-init-hook 'savehist-mode)

(add-hook 'after-init-hook 'save-place-mode)

(add-hook 'after-init-hook 'midnight-mode)

(setq minibuffer-prompt-properties
      '(read-only t cursor-intangible t face minibuffer-prompt))

(add-hook 'text-mode-hook 'global-so-long-mode)

(setq large-file-warning-threshold nil)

(setq hippie-expand-try-functions-list '(try-complete-file-name-partially
					 try-complete-file-name
					 try-expand-all-abbrevs
					 try-expand-dabbrev
					 try-expand-dabbrev-all-buffers
					 try-expand-dabbrev-from-kill
					 try-complete-lisp-symbol-partially
					 try-complete-lisp-symbol))

(global-set-key [remap dabbrev-expand] 'hippie-expand)

(add-hook 'after-init-hook 'winner-mode)

(straight-use-package 'corfu)

(global-corfu-mode)

(with-eval-after-load 'corfu
  (setq corfu-auto t)
  (setq corfu-cycle t)
  (setq corfu-quit-at-boundary t)
  (setq corfu-auto-prefix 2)
  (setq corfu-preselect-first t)
  (setq corfu-quit-no-match t)
  (setq completion-cycle-threshold 3))

(defun corfu-enable-always-in-minibuffer ()
  "Enable Corfu in the minibuffer if Vertico/Mct are not active."
  (unless (or (bound-and-true-p mct--active)
      (bound-and-true-p vertico--input))
    (corfu-mode 1)))
(add-hook 'minibuffer-setup-hook #'corfu-enable-always-in-minibuffer 1)

(straight-use-package 'corfu-doc)

(add-hook 'corfu-mode-hook 'corfu-doc-mode)

(straight-use-package 'kind-icon)

(setq kind-icon-default-face 'corfu-default)

(add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter)

(straight-use-package '(vertico
                        :files (:defaults "extensions/*")
                        :includes (vertico-directory)))

(vertico-mode)

(with-eval-after-load 'vertico
  (define-key vertico-map (kbd "C-j") 'vertico-directory-up)
  (setq vertico-cycle t)
  (setq completion-in-region-function
    (lambda (&rest args)
      (apply (if vertico-mode
             #'consult-completion-in-region
           #'completion--in-region)
         args))))


(setq read-file-name-completion-ignore-case t
  read-buffer-completion-ignore-case t
  completion-ignore-case t)

(straight-use-package 'orderless)
(setq completion-styles '(orderless partial-completion)
      completion-category-defaults nil
      completion-category-overrides '((file (styles . (partial-completion)))))

(straight-use-package 'marginalia)
(add-hook 'minibuffer-setup-hook 'marginalia-mode)

;; (with-eval-after-load 'marginalia
;;   (cl-pushnew 'epkg-marginalia-annotate-package
;; 	(alist-get 'package marginalia-annotator-registry)))

(straight-use-package 'consult)

(add-hook 'completion-list-mode-hook 'consult-preview-at-point-mode)

(global-set-key [remap apropos] 'consult-apropos)
(global-set-key [remap bookmark-jump] 'consult-bookmark)

(global-set-key [remap goto-line] 'consult-goto-line)
(global-set-key [remap imenu] 'consult-imenu)
(global-set-key [remap locate] 'consult-locate)
(global-set-key [remap load-theme] 'consult-theme)
(global-set-key [remap man] 'consult-man)
(global-set-key [remap recentf-open-files] 'consult-recent-file)
(global-set-key [remap switch-to-buffer] 'consult-buffer)
(global-set-key [remap switch-to-buffer-other-window] 'consult-buffer-other-window)
(global-set-key [remap switch-to-buffer-other-frame] 'consult-buffer-other-frame)
(global-set-key [remap yank-pop] 'consult-yank-pop)

(with-eval-after-load 'evil
  (evil-declare-key 'normal org-mode-map
    "gh" 'consult-outline))

(straight-use-package 'consult-dir)

(with-eval-after-load 'consult-dir
  (global-set-key (kbd "C-x C-d") 'consult-dir)
  (with-eval-after-load 'vertico
    (define-key vertico-map (kbd "C-x C-d") 'consult-dir)
    (define-key vertico-map (kbd "C-x C-j") 'consult-dir-jump-file)))

(straight-use-package 'embark)
(with-eval-after-load 'embark
  (setq prefix-help-command #'embark-prefix-help-command))

(straight-use-package 'rime)

(setq rime-user-data-dir "~/Library/Rime/")
(setq rime-emacs-module-header-root "/opt/homebrew/Cellar/emacs-plus@28/28.2/include")
(setq rime-librime-root (expand-file-name "librime/dist" user-emacs-directory))
(setq default-input-method "rime")
;; (setq rime-title `(,(propertize (all-the-icons-faicon "pencil-square-o" :v-adjust -0.1)
;;                                'face `(:family ,(all-the-icons-faicon-family)))))
(setq rime-show-candidate 'minibuffer)
(setq rime-posframe-properties '(:internal-border-width 0))
(setq rime-disable-predicates '(rime-predicate-prog-in-code-p
				rime-predicate-org-in-src-block-p
				rime-predicate-org-latex-mode-p
				rime-predicate-current-uppercase-letter-p))

(setq rime-inline-predicates '(rime-predicate-space-after-cc-p
			       rime-predicate-after-alphabet-char-p))

(with-eval-after-load 'rime
  (define-key rime-mode-map (kbd "M-j") 'rime-force-enable))

(with-eval-after-load 'evil
  (add-hook 'evil-insert-state-entry-hook (lambda ()
					    (if (eq major-mode 'org-mode)
						(activate-input-method "rime"))))
  (add-hook 'evil-insert-state-exit-hook #'evil-deactivate-input-method))

(straight-use-package '(rime-regexp :type git :host github :repo "colawithsauce/rime-regexp.el"))

(rime-regexp-mode 1)

(straight-use-package 'hungry-delete)
(global-hungry-delete-mode)

(straight-use-package 'engine-mode)
(with-eval-after-load 'engine-mode
  (defengine google "https://google.com/search?q=%s"
             :keybinding "g"
             :docstring "Search Google.")
  (defengine wikipedia "https://en.wikipedia.org/wiki/Special:Search?search=%s"
             :keybinding "w"
             :docstring "Search Wikipedia.")
  (defengine github "https://github.com/search?ref=simplesearch&q=%s"
             :keybinding "h"
             :docstring "Search GitHub.")
  (defengine baidu "https://www.baidu.com/s?ie=utf-8&wd="
             :keybinding "b"
             :docstring "Search Baidu.")
  (defengine youtube "http://www.youtube.com/results?aq=f&oq=&search_query=%s"
             :keybinding "y"
             :docstring "Search YouTube.")
  (defengine moviedouban "https://search.douban.com/movie/subject_search?search_text=%s"
             :keybinding "m"
             :docstring "Search Moive DouBan.")
  (defengine zhihu "https://www.zhihu.com/search?type=content&q=%s"
             :keybinding "z"
             :docstring "Search Zhihu."))
(add-hook 'after-init-hook 'engine-mode)


(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "s" '(:ignore t :wk "Search")
 "sb" '(engine/search-baidu :wk "Baidu")
 "ss" '(engine/search-google :wk "Google")
 "sG" '(engine/search-github :wk "Github")
 "sy" '(engine/search-youtube :wk "Youtube")
 "sw" '(engine/search-wikipedia :wk "Wikipedia")
 "sm" '(engine/search-moviedouban :wk "Movie DouBan")
 "sz" '(engine/search-zhihu :wk "Zhihu"))

(straight-use-package 'tempel)
(setq tempel-path "~/.emacs.d/template/tempel")

(global-set-key (kbd "M-+") 'tempel-complete)
(global-set-key (kbd "M-*") 'tempel-insert)

(setq insert-directory-program "/opt/homebrew/bin/gls")

(straight-use-package 'dirvish)

(dirvish-override-dired-mode)

(with-eval-after-load 'dirvish
  (setq dirvish-use-header-line 'global)
  (setq dirvish-header-line-format
        '(:left (path) :right (free-space))
        dirvish-mode-line-format
        '(:left (sort file-time " " file-size symlink) :right (omit yank index)))

  (customize-set-variable 'dirvish-quick-access-entries
                          '(("h" "~/"                          "Home")
                            ("d" "~/Downloads/"                "Downloads")
                            ("n" "~/Nextcloud/"                "Nextcloud"))))

(with-eval-after-load 'evil-collection
  (evil-collection-define-key 'normal 'dirvish-mode-map (kbd "q") 'dirvish-quit))

(global-set-key [remap dired] 'dirvish)

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 ";a" '(dirvish-quick-access :wk "Quick access"))

(straight-use-package 'grab-mac-link)

(defun my/link-safari ()
  (interactive)
  (grab-mac-link-dwim 'safari))

(general-define-key
 :keymaps '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "l" '(:ignore t :wk "Link/Language")
 "ls" '(my/link-safari :wk "Grab Safari Link"))

(straight-use-package 'browse-at-remote)

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "fR" '(browse-at-remote :wk "Browse remote"))

(straight-use-package 'helpful)
(setq help-window-select t)
(global-set-key [remap describe-function] 'helpful-callable)
(global-set-key [remap describe-variable] 'helpful-variable)
(global-set-key [remap describe-key] 'helpful-key)

(straight-use-package 'gcmh)

(add-hook 'after-init-hook 'gcmh-mode)
(with-eval-after-load 'gcmh
  (setq gcmh-idle-delay 'auto)
  (setq gcmh-auto-idle-delay-factor 10)
  (setq gcmh-high-cons-threshold #x1000000))

(straight-use-package 'writeroom-mode)

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "tz" '(writeroom-mode :wk "Zen mode"))

(with-eval-after-load 'ispell
  (setq ispell-program-name "/opt/homebrew/bin/aspell")
  (setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_US" "--run-together"))
  (setq ispell-aspell-dict-dir
        (ispell-get-aspell-config-value "dict-dir"))

  (setq ispell-aspell-data-dir
        (ispell-get-aspell-config-value "data-dir"))

  (setq ispell-personal-dictionary (expand-file-name "config/ispell/.aspell.en.pws" my-galaxy)))

(straight-use-package 'wucuo)

(add-hook 'prog-mode-hook #'wucuo-start)
(add-hook 'text-mode-hook #'wucuo-start)

(with-eval-after-load 'flyspell
  (define-key flyspell-mode-map (kbd "C-;") nil)
  (define-key flyspell-mode-map (kbd "C-,") nil)
  (define-key flyspell-mode-map (kbd "C-.") nil))

(straight-use-package 'langtool)

(setq langtool-http-server-host "localhost")
(setq langtool-http-server-port 8081)

(setq dictionary-server "dict.org")

(straight-use-package 'go-translate)

(with-eval-after-load 'go-translate
  (setq gts-translate-list '(("en" "zh")))
  (setq gts-default-translator (gts-translator
                                :picker (gts-noprompt-picker)
                                :engines (list
                                          (gts-google-engine :parser (gts-google-summary-parser)))
                                :render (gts-buffer-render))))


(general-define-key
 :keymaps '(normal visual)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "ll" '(gts-do-translate :wk "Translate"))

(straight-use-package 'lingva)
(with-eval-after-load 'lingva
  (setq lingva-target "zh"))

(general-define-key
 :keymaps '(normal visual)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "lL" '(lingva-translate :wk "Lingva"))

(add-hook 'prog-mode-hook 'flymake-mode)
;; (add-hook 'flymake-mode-hook 'flymake-popon-mode)

(with-eval-after-load 'org
  (setq org-modules '())
  (setq org-imenu-depth 4)
  (setq org-return-follows-link t)
  (setq org-image-actual-width nil)
  (setq org-display-remote-inline-images 'download)
  (setq org-log-into-drawer t)
  (setq org-fast-tag-selection-single-key 'expert)
  (setq org-adapt-indentation nil)
  (setq org-fontify-quote-and-verse-blocks t)
  (setq org-support-shift-select t)
  (setq org-treat-S-cursor-todo-selection-as-state-change nil)
  (setq org-hide-leading-stars nil)
  (setq org-startup-with-inline-images t)
  (setq org-image-actual-width '(500))
  (setq org-use-speed-commands t))

(with-eval-after-load 'org
  (setq org-todo-repeat-to-state t)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "INPROGRESS(i)" "|" "WAIT(w@)" "SOMEDAY(s@)" "CNCL(c@/!)" "DONE(d)")))
  (setq org-todo-state-tags-triggers
        (quote (("CNCL" ("CNCL" . t))
                ("WAIT" ("WAIT" . t))
                ("SOMEDAY" ("WAIT") ("SOMEDAY" . t))
                (done ("WAIT") ("SOMEDAY"))
                ("TODO" ("WAIT") ("CNCL") ("SOMEDAY"))
                ("NEXT" ("WAIT") ("CNCL") ("SOMEDAY"))
                ("DONE" ("WAIT") ("CNCL") ("SOMEDAY"))))))

(with-eval-after-load 'org
  (setq org-babel-python-command "python3")
  ;; (org-babel-do-load-languages
  ;;  'org-babel-load-languages
  ;;  '((emacs-lisp . t)))
  (defun my/org-babel-execute-src-block (&optional _arg info _params)
    "Load language if needed"
    (let* ((lang (nth 0 info))
           (sym (if (member (downcase lang) '("c" "cpp" "c++")) 'C (intern lang)))
           (backup-languages org-babel-load-languages))
      ;; - (LANG . nil) 明确禁止的语言，不加载。
      ;; - (LANG . t) 已加载过的语言，不重复载。
      (unless (assoc sym backup-languages)
        (condition-case err
            (progn
              (org-babel-do-load-languages 'org-babel-load-languages (list (cons sym t)))
              (setq-default org-babel-load-languages (append (list (cons sym t)) backup-languages)))
          (file-missing
           (setq-default org-babel-load-languages backup-languages)
           err)))))
  (advice-add 'org-babel-execute-src-block :before 'my/org-babel-execute-src-block)
  (setq org-confirm-babel-evaluate nil))

(with-eval-after-load 'org
  (setq org-capture-templates '(("a" "Anki Deck")
                                ("ae" "Deck: English" entry (file (lambda () (concat my-galaxy "/anki/anki_english.org")))
                                 "* %?\n" :jump-to-captured t)
                                ("ac" "Deck: Civil Engineering" entry (file (lambda () (concat my-galaxy "/anki/anki_engineering.org")))
                                 "* %?\n" :jump-to-captured t))))

(global-set-key (kbd "<f10>") 'org-capture)

(with-eval-after-load 'org
  (setq org-attach-id-to-path-function-list
        '(org-attach-id-ts-folder-format
          org-attach-id-uuid-folder-format))
  (setq org-attach-dir-relative t))

(with-eval-after-load 'org
  (setq org-refile-targets '((nil :maxlevel . 9)
                             (org-agenda-files :maxlevel . 9)))
  (setq org-refile-use-outline-path t)
  (setq org-outline-path-complete-in-steps nil)
  (setq org-refile-allow-creating-parent-nodes 'confirm)
  (setq org-refile-use-outline-path 'file)
  (setq org-refile-active-region-within-subtree t))

(with-eval-after-load 'ol
  (setq org-link-frame-setup '((vm . vm-visit-folder-other-frame)
                               (vm-imap . vm-visit-imap-folder-other-frame)
                               (gnus . org-gnus-no-new-news)
                               (file . find-file)
                               (wl . wl-other-frame))))

(with-eval-after-load 'org
  (setq org-archive-location (expand-file-name "todos/gtd_archive.org::datetree/" my-galaxy)))
(defun my/gtd-archive ()
  (interactive)
  (find-file (expand-file-name "todos/gtd_archive.org" my-galaxy)))

(with-eval-after-load 'org
  (add-to-list 'org-modules 'org-habit t))

(with-eval-after-load 'org
  (setq org-src-window-setup 'current-window)
  (setq org-src-ask-before-returning-to-edit-buffer nil))

(with-eval-after-load 'org
  (setq org-id-method 'ts)
  (setq org-id-link-to-org-use-id 'create-if-interactive))

(with-eval-after-load 'org
  ;;(org-clock-persistence-insinuate)
  (setq org-clock-history-length 23)
  (setq org-clock-in-resume t)
  (setq org-clock-into-drawer "LOGCLOCK")
  (setq org-clock-out-remove-zero-time-clocks t)
  (setq org-clock-out-when-done t)
  (setq org-clock-persist t)
  (setq org-clock-clocktable-default-properties '(:maxlevel 5 :link t :tags t))
  (setq org-clock-persist-query-resume nil)
  (setq org-clock-report-include-clocking-task t)
  ;; (setq org-clock-out-switch-to-state "DONE")
  (setq org-clock-in-switch-to-state 'bh/clock-in-to-next)
  (setq bh/keep-clock-running nil))

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "oc" '(:ignore t :wk "Clock")
 "ocj" '(org-clock-goto :wk "Clock goto")
 "oci" '(org-clock-in :wk "Clock In")
 "oco" '(org-clock-out :wk "Clock Out"))

(defun bh/is-task-p ()
  "Any task with a todo keyword and no subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (when (member (org-get-todo-state) org-todo-keywords-1)
            (setq has-subtask t))))
      (and is-a-task (not has-subtask)))))
(defun bh/is-project-p ()
  "Any task with a todo keyword subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (when (member (org-get-todo-state) org-todo-keywords-1)
            (setq has-subtask t))))
      (and is-a-task has-subtask))))
(defun bh/find-project-task ()
  "Move point to the parent (project) task if any"
  (save-restriction
    (widen)
    (let ((parent-task (save-excursion (org-back-to-heading 'invisible-ok) (point))))
      (while (org-up-heading-safe)
        (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
          (setq parent-task (point))))
      (goto-char parent-task)
      parent-task)))
(defun bh/is-project-subtree-p ()
  "Any task with a todo keyword that is in a project subtree.
  Callers of this function already widen the buffer view."
  (let ((task (save-excursion (org-back-to-heading 'invisible-ok)
                              (point))))
    (save-excursion
      (bh/find-project-task)
      (if (equal (point) task)
          nil
        t))))
(defun bh/clock-in-to-next (kw)
  "Switch a task from TODO to NEXT when clocking in.
    Skips capture tasks, projects, and subprojects.
    Switch projects and subprojects from NEXT back to TODO"
  (when (not (and (boundp 'org-capture-mode) org-capture-mode))
    (cond
     ((and (member (org-get-todo-state) (list "TODO"))
           (bh/is-task-p))
      "NEXT")
     ((and (member (org-get-todo-state) (list "NEXT"))
           (bh/is-project-p))
      "TODO"))))
(defun bh/punch-in (arg)
  "Start continuous clocking and set the default task to the
  selected task.  If no task is selected set the Organization task
  as the default task."
  (interactive "p")
  (setq bh/keep-clock-running t)
  (if (equal major-mode 'org-agenda-mode)
      ;;
      ;; We're in the agenda
      ;;
      (let* ((marker (org-get-at-bol 'org-hd-marker))
             (tags (org-with-point-at marker (org-get-tags))))
        (if (and (eq arg 4) tags)
            (org-agenda-clock-in '(16))
          (bh/clock-in-default-task-as-default)))
    ;;
    ;; We are not in the agenda
    ;;
    (save-restriction
      (widen)
                                        ; Find the tags on the current task
      (if (and (equal major-mode 'org-mode) (not (org-before-first-heading-p)) (eq arg 4))
          (org-clock-in '(16))
        (bh/clock-in-default-task-as-default)))))
(defun bh/punch-out ()
  (interactive)
  (setq bh/keep-clock-running nil)
  (when (org-clock-is-active)
    (org-clock-out))
  (org-agenda-remove-restriction-lock))
(defun bh/clock-in-default-task ()
  (save-excursion
    (org-with-point-at org-clock-default-task
      (org-clock-in))))
(defun bh/clock-in-parent-task ()
  "Move point to the parent (project) task if any and clock in"
  (let ((parent-task))
    (save-excursion
      (save-restriction
        (widen)
        (while (and (not parent-task) (org-up-heading-safe))
          (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
            (setq parent-task (point))))
        (if parent-task
            (org-with-point-at parent-task
              (org-clock-in))
          (when bh/keep-clock-running
            (bh/clock-in-default-task)))))))
(defvar bh/default-task-id "20220524T114723.420565")
(defun bh/clock-in-default-task-as-default ()
  (interactive)
  (org-with-point-at (org-id-find bh/default-task-id 'marker)
    (org-clock-in '(16))))
(defun bh/clock-out-maybe ()
  (when (and bh/keep-clock-running
             (not org-clock-clocking-in)
             (marker-buffer org-clock-default-task)
             (not org-clock-resolving-clocks-due-to-idleness))
    (bh/clock-in-parent-task)))
(add-hook 'org-clock-out-hook 'bh/clock-out-maybe 'append)
(defun bh/clock-in-last-task (arg)
  "Clock in the interrupted task if there is one
  Skip the default task and get the next one.
  A prefix arg forces clock in of the default task."
  (interactive "p")
  (let ((clock-in-to-task
         (cond
          ((eq arg 4) org-clock-default-task)
          ((and (org-clock-is-active)
                (equal org-clock-default-task (cadr org-clock-history)))
           (caddr org-clock-history))
          ((org-clock-is-active) (cadr org-clock-history))
          ((equal org-clock-default-task (car org-clock-history)) (cadr org-clock-history))
          (t (car org-clock-history)))))
    (widen)
    (org-with-point-at clock-in-to-task
      (org-clock-in nil))))

(general-define-key
 :keymaps '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "ti" '(bh/punch-in :wk "Punch In")
 "to" '(bh/punch-out :wk "Punch Out"))

(with-eval-after-load 'ox-html
  (setq org-html-preamble t)
  (setq org-html-preamble-format '(("en" "<a href=\"/index.html\" class=\"button\">Home</a>
<a href=\"/notes/index.html\" class=\"button\">Notes</a>
<a href=\"/engineering/index.html\" class=\"button\">Engineering</a>
<a href=\"/movies/index.html\" class=\"button\">Movies</a>
<a href=\"/books/index.html\" class=\"button\">Books</a>
<a href=\"/about.html\" class=\"button\">About</a>
<hr>")))

  (setq org-html-postamble t)

  (setq org-html-postamble-format
        '(("en" "<hr><div class=\"generated\">Created with %c on MacOS</div>")))

  (setq org-html-head-include-default-style nil)

  (setq org-html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"../css/style.css\" />"))

(with-eval-after-load 'ox-publish
  (setq org-publish-project-alist
        `(("site"
           :base-directory ,website-directory
           :base-extension "org"
           :recursive nil
           :publishing-directory ,my/publish-directory
           :publishing-function org-html-publish-to-html
           )
          ("notes"
           :base-directory ,(expand-file-name "notes" website-directory)
           :base-extension "org"
           :publishing-directory ,(expand-file-name "notes" my/publish-directory)
           :publishing-function org-html-publish-to-html
           :auto-sitemap t
           :sitemap-filename "index.org"
           :sitemap-title "Notes"
           :sitemap-sort-files anti-chronologically)
          ("books"
           :base-directory ,(expand-file-name "books" website-directory)
           :base-extension "org"
           :publishing-directory ,(expand-file-name "books" my/publish-directory)
           :publishing-function org-html-publish-to-html
           :auto-sitemap t
           :sitemap-filename "index.org"
           :sitemap-title "Books"
           :sitemap-sort-files anti-chronologically)
          ("movies"
           :base-directory ,(expand-file-name "movies" website-directory)
           :base-extension "org"
           :publishing-directory ,(expand-file-name "movies" my/publish-directory)
           :publishing-function org-html-publish-to-html
           :auto-sitemap t
           :sitemap-filename "index.org"
           :sitemap-title "Movies"
           :sitemap-sort-files anti-chronologically)
          ("engineering"
           :base-directory ,(expand-file-name "engineering" website-directory)
           :base-extension "org"
           :publishing-directory ,(expand-file-name "engineering" my/publish-directory)
           :publishing-function org-html-publish-to-html
           :auto-sitemap t
           :sitemap-filename "index.org"
           :sitemap-title "Engineering"
           :sitemap-sort-files anti-chronologically)
          ("static"
           :base-directory ,website-directory
           :base-extension "css\\|txt\\|jpg\\|gif\\|png"
           :recursive t
           :publishing-directory  ,my/publish-directory
           :publishing-function org-publish-attachment)

          ("personal-website" :components ("site" "notes" "books" "movies" "engineering" "static")))))

(defun my/copy-idlink ()
  "Copy idlink to clipboard."
  (interactive)
  (when (eq major-mode 'org-agenda-mode) ;switch to orgmode
    (org-agenda-show)
    (org-agenda-goto))
  (when (eq major-mode 'org-mode) ; do this only in org-mode buffers
    (let* ((mytmphead (nth 4 (org-heading-components)))
           (mytmpid (funcall 'org-id-get-create))
           (mytmplink (format "- [ ] [[id:%s][%s]]" mytmpid mytmphead)))
      (kill-new mytmplink)
      (message "Copied %s to killring (clipboard)" mytmplink))))

(general-define-key
 :keymaps '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "li" '(my/copy-idlink :wk "Copy IDLink"))

(straight-use-package 'toc-org)

(add-hook 'org-mode-hook 'toc-org-mode)

(straight-use-package 'org-superstar)

(add-hook 'org-mode-hook 'org-superstar-mode)

(straight-use-package 'org-download)

(add-hook 'org-mode-hook 'org-download-enable)
(with-eval-after-load 'org-download
  (setq org-download-image-dir (expand-file-name "pictures" my-galaxy))
  (setq org-download-screenshot-method 'screencapture)
  (setq org-download-abbreviate-filename-function 'expand-file-name)
  (setq org-download-timestamp "%Y%m%d%H%M%S")
  (setq org-download-display-inline-images nil)
  (setq org-download-heading-lvl nil)
  (setq org-download-annotate-function (lambda (_link) ""))
  (setq org-download-image-attr-list '("#+NAME: fig: " "#+CAPTION: " "#+ATTR_ORG: :width 500px" "#+ATTR_LATEX: :width 10cm :placement [!htpb]" "#+ATTR_HTML: :width 600px"))
  (setq org-download-screenshot-basename ".png"))

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "od" '(:ignore t :wk "Download")
 "odc" '(org-download-clipboard :wk "Download Clipboard")
 "ody" '(org-download-yank :wk "Download Yank")
 "odr" '(org-download-rename-last-file :wk "Rename last file")
 "odR" '(org-download-rename-at-point :wk "Rename point"))

(straight-use-package '(plantuml :type git :host github :repo "ginqi7/plantuml-emacs"))

(add-hook 'org-mode-hook (lambda ()
                             (require 'plantuml)))
(with-eval-after-load 'plantuml
  (setq plantuml-jar-path
        (concat
         (string-trim
          (shell-command-to-string "readlink -f $(brew --prefix plantuml)"))
         "/libexec/plantuml.jar")))

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "op" '(:ignore t :wk "Plantuml")
 "opm" '(plantuml-org-to-mindmap-open :wk "Mindmap")
 "opw" '(plantuml-org-to-wbs-open :wk "WBS"))

(straight-use-package 'org-drill)

(straight-use-package 'org-appear)

(setq org-appear-trigger 'manual)
(setq org-appear-autolinks t)

(add-hook 'org-mode-hook 'org-appear-mode)

(straight-use-package 'math-preview)
(with-eval-after-load 'math-preview
  (setq math-preview-scale 1.1)
  (setq math-preview-raise 0.3)
  (setq math-preview-margin '(1 . 0)))

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "tm" '(math-preview-all :wk "Math preveiw"))

(straight-use-package 'org-roam)
(with-eval-after-load 'org-roam
  (setq org-roam-db-gc-threshold most-positive-fixnum)
  (setq org-roam-directory (file-truename (expand-file-name "roam" my-galaxy)))
  (add-hook 'org-roam-mode-hook 'turn-on-visual-line-mode)
  (add-hook 'org-mode-hook (lambda ()
                             (setq-local time-stamp-active t
                                         time-stamp-start "#\\+MODIFIED:[ \t]*"
                                         time-stamp-end "$"
                                         time-stamp-format "\[%Y-%m-%d %3a %H:%M\]")
                             (add-hook 'before-save-hook 'time-stamp nil 'local)))
  (add-hook 'after-init-hook 'org-roam-db-autosync-enable)

  (add-to-list 'display-buffer-alist
               '("\\*org-roam\\*"
                 (display-buffer-in-side-window)
                 (side . right)
                 (window-width . 0.25)))
  ;; org-roam-capture
  (setq org-roam-capture-templates '(("a" "articles" plain "%?"
                                      :target (file+head "articles/${slug}.org"
                                                         "#+TITLE: ${title}\n#+CREATED: %U\n#+MODIFIED: \n")
                                      :unnarrowed t)
                                     ("b" "Books" plain (file "~/.emacs.d/template/readinglog")
                                      :target (file+head "books/${slug}.org"
                                                         "#+TITLE: ${title}\n#+CREATED: %U\n#+MODIFIED: \n")
                                      :unnarrowed t)
                                     ("d" "Diary" plain "%?"
                                      :target (file+datetree "daily/<%Y-%m>.org" day))
                                     ("m" "main" plain "%?"
                                      :target (file+head "main/${slug}.org"
                                                         "#+TITLE: ${title}\n#+CREATED: %U\n#+MODIFIED: \n")
                                      :unnarrowed t)
                                     ("p" "people" plain (file "~/.emacs.d/template/crm")
                                      :target (file+head "crm/${slug}.org"
                                                         "#+TITLE: ${title}\n#+CREATED: %U\n#+MODIFIED: \n")
                                      :unnarrowed t)
                                     ("r" "reference" plain (file "~/.emacs.d/template/reference")
                                      :target (file+head "ref/${citekey}.org"
                                                         "#+TITLE: ${title}\n#+CREATED: %U\n#+MODIFIED: \n")
                                      :unnarrowed t)
                                     ("w" "work" plain "%?"
                                      :target (file+head "work/${slug}.org"
                                                         "#+TITLE: ${title}\n#+CREATED: %U\n#+MODIFIED: \n")
                                      :unnarrowed t))))
(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "n" '(:ignore t :wk "Notes")
 "nb" '(org-roam-buffer-toggle :wk "Roam buffer")
 "nr" '(org-roam-node-random :wk "Random node")
 "nf" '(org-roam-node-find :wk "Find node")
 "ni" '(org-roam-node-insert :wk "Insert node")
 "ns" '(org-roam-db-sync :wk "Sync DB")

 "na" '(org-roam-alias-add :wk "Add alias")
 "nA" '(org-roam-alias-remove :wk "Remove alias")
 "nt" '(org-roam-tag-add :wk "Add tag")
 "nT" '(org-roam-tag-remove :wk "Remove tag")

 "nc" '(org-roam-dailies-capture-today :wk "Capture today")
 "nd" '(org-roam-dailies-goto-today :wk "Goto today")
 "nD" '(org-roam-dailies-goto-date :wk "Goto date"))

(add-to-list 'display-buffer-alist
             '("\\*org-roam\\*"
               (display-buffer-in-side-window)
               (side . right)
               (window-width . 0.25)))

(defun my/org-roam-buffer-show (_)
  (when (and (not (minibufferp))
             (not org-roam-capture--node)
             (not (derived-mode-p 'calendar-mode))
             (not org-capture-mode)
             (xor (org-roam-buffer-p) (eq 'visible (org-roam-buffer--visibility))))
    (org-roam-buffer-toggle)))

(add-hook 'window-buffer-change-functions #'my/org-roam-buffer-show)

(with-eval-after-load 'org-roam
  (cl-defmethod org-roam-node-type ((node org-roam-node))
    "Return the TYPE of NODE."
    (condition-case nil
        (file-name-nondirectory
         (directory-file-name
          (file-name-directory
           (file-relative-name (org-roam-node-file node) org-roam-directory))))
      (error "")))

  (cl-defmethod org-roam-node-directories ((node org-roam-node))
    (if-let ((dirs (file-name-directory (file-relative-name (org-roam-node-file node) org-roam-directory))))
        (format "(%s)" (car (split-string dirs "/")))
      ""))

  (cl-defmethod org-roam-node-backlinkscount ((node org-roam-node))
    (let* ((count (caar (org-roam-db-query
                         [:select (funcall count source)
                                  :from links
                                  :where (= dest $s1)
                                  :and (= type "id")]
                         (org-roam-node-id node)))))
      (format "[%d]" count)))

  (cl-defmethod org-roam-node-doom-filetitle ((node org-roam-node))
     "Return the value of \"#+title:\" (if any) from file that NODE resides in.
 If there's no file-level title in the file, return empty string."
     (or (if (= (org-roam-node-level node) 0)
          (org-roam-node-title node)
        (org-roam-get-keyword "TITLE" (org-roam-node-file node)))
         ""))

  (cl-defmethod org-roam-node-doom-hierarchy ((node org-roam-node))
    "Return hierarchy for NODE, constructed of its file title, OLP and direct title.
   If some elements are missing, they will be stripped out."
    (let ((title     (org-roam-node-title node))
          (olp       (org-roam-node-olp   node))
          (level     (org-roam-node-level node))
          (filetitle (org-roam-node-doom-filetitle node))
          (separator (propertize " > " 'face 'shadow)))
      (cl-case level
        ;; node is a top-level file
        (0 filetitle)
        ;; node is a level 1 heading
        (1 (concat (propertize filetitle 'face '(shadow italic))
                   separator title))
        ;; node is a heading with an arbitrary outline path
        (t (concat (propertize filetitle 'face '(shadow italic))
                   separator (propertize (string-join olp " > ") 'face '(shadow italic))
                   separator title)))))

  (setq org-roam-node-display-template (concat "${type:8} ${backlinkscount:3} ${doom-hierarchy:*}" (propertize "${tags:20}" 'face 'org-tag) " ")))

(straight-use-package 'org-roam-ui)
(with-eval-after-load 'org-roam-ui
  (setq org-roam-ui-sync-theme t)
  (setq org-roam-ui-follow t)
  (setq org-roam-ui-update-on-save t)
  (setq org-roam-ui-open-on-start t)

  (require 'websocket))

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "nu" '(org-roam-ui-open :wk "Random node"))

(straight-use-package 'consult-org-roam)

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "ns" '(consult-org-roam-search :wk "Search")
 "nb" '(consult-org-roam-backlinks :wk "Open Backlinks")
 "nl" '(consult-org-roam-forward-links :wk "Open Links"))

(straight-use-package 'org-transclusion)

(face-spec-set 'org-transclusion-fringe
       '((((background light))
          :foreground "black")
         (t
          :foreground "white"))
       'face-override-spec)
(face-spec-set 'org-transclusion-source-fringe
       '((((background light))
          :foreground "black")
         (t
          :foreground "white"))
       'face-override-spec)

(general-define-key :states '(normal visual emacs)
                    :keymaps 'org-mode-map
                    :prefix "SPC m"
                    "t" '(:ignore t :wk "Transclusion")
                    "ta" '(org-transclusion-add :wk "Add")
                    "tA" '(org-transclusion-add-all :wk "Add all")
                    "tr" '(org-transclusion-remove :wk "Remove")
                    "tR" '(org-transclusion-remove-all :wk "Remove all")
                    "tg" '(org-transclusion-refresh :wk "Refresh")
                    "tm" '(org-transclusion-make-from-link :wk "Make link")
                    "to" '(org-transclusion-open-source :wk "Open source")
                    "te" '(org-transclusion-live-sync-start :wk "Edit live"))

(setq org-cite-global-bibliography `(,(concat my-galaxy "/bibtexs/References.bib")
                                     ,(expand-file-name "L.Calibre/calibre.bib" my-cloud)))

(straight-use-package 'citar)
  (with-eval-after-load 'citar
    (setq citar-bibliography org-cite-global-bibliography)

    (setq citar-notes-paths `(,(expand-file-name "roam/ref" my-galaxy)))

    (setq citar-at-point-function 'embark-act)

    (setq citar-templates '((main . "${author editor:30} ${date year issued:4} ${title:48}")
                            (suffix . "${=key= id:15} ${=type=:12} ${tags keywords:*}")
                            (preview . "${author editor} (${year issued date}) ${title}, ${journal journaltitle publisher container-title collection-title}.\n")
                            (note . "${title}")))
    (setq citar-symbols
          `((file ,(all-the-icons-faicon "file-o" :face 'all-the-icons-green :v-adjust -0.1) . " ")
            (note ,(all-the-icons-material "speaker_notes" :face 'all-the-icons-blue :v-adjust -0.3) . " ")
            (link ,(all-the-icons-octicon "link" :face 'all-the-icons-orange :v-adjust 0.01) . " ")))
    (setq citar-symbol-separator "  ")

    (setq citar-open-note-function 'orb-citar-edit-note)

    (setq citar-library-file-extensions (list "pdf" "jpg"))
    (setq citar-file-additional-files-separator "-"))

    (with-eval-after-load 'citar-org
      (define-key citar-org-citation-map (kbd "<return>") 'org-open-at-point)
      (define-key org-mode-map (kbd "C-c C-x @") 'citar-insert-citation))

    (with-eval-after-load 'citar
      (with-eval-after-load 'embark
        (citar-embark-mode 1)))
;; https://blog.tecosaur.com/tmio/2021-07-31-citations.html
(with-eval-after-load 'citar
  (setq org-cite-insert-processor 'citar)
  (setq org-cite-follow-processor 'citar)
  (setq org-cite-activate-processor 'citar))

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "bo" '(citar-open-files :wk "Open bibtex")
 "bO" '(citar-open-entry :wk "Show entry")
 "bn" '(citar-open-note :wk "Open note")
 "bl" '(citar-open-links :wk "Open links"))

(straight-use-package 'citar-org-roam)

(setq citar-org-roam-subdir "ref")
(with-eval-after-load 'org-roam
  (with-eval-after-load 'citar
    (citar-org-roam-mode 1)))

(straight-use-package 'org-roam-bibtex)
(with-eval-after-load 'org-roam-bibtex
  (setq orb-note-actions-interface 'default
        orb-roam-ref-format 'org-cite))
(add-hook 'org-mode-hook 'org-roam-bibtex-mode)

(straight-use-package 'elfeed)

(with-eval-after-load 'elfeed
  (setq elfeed-show-entry-switch #'elfeed-display-buffer))

(with-eval-after-load 'evil
  (evil-set-initial-state 'elfeed-search-mode 'emacs)
  (evil-set-initial-state 'elfeed-show-mode 'emacs))

(defun elfeed-display-buffer (buf &optional act)
  (pop-to-buffer buf '((display-buffer-reuse-window display-buffer-in-side-window)
                       (side . bottom)
                       (window-height . 0.8)
                       (reusable-frames . visible)
                       (window-parameters
                        (select . t)
                        (quit . t)
                        (popup . t)))))

(straight-use-package 'elfeed-org)

(add-hook 'after-init-hook 'elfeed-org)

(with-eval-after-load 'elfeed-org
  (setq rmh-elfeed-org-files `(,(concat my-galaxy "/rss/elfeed.org"))))

(defun my/rss-source ()
  "Open elfeed config file."
  (interactive)
  (find-file (car rmh-elfeed-org-files)))

(straight-use-package 'elfeed-summary)

(setq elfeed-summary-other-window t)
(setq elfeed-summary-settings
      '((group (:title . "科技")
               (:elements (query . (and tec (not emacs) (not blogs)))
                          (group (:title . "Emacs")
                                 (:elements (query . emacs))
                                 (:face . org-level-1))
                          (group (:title . "Blogs")
                                 (:elements (query . blogs)))))
        (group (:title . "News")
               (:elements (query . news)))
        (group (:title . "Books")
               (:elements (query . book)))
        (group (:title . "Finance")
               (:elements (query . finance)))))
(advice-add 'elfeed-summary :after 'elfeed-summary-update)

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "E" '(elfeed-summary :wk "Elfeed"))

(straight-use-package 'ledger-mode)

(with-eval-after-load 'ledger
  (setq ledger-schedule-file (expand-file-name "finance/schedule.ledger" my-galaxy)))

(add-hook 'ledger-mode-hook 'corfu-mode)

(with-eval-after-load 'ledger
  (setq ledger-reports
        '(("bal"            "%(binary) -f %(ledger-file) bal")
          ("bal this month" "%(binary) -f %(ledger-file) bal -p %(month) -S amount")
          ("bal this year"  "%(binary) -f %(ledger-file) bal -p 'this year'")
          ("net worth"      "%(binary) -f %(ledger-file) bal Assets Liabilities")
          ("account"        "%(binary) -f %(ledger-file) reg %(account)")
          ("reg" "%(binary) -f %(ledger-file) reg")
          ("payee" "%(binary) -f %(ledger-file) reg @%(payee)"))))


(defun my/finance-file ()
  "Open finance file."
  (interactive)
  (find-file (expand-file-name "finance/finance.ledger" my-galaxy)))

(general-define-key
 :keymaps '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "fo" '(:ignore t :wk "Open file")
 "fof" '(my/finance-file :wk "Finance file"))

;; https://github.com/jeremyf/dotemacs/blob/main/emacs.d/jf-org-mode.el
(defun jf/org-link-remove-link ()
  "Remove the link part of an org-mode link at point and keep
only the description"
  (interactive)
  (let ((elem (org-element-context)))
    (when (eq (car elem) 'link)
      (let* ((content-begin (org-element-property :contents-begin elem))
             (content-end  (org-element-property :contents-end elem))
             (link-begin (org-element-property :begin elem))
             (link-end (org-element-property :end elem)))
        (when (and content-begin content-end)
          (let ((content (buffer-substring-no-properties content-begin content-end)))
            (delete-region link-begin link-end)
            (insert content)))))))

(general-define-key
 :keymaps '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "lr" '(jf/org-link-remove-link :wk "Link Remove"))

;; http://mbork.pl/2022-10-10_Adding_timestamps_to_youtube_links
(defun yt-set-time (time)
  "Set TIME in the YouTube link at point.
TIME is number of seconds if called from Lisp, and a string if
called interactively. Supported formats:
- seconds
- minutes:seconds
- number of seconds with the \"s\" suffix."
  (interactive (list
                (if current-prefix-arg
                    (prefix-numeric-value current-prefix-arg)
                  (read-string "Time: "))))
  (let ((url (thing-at-point-url-at-point)))
    (if (and url
             (string-match
              (format "^%s"
                      (regexp-opt
                       '("https://www.youtube.com/"
                         "https://youtu.be/")
                       "\\(?:"))
              url))
        (let* ((bounds (thing-at-point-bounds-of-url-at-point))
               (time-present-p (string-match "t=[0-9]+" url))
               (question-mark-present-p (string-search "?" url))
               (seconds (cond
                         ((numberp time)
                          time)
                         ((string-match
                           "^\\([0-9]+\\):\\([0-9]\\{2\\}\\)$" time)
                          (+ (* 60 (string-to-number
                                    (match-string 1 time)))
                             (string-to-number (match-string 2 time))))
                         ((string-match "^\\([0-9]+\\)s?$" time)
                          (string-to-number (match-string 1 time)))
                         (t (error "Wrong argument format"))))
               (new-url (if time-present-p
                            (replace-regexp-in-string
                             "t=[0-9]+"
                             (format "t=%i" seconds)
                             url)
                          (concat url
                                  (if question-mark-present-p "&" "?")
                                  (format "t=%i" seconds)))))
          (delete-region (car bounds) (cdr bounds))
          (insert new-url))
      (error "Not on a Youtube link"))))

(general-define-key
 :keymaps '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "lt" '(yt-set-time :wk "Set Youtube link time"))

;; @https://medium.com/@jakeb0x/straightforward-emacs-show-all-unchecked-org-mode-checkboxes-199f22e8524a
(defun jakebox/org-occur-unchecked-boxes ()
    "Show unchecked Org Mode checkboxes."
    (interactive)
    (occur "\\[ \\]"))
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c o [") 'jakebox/org-occur-unchecked-boxes))

(with-eval-after-load 'org
  (setq org-agenda-files (directory-files-recursively (expand-file-name "todos" my-galaxy) "org$\\|archive$"))
  (setq org-agenda-dim-blocked-tasks t)
  (setq org-agenda-compact-blocks t))

(defun my/gtd-file ()
    (interactive)
    (find-file (expand-file-name "todos/gtd.org" my-galaxy)))

(add-hook 'org-agenda-finalize-hook #'org-agenda-find-same-or-today-or-agenda 90)

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-,") nil)
  (define-key org-mode-map (kbd "C-'") nil))

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "o" '(:ignore t :wk "Org")
 "oa" '(my/org-agenda :wk "Agenda")
 "ot" '(org-todo-list :wk "Todo list")
 "ov" '(org-search-view :wk "View search"))

;; https://github.com/daviwil/dotfiles/blob/master/Emacs.org
(defun vulpea-buffer-tags-get ()
  "Return filetags value in current buffer."
  (vulpea-buffer-prop-get-list "filetags" "[ :]"))
(defun vulpea-buffer-tags-set (&rest tags)
  "Set TAGS in current buffer.
If filetags value is already set, replace it."
  (if tags
  (vulpea-buffer-prop-set
   "filetags" (concat ":" (string-join tags ":") ":"))
    (vulpea-buffer-prop-remove "filetags")))
(defun vulpea-buffer-tags-add (tag)
  "Add a TAG to filetags in current buffer."
  (let* ((tags (vulpea-buffer-tags-get))
     (tags (append tags (list tag))))
    (apply #'vulpea-buffer-tags-set tags)))
(defun vulpea-buffer-tags-remove (tag)
  "Remove a TAG from filetags in current buffer."
  (let* ((tags (vulpea-buffer-tags-get))
     (tags (delete tag tags)))
    (apply #'vulpea-buffer-tags-set tags)))
(defun vulpea-buffer-prop-set (name value)
  "Set a file property called NAME to VALUE in buffer file.
If the property is already set, replace its value."
  (setq name (downcase name))
  (org-with-point-at 1
    (let ((case-fold-search t))
  (if (re-search-forward (concat "^#\\+" name ":\\(.*\\)")
                 (point-max) t)
      (replace-match (concat "#+" name ": " value) 'fixedcase)
    (while (and (not (eobp))
            (looking-at "^[#:]"))
      (if (save-excursion (end-of-line) (eobp))
      (progn
        (end-of-line)
        (insert "\n"))
        (forward-line)
        (beginning-of-line)))
    (insert "#+" name ": " value "\n")))))
(defun vulpea-buffer-prop-set-list (name values &optional separators)
  "Set a file property called NAME to VALUES in current buffer.
VALUES are quoted and combined into single string using
`combine-and-quote-strings'.
If SEPARATORS is non-nil, it should be a regular expression
matching text that separates, but is not part of, the substrings.
If nil it defaults to `split-string-default-separators', normally
\"[ \f\t\n\r\v]+\", and OMIT-NULLS is forced to t.
If the property is already set, replace its value."
  (vulpea-buffer-prop-set
   name (combine-and-quote-strings values separators)))
(defun vulpea-buffer-prop-get (name)
  "Get a buffer property called NAME as a string."
  (org-with-point-at 1
    (when (re-search-forward (concat "^#\\+" name ": \\(.*\\)")
                 (point-max) t)
  (buffer-substring-no-properties
   (match-beginning 1)
   (match-end 1)))))
(defun vulpea-buffer-prop-get-list (name &optional separators)
  "Get a buffer property NAME as a list using SEPARATORS.
If SEPARATORS is non-nil, it should be a regular expression
matching text that separates, but is not part of, the substrings.
If nil it defaults to `split-string-default-separators', normally
\"[ \f\t\n\r\v]+\", and OMIT-NULLS is forced to t."
  (let ((value (vulpea-buffer-prop-get name)))
    (when (and value (not (string-empty-p value)))
  (split-string-and-unquote value separators))))
(defun vulpea-buffer-prop-remove (name)
  "Remove a buffer property called NAME."
  (org-with-point-at 1
    (when (re-search-forward (concat "\\(^#\\+" name ":.*\n?\\)")
                 (point-max) t)
  (replace-match ""))))

(with-eval-after-load 'org
  (with-eval-after-load 'org-roam
    (defun vulpea-project-p ()
      "Return non-nil if current buffer has any todo entry.
TODO entries marked as done are ignored, meaning the this
function returns nil if current buffer contains only completed
tasks."
      (seq-find                                 ; (3)
       (lambda (type)
         (or (eq type 'todo)
             (eq type 'done)))
       (org-element-map                         ; (2)
           (org-element-parse-buffer 'headline) ; (1)
           'headline
         (lambda (h)
           (org-element-property :todo-type h)))))
    (defun vulpea-project-update-tag ()
      "Update PROJECT tag in the current buffer."
      (when (and (not (active-minibuffer-window))
                 (vulpea-buffer-p))
        (save-excursion
          (goto-char (point-min))
          (let* ((tags (vulpea-buffer-tags-get))
                 (original-tags tags))
            (if (vulpea-project-p)
                (setq tags (cons "project" tags))
              (setq tags (remove "project" tags)))
            ;; cleanup duplicates
            (setq tags (seq-uniq tags))
            ;; update tags if changed
            (when (or (seq-difference tags original-tags)
                      (seq-difference original-tags tags))
              (apply #'vulpea-buffer-tags-set tags))))))
    (defun vulpea-buffer-p ()
      "Return non-nil if the currently visited buffer is a note."
      (and buffer-file-name
           (string-prefix-p
            (expand-file-name (file-name-as-directory org-roam-directory))
            (file-name-directory buffer-file-name))))
    (defun vulpea-project-files ()
      "Return a list of note files containing 'project' tag." ;
      (seq-uniq
       (seq-map
        #'car
        (org-roam-db-query
         [:select [nodes:file]
                  :from tags
                  :left-join nodes
                  :on (= tags:node-id nodes:id)
                  :where (like tag (quote "%\"project\"%"))]))))

    (defun vulpea-agenda-files-update (&rest _)
      "Update the value of `org-agenda-files'."
      (setq org-agenda-files (seq-uniq
                              (append
                               (vulpea-project-files)
                               `(,(expand-file-name "todos/gtd.org" my-galaxy))))))

    (add-hook 'find-file-hook #'vulpea-project-update-tag)
    (add-hook 'before-save-hook #'vulpea-project-update-tag)
    (add-hook 'find-file-hook #'vulpea-agenda-files-update)

    (advice-add 'org-agenda :before #'vulpea-agenda-files-update)
    (advice-add 'org-todo-list :before #'vulpea-agenda-files-update)))

(with-eval-after-load 'org
  (setq org-agenda-custom-commands
        '(("A" "Archive"
           ((todo "DONE|CNCL"
                  ((org-agenda-prefix-format " %i")
                   (org-agenda-hide-tags-regexp "project")
                   (org-agenda-overriding-header "Archive")))))
          (" " "GTD Lists: Daily agenda and tasks"
           ((agenda "" ((org-agenda-span 2)
                        (org-deadline-warning-days 3)
                        (org-agenda-block-separator nil)
                        (org-scheduled-past-days 365)
                        (org-agenda-hide-tags-regexp "project")
                        (org-agenda-day-face-function (lambda (date) 'org-agenda-date))
                        (org-agenda-format-date "%A %-e %B %Y")
                        (org-agenda-prefix-format " %i %?-12t% s")
                        (org-agenda-overriding-header "Today's agenda")))
            ;; (agenda "" ((org-agenda-time-grid nil)
            ;;             (org-agenda-start-on-weekday nil)
            ;;             (org-agenda-span 14)
            ;;             (org-agenda-show-all-dates nil)
            ;;             (org-deadline-warning-days 0)
            ;;             (org-agenda-prefix-format " %i")
            ;;             (org-agenda-block-separator nil)
            ;;             (org-agenda-hide-tags-regexp "project")
            ;;             (org-agenda-entry-types '(:deadline))
            ;;             (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
            ;;             (org-agenda-overriding-header "Upcoming deadlines (+14d)")))
            (tags-todo "*"
                       ((org-agenda-skip-function `(org-agenda-skip-entry-if 'deadline
                                                                             'schedule
                                                                             'timestamp
                                                                             'notregexp ,(format "\\[#%s\\]" (char-to-string org-priority-highest))))
                        (org-agenda-hide-tags-regexp "project")
                        (org-agenda-prefix-format " %i")
                        (org-agenda-overriding-header "Important tasks without a date")))
            (todo "NEXT"
                  ((org-agenda-skip-function '(org-agenda-skip-if nil '(timestamp)))
                   (org-agenda-prefix-format " %i")
                   (org-agenda-block-separator nil)
                   (org-agenda-hide-tags-regexp "project")
                   (org-agenda-overriding-header "Next tasks list")))
            (todo "INPROGRESS"
                  ((org-agenda-block-separator nil)
                   (org-agenda-prefix-format " %i")
                   (org-agenda-hide-tags-regexp "project")
                   (org-agenda-overriding-header "Inprogress tasks list")))
            (tags-todo "-Computer-Emacs/TODO"
                       ((org-agenda-skip-function `(org-agenda-skip-entry-if 'deadline
                                                                             'schedule
                                                                             'timestamp
                                                                             'regexp ,(format "\\[#%s\\]" (char-to-string org-priority-highest))))
                        (org-agenda-prefix-format " %i")
                        (org-agenda-hide-tags-regexp "project")
                        (org-agenda-block-separator nil)
                        (org-agenda-overriding-header "Todo tasks list")))
            (tags-todo "Emacs|Computer"
                       ((org-agenda-block-separator nil)
                        (org-agenda-skip-function '(org-agenda-skip-if nil '(timestamp)))
                        (org-agenda-prefix-format " %i")
                        (org-agenda-hide-tags-regexp "project")
                        (org-agenda-overriding-header "Computer science")))
            (tags-todo "Family"
                       ((org-agenda-skip-function '(org-agenda-skip-if nil '(timestamp)))
                        (org-agenda-prefix-format " %i")
                        (org-agenda-hide-tags-regexp "project")
                        (org-agenda-block-separator nil)
                        (org-agenda-overriding-header "Family")))
            (todo "WAIT|SOMEDAY"
                  ((org-agenda-block-separator nil)
                   (org-agenda-prefix-format " %i")
                   (org-agenda-hide-tags-regexp "project")
                   (org-agenda-overriding-header "Tasks on hold"))))))))

(defun my/org-agenda ()
  "Open my org-agenda."
  (interactive)
  (org-agenda "" " "))

(global-set-key (kbd "<f12>") 'my/org-agenda)

(straight-use-package 'ox-hugo)

(with-eval-after-load 'ox
  (require 'ox-hugo))

(straight-use-package 'auctex)

(add-to-list 'auto-mode-alist '("\\.tex\\'" . LaTeX-mode))

(setq TeX-auto-save t)
(setq TeX-parse-self t)

(setq TeX-save-query nil)
(setq TeX-electric-sub-and-superscript t)
(setq TeX-auto-local ".auctex-auto")
(setq TeX-style-local ".auctex-style")
(setq TeX-source-correlate-mode t)
(setq TeX-source-correlate-method 'synctex)
(setq TeX-source-correlate-start-server nil)

(setq-default TeX-master nil)

(setq LaTeX-section-hook '(LaTeX-section-heading
                           LaTeX-section-title
                           LaTeX-section-toc
                           LaTeX-section-section
                           LaTeX-section-label))
(setq LaTeX-fill-break-at-separators nil)
(setq LaTeX-item-indent 0)

(setq org-highlight-latex-and-related '(latex script))
(with-eval-after-load 'ox-latex
  (setq org-latex-classes nil
        org-latex-listings 'minted
        org-export-latex-listings 'minted
        org-latex-minted-options '(("breaklines" "true")
                                   ("breakanywhere" "true")))
  (add-to-list 'org-latex-classes
               '("book"
                 "\\documentclass[UTF8,twoside,a4paper,12pt,openright]{ctexrep}
        [NO-DEFAULT-PACKAGES]
        [NO-PACKAGES]
        [EXTRA]"
                 ("\\chapter{%s}" . "\\chapter*{%s}")
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
  (add-to-list 'org-latex-classes '("article-cn" "\\documentclass{ctexart}
        [NO-DEFAULT-PACKAGES]
        [NO-PACKAGES]
        [EXTRA]"
                                    ("\\section{%s}" . "\\section*{%s}")
                                    ("\\subsection{%s}" . "\\subsection*{%s}")
                                    ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                                    ("\\paragraph{%s}" . "\\paragraph*{%s}")
                                    ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
  (add-to-list 'org-latex-classes '("article" "\\documentclass[11pt]{article}
                    [NO-DEFAULT-PACKAGES]
                    [NO-PACKAGES]
                    [EXTRA]"
                                    ("\\section{%s}" . "\\section*{%s}")
                                    ("\\subsection{%s}" . "\\subsection*{%s}")
                                    ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                                    ("\\paragraph{%s}" . "\\paragraph*{%s}")
                                    ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
  (add-to-list 'org-latex-classes '("beamer" "\\documentclass[presentation]{beamer}
                                    [DEFAULT-PACKAGES]
                                    [PACKAGES]
                                    [EXTRA]"
                                    ("\\section{%s}" . "\\section*{%s}")
                                    ("\\subsection{%s}" . "\\subsection*{%s}")
                                    ("\\subsubsection{%s}" . "\\subsubsection*{%s}"))))

(setq org-latex-pdf-process '("xelatex -8bit --shell-escape  -interaction=nonstopmode -output-directory %o %f"
                              "bibtex -shell-escape %b"
                              "xelatex -8bit --shell-escape  -interaction=nonstopmode -output-directory %o %f"
                              "xelatex -8bit --shell-escape  -interaction=nonstopmode -output-directory %o %f"
                              "rm -fr %b.out %b.log %b.tex %b.brf %b.bbl")
      org-latex-logfiles-extensions '("lof" "lot" "tex~" "aux" "idx" "log" "out" "toc" "nav" "snm" "vrb" "dvi" "fdb_latexmk" "blg" "brf" "fls" "entoc" "ps" "spl" "bbl")
      org-latex-prefer-user-labels t)

(add-hook 'org-mode-hook #'(lambda ()
                             (require 'ox-beamer)))

(straight-use-package 'reftex)

(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
(add-hook 'latex-mode-hook 'turn-on-reftex)

(setq reftex-toc-split-windows-horizontally t)
(setq reftex-toc-split-windows-fraction 0.25)
(add-hook 'reftex-toc-mode-hook 'menu-bar--visual-line-mode-enable)
(add-hook 'reftex-toc-mode-hook #'(lambda () (setq-local mode-line-format nil)))

(straight-use-package 'pdf-tools)

(add-hook 'after-init-hook 'pdf-tools-install)
(setq pdf-view-use-unicode-ligther nil)
;; (run-with-idle-timer 10 nil #'(lambda () (pdf-tools-install)))

;; (add-hook 'doc-view-mode-hook 'pdf-tools-install)
(with-eval-after-load 'pdf-tools
  (add-hook 'pdf-tools-enabled-hook #'(lambda ()
                                        (if (string-equal "dark" (frame-parameter nil 'background-mode))
                                            (pdf-view-themed-minor-mode 1)))))

(with-eval-after-load 'pdf-tools
  (setq pdf-view-use-unicode-ligther nil)
  (setq pdf-view-use-scaling t)
  (setq pdf-view-use-imagemagick nil)
  (setq pdf-annot-activate-created-annotations nil))

(defun my/get-file-name ()
  (interactive)
  (kill-new (file-name-base (buffer-file-name)))
  (message "Copied %s" (file-name-base (buffer-file-name))))

(with-eval-after-load 'pdf-view
    (define-key pdf-view-mode-map (kbd "w") 'my/get-file-name)
    (define-key pdf-view-mode-map (kbd "h") 'pdf-annot-add-highlight-markup-annotation)
    (define-key pdf-view-mode-map (kbd "t") 'pdf-annot-add-text-annotation)
    (define-key pdf-view-mode-map (kbd "d") 'pdf-annot-delete)
    (define-key pdf-view-mode-map (kbd "q") 'kill-this-buffer)
    (define-key pdf-view-mode-map (kbd "y") 'pdf-view-kill-ring-save)
    (define-key pdf-view-mode-map (kbd "G") 'pdf-view-goto-page)
    (define-key pdf-view-mode-map [remap pdf-misc-print-document] 'mrb/pdf-misc-print-pages))

(with-eval-after-load 'pdf-outline
  (define-key pdf-outline-buffer-mode-map (kbd "<RET>") 'pdf-outline-follow-link-and-quit))

(with-eval-after-load 'pdf-annot
  (define-key pdf-annot-edit-contents-minor-mode-map (kbd "<return>") 'pdf-annot-edit-contents-commit)
  (define-key pdf-annot-edit-contents-minor-mode-map (kbd "<S-return>") 'newline))

(defun my/edit-notes ()
  "Edit reference note base pdf name."
  (interactive)
  (if (equal (file-name-extension (buffer-name)) "pdf")
      (consult-bibtex-edit-notes (file-name-sans-extension (buffer-name)))
    (consult-bibtex-edit-notes (consult-bibtex--read-entry))))

(defun my/org-delete-heading-content (heading)
  "Delete content of specific HEADING"
  (org-map-entries
   (lambda ()
     (let ((name (nth 4 (org-heading-components))))
       (if (string= name heading)
	   (save-restriction
	     (org-mark-subtree)
	     (forward-line)
	     (delete-region (region-beginning) (region-end))))))))
(defun my/extract-pdf-annots-to-ref-note ()
  (interactive)
  (let (annots)
    (setf annots (shell-command-to-string (format "pdfannots.py %s" (find-file (buffer-name)))))
    (consult-bibtex-edit-notes (file-name-sans-extension (buffer-name)))
    (my/org-delete-heading-content "Research Contribution")
    (goto-char (org-find-exact-headline-in-buffer "Research Contribution"))
    (forward-line)
    (dolist (item (split-string annots "\n"))
      (if (string-prefix-p "   >" item)
	  (princ (concat (replace-regexp-in-string "   >" "+" item) "\n")
		 (current-buffer))))))

(with-eval-after-load 'pdf-cache
  (define-pdf-cache-function pagelabels))

(with-eval-after-load 'pdf-misc
  (setq pdf-misc-print-program-executable "/usr/bin/lp"))

(defun mrb/pdf-misc-print-pages(filename pages &optional interactive-p)
    "Wrapper for `pdf-misc-print-document` to add page selection support."
    (interactive (list (pdf-view-buffer-file-name)
           (read-string "Page range (empty for all pages): "
                    (number-to-string (pdf-view-current-page)))
           t) pdf-view-mode)
    (let ((pdf-misc-print-program-args
       (if (not (string-blank-p pages))
       (cons (concat "-P " pages) pdf-misc-print-program-args)
         pdf-misc-print-program-args)))
  (pdf-misc-print-document filename)))

(defun pdf-password-protect ()
  "Password protect current pdf in buffer or `dired' file."
  (interactive)
  (unless (executable-find "qpdf")
    (user-error "QPDF not installed"))
  (unless (equal "pdf"
		 (or (when (buffer-file-name)
		       (downcase (file-name-extension (buffer-file-name))))
		     (when (dired-get-filename nil t)
		       (downcase (file-name-extension (dired-get-filename nil t))))))
    (user-error "No pdf to act on"))
  (let* ((user-password (read-passwd "user-password: "))
	 (owner-password (read-passwd "owner-password: "))
	 (input (or (buffer-file-name)
		    (dired-get-filename nil t)))
	 (output (concat (file-name-sans-extension input)
			 "_enc.pdf")))
    (message
     (string-trim
      (shell-command-to-string
       (format "qpdf --verbose --encrypt %s %s 256 -- %s %s"
	       user-password owner-password input output))))))

(straight-use-package 'nov)
(with-eval-after-load 'nov
  (setq nov-unzip-program (executable-find "bsdtar")
        nov-unzip-args '("-xC" directory "-f" filename)))
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))

(straight-use-package 'calibredb)
(with-eval-after-load 'calibredb
  (setq calibredb-root-dir "~/Nextcloud/L.Calibre/")
  (setq calibredb-db-dir (expand-file-name "metadata.db" calibredb-root-dir))
  (setq calibredb-add-delete-original-file t)
  (setq calibredb-size-show t)
  (setq calibredb-format-character-icons t)

  (setq calibredb-ref-default-bibliography (expand-file-name "calibre.bib" calibredb-root-dir)))

(global-set-key (kbd "<f1>") 'calibredb)

(with-eval-after-load 'evil
  (evil-set-initial-state 'calibredb-search-mode 'emacs))

(straight-use-package 'vterm)
(with-eval-after-load 'vterm
  (setq vterm-kill-buffer-on-exit t)
  (setq vterm-max-scrollback 5000))

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "tv" '(vterm :wk "vterm"))

(setq display-time-mail-icon `(,(propertize (all-the-icons-material "mail")
                                            'face `(:family ,(all-the-icons-material-family)))))
(setq message-sendmail-envelope-from 'header)
(setq message-kill-buffer-query nil)
(setq message-sendmail-extra-arguments '("-a" "outlook"))
(setq message-send-mail-function 'sendmail-send-it)

(with-eval-after-load 'mu4e
  (setq send-mail-function 'sendmail-send-it)
  (setq sendmail-program (executable-find "msmtp"))
  (setq mail-specify-envelope-from t)
  (setq mail-envelope-from 'header))

(unless (fboundp 'mu4e)
  (autoload #'mu4e "mu4e" nil t))

(with-eval-after-load 'mu4e
  (setq mu4e-mu-binary "/opt/homebrew/bin/mu")
  (setq mail-user-agent 'mu4e-user-agent)
  (setq mu4e-mu-binary (executable-find "mu"))
  (setq mu4e-update-interval (* 15 60))
  (setq mu4e-attachment-dir "~/Downloads/")
  (setq mu4e-get-mail-command (concat (executable-find "mbsync") " -a"))
  (setq mu4e-index-update-in-background t)
  (setq mu4e-index-update-error-warning t)
  (setq mu4e-index-update-error-warning nil)
  (setq mu4e-index-cleanup t)
  (setq mu4e-view-show-images t)
  (setq mu4e-view-image-max-width 800)
  (setq mu4e-view-show-addresses t)
  (setq mu4e-confirm-quit nil)
  (setq mu4e-context-policy 'pick-first)
  (with-eval-after-load 'mu4e
    (setq mu4e-sent-folder   "/outlook/Sent"
          mu4e-drafts-folder "/outlook/Drafts"
          mu4e-trash-folder  "/outlook/Deleted"
          mu4e-refile-folder  "/outlook/Archive"))
  (setq mu4e-view-prefer-html nil)
  (setq mu4e-html2text-command 'mu4e-shr2text)
  (setq mu4e-main-hide-personal-addresses t)
  (setq mu4e-headers-precise-alignment t)
  (setq mu4e-headers-include-related t)
  (setq mu4e-headers-auto-update t)
  (setq mu4e-headers-date-format "%d/%m/%y")
  (setq mu4e-headers-time-format "%H:%M")
  (setq mu4e-headers-fields '((:flags . 12)
                              (:human-date . 9)
                              (:subject . 90)
                              (:from-or-to . 40)
                              (:tags . 20)))
  (setq mu4e-use-fancy-chars nil)
  (setq mu4e-bookmarks '(("flag:unread AND NOT flag:trashed" "Unread messages" ?u)
                         ("date:today..now" "Today's messages" ?t)
                         ("date:7d..now" "Last 7 days" ?w)
                         ("date:1d..now AND NOT list:emacs-orgmode.gnu.org" "Last 1 days" ?o)
                         ("date:1d..now AND list:emacs-orgmode.gnu.org" "Last 1 days (org mode)" ?m)
                         ("maildir:/drafts" "drafts" ?d)
                         ("flag:flagged AND NOT flag:trashed" "flagged" ?f)
                         ("mime:image/*" "Messages with images" ?p)))
  (setq mu4e-compose-reply-ignore-address '("no-?reply" "duan_n@outlook.com"))
  (setq mu4e-compose-format-flowed nil)
  (setq mu4e-compose-signature-auto-include nil)
  (setq mu4e-compose-dont-reply-to-self t))

(run-with-idle-timer 10 nil #'(lambda () (mu4e 'background)))

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "M" '(mu4e :wk "MAIL"))

(straight-use-package 'mu4e-alert)

(add-hook 'mu4e-index-updated-hook 'mu4e-alert-enable-notifications)
(with-eval-after-load 'mu4e
  (mu4e-alert-enable-mode-line-display))

(straight-use-package 'mu4e-column-faces)

(with-eval-after-load 'mu4e
  (mu4e-column-faces-mode))

(with-eval-after-load 'mu4e-headers
  (setq mu4e-use-fancy-chars t)
  (setq mu4e-headers-list-mark `("s" . ,(propertize
                                         (all-the-icons-material "list")
                                         'face `(:family ,(all-the-icons-material-family)))))
  (setq mu4e-headers-seen-mark `("S" . ,(propertize
                                         (all-the-icons-material "mail_outline")
                                         'face `(:family ,(all-the-icons-material-family)))))

  (setq mu4e-headers-new-mark `("N" . ,(propertize
                                        (all-the-icons-material "markunread")
                                        'face `(:family ,(all-the-icons-material-family)))))

  (setq mu4e-headers-unread-mark `("u" . ,(propertize
                                           (all-the-icons-material "notifications_none")
                                           'face `(:family ,(all-the-icons-material-family)))))
  (setq mu4e-headers-signed-mark `("s" . ,(propertize
                                           (all-the-icons-material "check")
                                           'face `(:family ,(all-the-icons-material-family)))))

  (setq mu4e-headers-encrypted-mark `("x" . ,(propertize
                                              (all-the-icons-material "enhanced_encryption")
                                              'face `(:family ,(all-the-icons-material-family)))))

  (setq mu4e-headers-draft-mark `("D" . ,(propertize
                                          (all-the-icons-material "drafts")
                                          'face `(:family ,(all-the-icons-material-family)))))
  (setq mu4e-headers-attach-mark `("a" . ,(propertize
                                           (all-the-icons-material "attachment")
                                           'face `(:family ,(all-the-icons-material-family)))))
  (setq mu4e-headers-passed-mark `("P" . ,(propertize ; ❯ (I'm participated in thread)
                                           (all-the-icons-material "center_focus_weak")
                                           'face `(:family ,(all-the-icons-material-family)))))
  (setq mu4e-headers-flagged-mark `("F" . ,(propertize
                                            (all-the-icons-material "flag")
                                            'face `(:family ,(all-the-icons-material-family)))))
  (setq mu4e-headers-replied-mark `("R" . ,(propertize
                                            (all-the-icons-material "reply_all")
                                            'face `(:family ,(all-the-icons-material-family)))))
  (setq mu4e-headers-trashed-mark `("T" . ,(propertize
                                            (all-the-icons-material "cancel")
                                            'face `(:family ,(all-the-icons-material-family)))))

  (setq mu4e-headers-personal-mark `("p" . ,(propertize
                                             (all-the-icons-material "person")
                                             'face `(:family ,(all-the-icons-material-family)
                                                             :foreground 'mu4e-special-header-value-face)))))

(straight-use-package 'mu4e-conversation)

(with-eval-after-load 'mu4e
  (global-mu4e-conversation-mode))

(straight-use-package 'telega)

(setq telega-proxies (list '(:server "127.0.0.1" :port 8889 :enable t
                                     :type (:@type "proxyTypeHttp"))))
(setq telega-server-libs-prefix "/opt/homebrew/Cellar/tdlib/1.8.0/include/")

(general-define-key
 :states '(normal visual emacs)
 :prefix "SPC"
 :non-normal-prefix "M-SPC"
 "T" '(telega :wk "Telega"))
