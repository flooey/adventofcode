(load "~/.quicklisp/setup.lisp")
(ql:quickload "uiop")

(defun get-file (f fname)
  (let* ((input (uiop:read-file-string fname))
         (split (remove-if (lambda (s) (equal "" s)) (uiop:split-string input :separator "
")))
         )
    (mapcar f split)))

(defun get-input (f)
  (get-file f "input.txt"))

(defun get-sample (f)
  (get-file f "sample.txt"))

(defun split-on-spaces (s)
  (remove-if (lambda (s) (equal "" s)) (uiop:split-string s :separator " ")))

(defun dprint (x)
  (print x)
  x)
