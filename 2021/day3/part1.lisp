(load "../common.lisp")

(defparameter input (get-input #'identity))

(defun count-1 (els pos)
  (count-if (lambda (i) (eql i #\1)) (map 'vector (lambda (i) (elt i pos)) els)))

(defun count-all-1 (els)
  (loop for n from 0 below (length (first els))
        collect (count-1 els n)))

(defun make-gamma-value (els)
  (parse-integer (map 'string (lambda (i) (if (> i (/ (length els) 2)) #\1 #\0)) (count-all-1 els)) :radix 2))

(defun make-epsilon-value (els)
  (parse-integer (map 'string (lambda (i) (if (> i (/ (length els) 2)) #\0 #\1)) (count-all-1 els)) :radix 2))

(print (* (make-gamma-value input) (make-epsilon-value input)))
