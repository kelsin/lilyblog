;;; lilyblog.el --- Mode to help edit LilyBlog posts

;; Copyright (C) 2010  Christopher Giroir

;; Author: Christopher Giroir <cgiroir@berklee.edu>
;; Keywords: convenience, files

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This code provides editor functions to help create and save LilyBlog blog
;; posts. Please see github for more info

;;; Code:

;; Regular expression to find keywords
(defconst lilyblog-keyword-regexp '("^[a-z]+: "))

;; Major Mode line
(define-derived-mode lilyblog-mode markdown-mode "LilyBlog"
  "A mode to help in editing LilyBlog posts"
  :group 'lilyblog
  (font-lock-add-keywords nil lilyblog-keyword-regexp)
  (lilyblog-goto-post))

;; Keybindings
(define-key lilyblog-mode-map (kbd "C-c g") 'lilyblog-goto-tags)
(define-key lilyblog-mode-map (kbd "C-c b") 'lilyblog-goto-body)
(define-key lilyblog-mode-map (kbd "C-c i") 'lilyblog-insert-image)
(define-key lilyblog-mode-map (kbd "C-c o") 'lilyblog-open-post)
(define-key lilyblog-mode-map (kbd "C-c h") 'lilyblog-open-github)
(define-key lilyblog-mode-map (kbd "C-c d") 'lilyblog-update-date)
(define-key lilyblog-mode-map (kbd "C-c t") 'lilyblog-change-title)
(define-key lilyblog-mode-map (kbd "C-c p") 'lilyblog-publish)
(define-key lilyblog-mode-map (kbd "C-c u") 'lilyblog-unpublish)

;; Movement commands
(defun lilyblog-goto-body ()
  "Moves cursor to the first line of the body"
  (interactive)
  (goto-char (point-min))
  (re-search-forward "\n\n"))

(defun lilyblog-goto-tags ()
  "Moves cursor to the tags line"
  (interactive)
  (goto-char (point-min))
  (re-search-forward "^tags: "))

;; Editing Post Functions
(defun lilyblog-insert-image (file name title)
  "Inserts an image tag into the current post from a file on the filesystem"
  (interactive))

(defun lilyblog-open-post ()
  "Saves the current post, and then opens it in a web
browser. This relies on you running a local server at
localhost:3000 with your blog running"
  (interactive)
  (save-buffer)
  (let ((current-file (buffer-file-name)))
    (lilyblog-system-open (lilyblog-dev-url))))

(defun lilyblog-open-github ()
  "Opens the LilyBlog github page"
  (interactive)
  (lilyblog-system-open "http://github.com/Kelsin/lilyblog"))

(defun lilyblog-update-date ()
  "Sets the date of this blog post to the current date"
  (interactive)
  (let* ((new-dates (lilyblog-dates))
         (current-file (buffer-file-name))
         (new-file (replace-regexp-in-string "/[0-9]\\{8\\}_\\([^\\./]+\\)\\."
                                             (concat "/"
                                                     (gethash :file new-dates)
                                                     "_\\1.")
                                             current-file))
         (inhibit-read-only t))
    (save-excursion
      (goto-char (point-min))
      (perform-replace "^date: .*$"
                       (concat "date: "
                               (gethash :post new-dates))
                       nil t nil)
      (if (not (equal current-file new-file))
          (progn
            (rename-file current-file new-file)
            (set-visited-file-name new-file nil t))))))

(defun lilyblog-change-title (title)
  "Sets the title of this blog post"
  (interactive "sTitle: ")
  (let* ((new-titles (lilyblog-titles title))
         (current-file (buffer-file-name))
         (new-file (replace-regexp-in-string "/\\([0-9]\\{8\\}\\)_[^\\./]+\\."
                                             (concat "/\\1_"
                                                     (gethash :file new-titles)
                                                     ".")
                                             current-file))
         (inhibit-read-only t))
    (save-excursion
      (goto-char (point-min))
      (perform-replace "^title: .*$"
                       (concat "title: "
                               (gethash :post new-titles))
                       nil t nil)
      (if (not (equal current-file new-file))
          (progn
            (rename-file current-file new-file)
            (set-visited-file-name new-file nil t))))))

(defun lilyblog-create-post ()
  "Creates a new post"
  (interactive)
  (let* ((titles (lilyblog-get-title))
         (dates (lilyblog-dates))
         (file (lilyblog-check-new-post-file (lilyblog-expand-filename titles dates))))
    (if file
        (progn
          (if (not (file-accessible-directory-p lilyblog-post-directory))
              (make-directory lilyblog-post-directory))
          (switch-to-buffer (find-file-noselect (expand-file-name file lilyblog-post-directory) nil t))
          (goto-char (point-min))
          (insert "title: " (gethash :post titles) "\n"
                  "date: " (gethash :post dates) "\n"
                  "tags:\n\n")
          (after-find-file)))))

(defun lilyblog-edit-post ()
  "Opens up the post directory so that you can find a post to edit"
  (interactive)
  (if (file-accessible-directory-p lilyblog-post-directory)
      (dired lilyblog-post-directory)
    (message "No posts created yet")))

(defun lilyblog-rename-file (new-file)
  "Renames current file to new-file if the name is different than
the current name"
  (if (not (equal (buffer-file-name) new-file))
      (progn
        (rename-file (buffer-file-name) new-file)
        (set-visited-file-name new-file nil t))))

(defun lilyblog-set-extension (ext)
  "Renames the extension on the current file"
  (lilyblog-rename-file (concat (file-name-sans-extension (buffer-file-name))
                                "." ext)))

(defun lilyblog-publish ()
  "Renames the post from .draft to .post"
  (interactive)
  (lilyblog-set-extension "post"))

(defun lilyblog-unpublish ()
  "Renames the post from .post to .draft"
  (interactive)
  (lilyblog-set-extension "draft"))

(defun lilyblog-expand-filename (titles dates &optional type)
  (expand-file-name (concat (gethash :file dates)
                            "_" (gethash :file titles)
                            "." (if type type "draft"))
                    lilyblog-post-directory))

(defun lilyblog-check-new-post-file (file)
  "This makes sure the file doesn't exist already. If it does it asks the user if it wants to make a backup"
  (if (file-exists-p file)
      (if (y-or-n-p "File already exists, should we back up the other file in order to make room? ")
          (progn
            (let ((buffer (find-buffer-visiting file)))
              (if buffer
                  (progn
                    (with-current-buffer buffer
                      (save-buffer))
                    (kill-buffer buffer))))
            (rename-file file (concat file ".bak") nil)
            file)
        (if (y-or-n-p "Overwrite existing file? ")
            (progn
              (let ((buffer (find-buffer-visiting file)))
                (if buffer
                    (progn
                      (with-current-buffer buffer
                        (set-buffer-modified-p nil))
                      (kill-buffer buffer))))
              (delete-file file)
              file)))
    file))

(defun lilyblog-get-title ()
  "Asks the user for a title and returns both versions of it"
  (lilyblog-titles (read-from-minibuffer "Title: ")))

(defun lilyblog-titles (title)
  "Returns two versions of the title in a hash hash. The :post
  key refers to the title in the post file while :file refers to
  the slug"
  (let ((titles (make-hash-table)))
    (puthash :post title titles)
    (puthash :file (replace-regexp-in-string "\[^a-z0-9-\]+" "-" (downcase title)) titles)
    titles))

(defun lilyblog-dates ()
  "Formats the current date in two ways and returns a hash. :post
  refers to the date line that will go in the post file
  while :file refers to the date section of the file name"
  (let ((dates (make-hash-table)))
    (puthash :post
             (replace-regexp-in-string "  +"
                                       " "
                                       (format-time-string "%A, %B %e, %Y at %l:%M%P"))
             dates)
    (puthash :file
             (format-time-string "%Y%m%d")
             dates)
    dates))

(defconst lilyblog-file-regexp "\\([0-9]\\{4\\}\\)\\([0-9][0-9]\\)\\([0-9][0-9]\\)_\\([^\\./]+\\)\\.\\([a-z]\\)+$")

(defun lilyblog-get-post-file ()
  "Gets the current buffers file name without directory"
  (file-name-nondirectory (buffer-file-name)))

(defun lilyblog-get-post-file-part (part)
  "Returns a certain match from the regexp post file"
  (replace-regexp-in-string lilyblog-file-regexp
                            (format "\\%d" part)
                            (lilyblog-get-post-file)))

(defun lilyblog-parse-filename ()
  "Returns the current post information from filename"
  (let ((data (make-hash-table)))
    (puthash :year (lilyblog-get-post-file-part 1) data)
    (puthash :month (lilyblog-get-post-file-part 2) data)
    (puthash :day (lilyblog-get-post-file-part 3) data)
    (puthash :slug (lilyblog-get-post-file-part 4) data)
    (puthash :type (lilyblog-get-post-file-part 5) data)
    data))

(defun lilyblog-dev-url ()
  "Returns the dev url to use for viewing the current post"
  (let ((parts (lilyblog-parse-filename)))
    (concat "http://" lilyblog-dev-host ":" lilyblog-dev-post lilyblog-dev-path
            (gethash :year parts) "/"
            (gethash :month parts) "/"
            (gethash :day parts) "/"
            (gethash :slug parts) "/")))

(cond ((string-match "darwin" (symbol-name system-type))
       (defun lilyblog-system-open (item)
         "Opens an item with open"
         (call-process "/usr/bin/env" nil nil nil
                       "open"
                       item)))
      ((string-match "linux" (symbol-name system-type))
       (defun lilyblog-system-open (item)
         "Opens an item with gnome-open"
         (call-process "/usr/bin/env" nil nil nil
                       "gnome-open"
                       item))))

(provide 'lilyblog)
;;; lilyblog.el ends here
