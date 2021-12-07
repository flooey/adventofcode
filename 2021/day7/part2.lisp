(load "../common.lisp")

(defun average (l)
  (round (apply #'+ l) (length l)))

(defun triangle-num (x)
  (if (= x 0)
      0
      (+ x (triangle-num (- x 1)))))

(defun fuel-one (x pos)
  (triangle-num (abs (- x pos))))

(defun fuel (l pos)
  (apply '+ (mapcar (lambda (x) (fuel-one x pos)) l)))

(defparameter *input* (first (get-input (lambda (l) (mapcar #'parse-integer (uiop:split-string l :separator ","))))))

(let ((avg (average *input*)))
  (print (min (fuel *input* avg) (fuel *input* (+ avg 1)) (fuel *input* (- avg 1)))))
