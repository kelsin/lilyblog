;;; lilyblog-autoloads.el --- Sets up correct auto loads for lilyblog.el

;; Copyright (C) 2010  Christopher Giroir

;; Author: Christopher Giroir <cgiroir@berklee.edu>
;; Keywords: 

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

;; Require this file in order to have lilyblog-mode autoload when needed.

;;; Code:

;; Customs
(require 'lilyblog-customs)

;; Main editing mode with auto-mode-alist definitions
(autoload 'lilyblog-mode "lilyblog"
  "A mode to edit LilyBlog posts" t nil)
(add-to-list 'auto-mode-alist '("\\.post$" . lilyblog-mode))
(add-to-list 'auto-mode-alist '("\\.draft$" . lilyblog-mode))

;; Function to create a post
(autoload 'lilyblog-create-post "lilyblog"
  "Create a new LilyBlog post" t nil)

;; Function to edit a post
(autoload 'lilyblog-edit-post "lilyblog"
  "Edit existing LilyBlog post" t nil)

(provide 'lilyblog-autoloads)
;;; lilyblog-autoloads.el ends here
