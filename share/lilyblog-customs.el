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

(defcustom lilyblog-image-host nil
  "This is a server where you are going to store images. This has
to be a valid tramp string to your image folder."
  :group 'lilyblog
  :type 'string)

(defcustom lilyblog-open-magit-after-publish t
  "This will make lilyblog mode open magit-status after the
lilyblog-publish command"
  :group 'lilyblog
  :type 'boolean)

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
