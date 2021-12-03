(load "../common.lisp")

(defparameter input (get-input #'identity))

(defun count-1 (els pos)
  (count-if (lambda (i) (eql i #\1)) (map 'vector (lambda (i) (elt i pos)) els)))

(defun rating-helper (els pos cmp)
  (if (= (length els) 1)
      (parse-integer (first els) :radix 2)
      (let* ((c (count-1 els pos))
             (k (if (funcall cmp c (/ (length els) 2)) #\1 #\0))
             (newels (remove-if-not (lambda (i) (char= (elt i pos) k)) els)))
        (rating-helper newels (+ pos 1) cmp))))

(defun oxygen-rating (els)
  (rating-helper els 0 #'>=))

(defun co2-rating (els)
  (rating-helper els 0 #'<))

(print (* (oxygen-rating input) (co2-rating input)))

