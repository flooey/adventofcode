(load "../common.lisp")

(defun parse-line (l)
  (destructuring-bind (start end) (uiop:split-string l :separator "|")
    (list (split-on-spaces start) (split-on-spaces end))))

(defparameter *input* (get-input #'parse-line))

(defparameter *numbers* (flatten (mapcar #'second *input*)))

(print (apply #'+
	      (mapcar
	       (lambda (x)
		 (case (length x)
		   (2 1) (3 1) (4 1) (5 0) (6 0) (7 1)))
	       *numbers*)))
