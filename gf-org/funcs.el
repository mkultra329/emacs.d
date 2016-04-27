;;; funcs.el --- gf-org layer functions file for Spacemacs.
;;; Commentary:
;;; Code:

(defun gf-org/reload ()
  "Reload the org file for the current month - useful for a long
running emacs instance."
  (interactive)
  (setq gf-org/current-month-last-visited nil)
  ;; Agenda files are only used for searching - my notes are designed to
  ;; work without scheduling, tags etc
  (setq org-agenda-files (append
                          (file-expand-wildcards (concat org-directory "dates/*.org"))
                          (file-expand-wildcards (concat org-directory "topics/*.org"))
                          (file-expand-wildcards (concat org-directory "topics/*/*.org"))))
  (setq org-default-notes-file
        (concat org-directory "dates/"
                (downcase (format-time-string "%Y-%B.org")))))

(defun gf-org/find-current-month-notes-file ()
  "Find the org file for the current month"
  (interactive)
  (setq gf-org/current-month-last-visited (format-time-string "%D"))
  (find-file org-default-notes-file))


;; projects

(defun gf-org/create-org-path (path)
  "Create a name suitable for an org file from the last part of a file
path."
  (let ((last (car (last (split-string (if (equal (substring path -1) "/")
                                           (substring path 0 -1) path) "/")))))
    (concat gf-org/projects-dir "/"
            (downcase
             (replace-regexp-in-string
              "\\." "-" (if (equal (substring last 0 1) ".")
                            (substring last 1) last)))
            ".org")))

(defvar gf-org/project-org-file-overrides '()
  "A list of projectile directories and the specified project org file for them.")

(defun gf-org/resolve-project-org-file ()
  "Get the path of the org file for the current project, either by creating a
suitable name automatically or fetching from gf-org/project-org-file-overrides."
  (gf-org/create-org-path (projectile-project-root)))

(defun gf-org/switch-to-project-org-file ()
  "Switch to the org file for the current project."
  (interactive)
  (find-file (gf-org/resolve-project-org-file)))

(defvar gf-org/previous-project-buffers (make-hash-table :test 'equal))

(defun gf-org/toggle-switch-to-project-org-file ()
  "Alternate between the current buffer and the org file for the
current project."
  (interactive)
  (if (and
       (string-equal "org-mode" (symbol-name major-mode))
       (s-contains-p "/notes/" (buffer-file-name)))
      (if (gethash (buffer-file-name) gf-org/previous-project-buffers)
          (switch-to-buffer (gethash (buffer-file-name) gf-org/previous-project-buffers))
        (error "Previous project buffer not found"))
    (let ((file (gf-org/resolve-project-org-file)))
      (puthash file (current-buffer) gf-org/previous-project-buffers)
      (find-file file))))

;;; funcs.el ends here