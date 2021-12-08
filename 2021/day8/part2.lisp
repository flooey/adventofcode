(load "../common.lisp")

(defun parse-line (l)
  (destructuring-bind (start end) (uiop:split-string l :separator "|")
    (list (split-on-spaces start) (split-on-spaces end))))

(defun overlap (x y)
  (length (intersection (coerce x 'list) (coerce y 'list))))

(defun deduce (data)
  (let ((ht (make-hash-table :test 'equal))
	(data (mapcar #'sort-string data))
	(one nil)
	(four nil))
    (loop for i in data
	  do (case (length i)
	       (2 (setf (gethash i ht) 1) (setq one i))
	       (3 (setf (gethash i ht) 7))
	       (4 (setf (gethash i ht) 4) (setq four i))
	       (7 (setf (gethash i ht) 8))))
    (loop for i in data
	  do (case (length i)
	       (5 (cond ((= (overlap i one) 2) (setf (gethash i ht) 3))
			((= (overlap i four) 3) (setf (gethash i ht) 5))
			(t (setf (gethash i ht) 2))))
	       (6 (cond ((/= (overlap i one) 2) (setf (gethash i ht) 6))
			((/= (overlap i four) 4) (setf (gethash i ht) 0))
			(t (setf (gethash i ht) 9))))))
    ht))

(defun sort-string (s)
  (sort (copy-seq s) #'char-lessp))

(defun output (l)
  (destructuring-bind (data vals) l
    (let ((ht (deduce data))
	  (vals (mapcar #'sort-string vals)))
      (+ (* 1000 (gethash (first vals) ht))
	 (* 100 (gethash (second vals) ht))
	 (* 10 (gethash (third vals) ht))
	 (gethash (fourth vals) ht)))))

(defparameter *input* (get-input #'parse-line))

(print (apply #'+ (mapcar #'output *input*)))
