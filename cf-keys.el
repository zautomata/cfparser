(load "cf-main.el")

(defun cf-login-i()
  "Login to Codeforces using handle/password."
  (interactive)
  (let ((cf-uname (read-string "usename: "))
	(cf-psswd (read-passwd "password: "))
	(cf-remember (if (y-or-n-p "remember? ") '"on" '"")))
    (message
     (if (cf-login cf-uname cf-psswd cf-remember)
	 '"login: ok"
       '"login: fail"))))

(defun cf-logout-i()
  "Logout from Codeforces."
  (interactive)
  (cf-logout)
  (message "logout: ok"))

(defun cf-whoami-i()
  "Print handle."
  (interactive)
  (message (format "logged in as %s" (cf-logged-in-as))))

(setq cf-path-regexp "/\\([0-9]+\\)/?\\([a-zA-Z]\\)/?[^/.]*\\(\.[^.]+\\)$")
(defun cf-submit-current-buffer-by-path-i()
  "Submit contents of the buffer."
  (interactive)
  (unless (cf-logged-in-as)
    (cf-login-i))
  (let (contest problem extension language path)
    (setq path (buffer-file-name))
    (if (string-match cf-path-regexp path)
	(progn
	  (setq contest (match-string 1 path))
	  (setq problem (match-string 2 path))
	  (setq extension (match-string 3 path))
	  (setq language
		(cond
		 ((string= extension ".cpp") cf-pl-g++)
		 ((string= extension ".cc") cf-pl-g++)
		 ((string= extension ".c") cf-pl-gcc)
		 ((string= extension ".pas") cf-pl-fpc)
		 ((string= extension ".php") cf-pl-php)
		 ((string= extension ".java") cf-pl-java-7)
		 ;; and so on..
		 (t cf-default-language)))
	  (message
	   (if (cf-submit contest problem (buffer-substring-no-properties (buffer-end -1) (buffer-end 1)) language)
	       (format "submit: ok [by %s to %s/%s]" (cf-logged-in-as) contest problem)
	     '"submit: fail")))
      (message "submit: file name not recognized"))))

(defun cf-download-tests-i() 
  "Save sample tests to the current directory. 0.in, 0.ans, 1.in ..."
  (interactive)
  (let (tests input output contest problem path i)
    (setq path (buffer-file-name))
    (if (string-match cf-path-regexp path)
	(progn
	  (setq contest (match-string 1 path))
	  (setq problem (match-string 2 path))
	  (message (format "downloading tests for %s/%s..." contest problem))
	  (setq tests (cf-get-tests contest problem))
	  (setq i 0)
	  (dolist (test tests)
	    (setq input (car test))
	    (setq output (cadr test))
	    (with-temp-buffer
	      (insert input)
	      (write-region (point-min) (point-max) (format "%d.in" i))
	      (erase-buffer)
	      (insert output)
	      (write-region (point-min) (point-max) (format "%d.out" i)))
	    (setq i (+ 1 i)))
	  (message (format "downloaded %d tests" i)))
      (message "download: file name not recognized"))))

(global-set-key (kbd "C-c s") 'cf-submit-current-buffer-by-path-i)
(global-set-key (kbd "C-c i") 'cf-login-i)
(global-set-key (kbd "C-c o") 'cf-logout-i)
(global-set-key (kbd "C-c w") 'cf-whoami-i)
(global-set-key (kbd "C-c d") 'cf-download-tests-i)
