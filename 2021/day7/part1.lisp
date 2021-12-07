(load "../common.lisp")

(defun median (l)
  (let ((sorted (sort (copy-seq l) #'<))
        (a (floor (- (length l) 1) 2))
        (b (ceiling (- (length l) 1) 2)))
    (if (= (elt sorted a) (elt sorted b))
        (elt sorted a)
        (floor (+ (elt sorted a) (elt sorted b)) 2))))

(defun fuel-one (x pos)
  (abs (- x pos)))

(defun fuel (l pos)
  (apply '+ (mapcar (lambda (x) (fuel-one x pos)) l)))

(defparameter *input* (first (get-input (lambda (l) (mapcar #'parse-integer (uiop:split-string l :separator ","))))))

(print (fuel *input* (median *input*)))
