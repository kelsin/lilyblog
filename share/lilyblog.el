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

(define-derived-mode lilyblog-mode markdown-mode "LilyBlog"
  "A mode to help in editing LilyBlog posts"
  :group 'lilyblog
  (let ((inhibit-read-only t))
    (goto-char (point-min))
    (re-search-forward "^$")
    (next-line)
    (lilyblog-set-readonly)))

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
      (lilyblog-set-readonly)
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
      (lilyblog-set-readonly)
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

(defun lilyblog-publish ()
  "Renames the post from draft to post, and pulls open magit"
  (interactive)
  (let* ((current-file (buffer-file-name))
         (new-file (replace-regexp-in-string "\\.draft$" ".post" current-file)))
    (if (not (equal current-file new-file))
        (progn
          (rename-file current-file new-file)
          (set-visited-file-name new-file nil t)
          (if lilyblog-open-magit-after-publish
              (magit-status lilyblog-post-directory))))))

(defun lilyblog-expand-filename (titles dates)
  (expand-file-name (concat (gethash :file dates)
                            "_"
                            (gethash :file titles)
                            ".draft")
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

(defun lilyblog-set-readonly ()
  "Sets the title and date sections of the blog readonly"
  (save-excursion
    (goto-char (point-min))
    (if (re-search-forward "^title: .*$" nil t)
        (add-text-properties (line-beginning-position) (point)
                             '(read-only
                               "Changing the title changes the post's slug, please use M-x lilyblog-change-title"
                               front-sticky
                               (read-only))))
    (goto-char (point-min))
    (if (re-search-forward "^date: .*$" nil t)
        (add-text-properties (line-beginning-position) (point)
                             '(read-only
                               "Changing the date changes the post's slug, please use M-x lilyblog-change-date"
                               front-sticky
                               (read-only))))))

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

(provide 'lilyblog)
;;; lilyblog.el ends here
