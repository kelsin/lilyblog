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

;; Date format
(defconst lilyblog-rfc822 "%a, %d %b %Y %H:%M:%S %z")

;; Regexp to parse a blog post's file name
(defconst lilyblog-file-regexp
  "\\([0-9]\\{4\\}\\)\\([0-9][0-9]\\)\\([0-9][0-9]\\)_\\([^\\./]+\\)\\.\\([a-z]\\)+$")

;; Major Mode line
(define-derived-mode lilyblog-mode markdown-mode "LilyBlog"
  "A mode to help in editing LilyBlog posts"
  :group 'lilyblog
  (font-lock-add-keywords nil lilyblog-keyword-regexp)
  (lilyblog-goto-body))

;; Keybindings
(define-key lilyblog-mode-map (kbd "C-c C-g") 'lilyblog-goto-tags)
(define-key lilyblog-mode-map (kbd "C-c C-a") 'lilyblog-add-tag)
(define-key lilyblog-mode-map (kbd "C-c C-b") 'lilyblog-goto-body)
(define-key lilyblog-mode-map (kbd "C-c C-i") 'lilyblog-insert-image)
(define-key lilyblog-mode-map (kbd "C-c C-m") 'lilyblog-image-tag)
(define-key lilyblog-mode-map (kbd "C-c C-o") 'lilyblog-open-post)
(define-key lilyblog-mode-map (kbd "C-c C-h") 'lilyblog-open-github)
(define-key lilyblog-mode-map (kbd "C-c C-d") 'lilyblog-update-date)
(define-key lilyblog-mode-map (kbd "C-c C-t") 'lilyblog-change-title)
(define-key lilyblog-mode-map (kbd "C-c C-p") 'lilyblog-publish)
(define-key lilyblog-mode-map (kbd "C-c C-u") 'lilyblog-unpublish)

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

(defun lilyblog-add-tag (tag)
  "Adds a tag to the tag string"
  (interactive "sTag: ")
  (save-excursion
    (lilyblog-goto-tags)
    (end-of-line)
    (delete-horizontal-space)
    (if (not (equal (char-before) ?:))
        (insert ","))
    (insert (format " %s" (lilyblog-clean-tag tag)))))

(defun lilyblog-chomp (str)
  "Chomp leading and tailing whitespace from STR."
  (let ((s (if (symbolp str) (symbol-name str) str)))
    (replace-regexp-in-string "\\(^[[:space:]\\n]*\\|[[:space:]\\n]*$\\)" "" s)))

(defun lilyblog-clean-tag (tag)
  "Cleans up a tag string just like ruby does"
  (lilyblog-chomp (replace-regexp-in-string
                   "\\(^[-_]*\\|[-_]*$\\)" ""
                   (replace-regexp-in-string
                    "[^0-9a-xA-Z_-]+" "_"
                    (downcase tag)))))

(defun lilyblog-run-rake-task (task &rest args)
  "Runs a rake rake in the post directory"
  (let ((default-directory (expand-file-name (format "%s/.." (buffer-file-name))))
        (rake-args (lilyblog-format-rake-task task args)))
    (message (format "Running \"rake -f ../Rakefile %s\" from %s" rake-args default-directory))
    (process-file "rake" nil nil nil "-f" "../Rakefile" rake-args)))

(defun lilyblog-format-rake-task (task &optional args)
  "Returns the name of a rake task from the arguments and task name"
  (if args
      (format "%s[%s]" task
              (mapconcat 'shell-quote-argument args ","))
    task))

;; Editing Post Functions
(defun lilyblog-insert-image (file title)
  "Inserts an image tag into the current post from a file on the filesystem"
  (interactive "fImage File: \nsTitle: ")
  (let* ((name (lilyblog-clean-tag title))
         (images (lilyblog-image-names file name)))
    (message (format "(lilyblog-image-names %s %s) => %s" file name images))
    (lilyblog-run-rake-task "images:create" file name)
    (lilyblog-copy-image images)
    (lilyblog-image-tag-from-images images title)))

(defun lilyblog-new-extension (file)
  "Returns the new extension we're going to us for this image
based on the original filename"
  (if (equal (file-name-extension file) "jpg")
      "jpg"
    "png"))

(defun lilyblog-image-names (file name)
  "Returns an alist of the two image names"
  (message (format "Filename: %s\nName: %s" file name))
  (let ((ext (lilyblog-new-extension file)))
    (list (cons 'image (concat name "." ext))
          (cons 'thumb (concat name ".thumbnail." ext)))))

(defun lilyblog-image-name (images)
  "Returns the main image name from the images alist"
  (cdr (assoc 'image images)))

(defun lilyblog-thumb-name (images)
  "Returns the thumbnail image name from the images alist"
  (cdr (assoc 'thumb images)))

(defun lilyblog-post-image-folder ()
  (let ((date (gethash :date (lilyblog-parse-filename))))
    (format "%s%s/" lilyblog-image-folder date)))

(defun lilyblog-create-post-image-folder ()
  "Makes sure we have access to this folder"
  (if (file-writable-p lilyblog-image-folder)
      (let ((folder (lilyblog-post-image-folder)))
        (if (file-writable-p folder)
            folder
          (progn (make-directory folder)
                 folder)))))

(defun lilyblog-copy-file (image folder)
  (message (format "Copying image:%s to folder:%s" image folder))
  (let ((from (format "/tmp/%s" image))
        (to (concat folder image)))
    (message (format "Copying %s to %s" from to))
    (copy-file from to)))

(defun lilyblog-copy-image (images)
  "Copies the image files over to the server"
  (if (y-or-n-p (format "Should we copy images to %s?" (lilyblog-post-image-folder)))
      (let ((folder (lilyblog-create-post-image-folder)))
        (message (format "Images: %s" images))
        (if folder
            (let ((image (lilyblog-image-name images))
                  (thumb (lilyblog-thumb-name images)))
              (message (format "Image Filename: %s\nThumbnail Filename: %s" image thumb))
              (lilyblog-copy-file image folder)
              (lilyblog-copy-file thumb folder))))))

(defun lilyblog-full-image-url (image)
  "Returns the full url for an image"
  (let ((date (gethash :date (lilyblog-parse-filename))))
    (format "%s%s/%s" lilyblog-image-url date image)))

(defun lilyblog-image-tag (image thumb title)
  "Formats a markdown tag for an image"
  (interactive "sImage Link: \nsImage Thumbnail Link: \nsImage Title: ")
  (insert (format "[![%s](%s \"%s\")](%s \"%s\")" title thumb title image title)))

(defun lilyblog-image-tag-from-images (image title)
  "Formats markdown for a linked image"
  (lilyblog-image-tag (lilyblog-full-image-url (lilyblog-image-name images))
                      (lilyblog-full-image-url (lilyblog-thumb-name images))
                      title))

(defun lilyblog-open-post (&optional production-site)
  "Saves the current post, and then opens it in a web
browser. This relies on you running a local server at
localhost:3000 with your blog running"
  (interactive "P")
  (save-buffer)
  (lilyblog-system-open (lilyblog-post-url (if production-site
                                               lilyblog-prd-url
                                             lilyblog-dev-url))))

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
                                             current-file)))
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
                  "tags: \n\n")
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
    (puthash :file (replace-regexp-in-string
                    "\\(^-*\\|-*$\\)" ""
                    (replace-regexp-in-string
                     "\[^a-z0-9-\]+" "-"
                     (downcase title))) titles)
    titles))

(defun lilyblog-dates ()
  "Formats the current date in two ways and returns a hash. :post
  refers to the date line that will go in the post file
  while :file refers to the date section of the file name"
  (let ((dates (make-hash-table)))
    (puthash :post
             (replace-regexp-in-string
              "  +" " " (format-time-string lilyblog-rfc822))
             dates)
    (puthash :file
             (format-time-string "%Y%m%d")
             dates)
    dates))

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
    (puthash :date (concat (gethash :year data)
                           (gethash :month data)
                           (gethash :day data)) data)
    data))

(defun lilyblog-post-url (url)
  "Attaches post slug onto url"
  (let ((parts (lilyblog-parse-filename)))
    (concat url
            (gethash :year parts) "/"
            (gethash :month parts) "/"
            (gethash :day parts) "/"
            (gethash :slug parts) "/")))

;; Define lilyblog-system-open depending on which operating system we're on
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
