(load "../common.lisp")

(defun parse-line (l)
  (let ((split (uiop:split-string l :separator '(#\, #\= #\. #\ ))))
    (list (equal (first split) "on")
          (list (parse-integer (third split))
                (parse-integer (fifth split)))
          (list (parse-integer (seventh split))
                (parse-integer (ninth split)))
          (list (parse-integer (nth 10 split))
                (parse-integer (nth 12 split))))))

(defun is-big (x)
  (destructuring-bind (onoff x y z) x
    (declare (ignore onoff))
    (or (and (< (first x) -50)
             (< (second x) -50))
        (and (> (first x) 50)
             (> (second x) 50))
        (and (< (first y) -50)
             (< (second y) -50))
        (and (> (first y) 50)
             (> (second y) 50))
        (and (< (first z) -50)
             (< (second z) -50))
        (and (> (first z) 50)
             (> (second z) 50)))))

(defun apply-thing (state op)
  (destructuring-bind (val (x1 x2) (y1 y2) (z1 z2)) op
      (loop for x from x1 to x2
            do (loop for y from y1 to y2
                     do (loop for z from z1 to z2
                              do (setf (aref state (+ x 50) (+ y 50) (+ z 50)) val))))))

(defun apply-all (state ops)
  (loop for op in ops
        do (apply-thing state op)))

(defparameter *input* (remove-if #'is-big (get-input #'parse-line)))
(defparameter *state* (make-array '(101 101 101) :initial-element nil))

(apply-all *state* *input*)
(print (loop for i from 0 below (array-total-size *state*) sum (if (row-major-aref *state* i) 1 0)))
