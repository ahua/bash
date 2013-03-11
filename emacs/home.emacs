(setq make-backup-files nil)

(global-linum-mode 1);
(setq linum-format "%3d \u2502")

(add-to-list 'load-path "~/.emacs.d/")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d//ac-dict")
(ac-config-default)

(add-hook 'c-mode-common-hook 'hs-minor-mode)
(add-hook 'emacs-lisp-mode-hook 'hs-minor-mode)
(add-hook 'java-mode-hook 'hs-minor-mode)
(add-hook 'python-mode-hook 'hs-minor-mode)
(add-hook 'ruby-mode-hook 'hs-minor-mode)

(global-set-key [f1] 'hs-toggle-hiding)
(global-set-key [f2] 'hs-hide-all)
(global-set-key [f3] 'hs-show-all)

