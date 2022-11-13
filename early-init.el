;;; early-init.el --- Early Init File -*- lexical-binding: t; no-byte-compile: t -*-
;; Defer garbage collection further back in the startup process
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; (setq package-enable-at-startup nil)
;; (setq package-quickstart nil)
;; Prevent the glimpse of un-styled Emacs by disabling these UI elements early.
(setq inhibit-startup-message t)
(setq inhibit-splash-screen t)
(setq inhibit-compacting-font-caches t)

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(fullscreen . maximized) default-frame-alist)
;; Resizing the Emacs frame can be a terribly expensive part of changing the
;; font. By inhibiting this, we easily halve startup times with fonts that are
;; larger than the system default.
;; (setq frame-inhibit-implied-resize t)
;; (setq use-file-dialog nil)
;; (setq use-dialog-box nil)
;; Make the initial buffer load faster by setting its mode to fundamental-mode
;; (setq initial-major-mode 'fundamental-mode)
;; Prevent unwanted runtime builds in gccemacs (native-comp); packages are
;; compiled ahead-of-time when they are installed and site files are compiled
;; when gccemacs is installed.
;; (setq comp-deferred-compilation nil)
;; Disable mode-line, It's uglily after theme changed
;; (setq-default mode-line-format nil)
;;; early-init.el ends here
