;;; lilyblog-customs.el --- Custom definitions for lilyblog

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

;;; Code:

;; Main group
(defgroup lilyblog nil
  "Customization for lilyblog-mode"
  :group 'Data)

;; Post directory
(defcustom lilyblog-post-directory "~/src/lilyblog/posts"
  "This is the root directory of your local lilyblog
install. lilyblog-mode will look here for posts."
  :group 'lilyblog
  :type 'directory)

(defcustom lilyblog-image-folder "~/images/"
  "This is a folder where you are going to store images. This has
to be a valid tramp string to your image folder. This means that
it can be a local folder string as well. As long as a copy file
command works with this string, you can use it."
  :group 'lilyblog
  :type 'string)

(defcustom lilyblog-image-url "http://localhost:3000/"
  "This is the location that you want images linked to in the
blog post."
  :group 'lilyblog
  :type 'string)

(defcustom lilyblog-dev-path "/"
  "Path on dev server to blog."
  :group 'lilyblog
  :type 'string)

(defcustom lilyblog-dev-host "localhost"
  "This is the host to connect to if you want to view a post
locally"
  :group 'lilyblog
  :type 'string)

(defcustom lilyblog-dev-post "3000"
  "This is the port of the locally running web server to connect
to when you want to view a post locally"
  :group 'lilyblog
  :type 'string)

(provide 'lilyblog-customs)
;;; lilyblog-customs.el ends here
