(load "../common.lisp")

(defun make-fish (in)
  (let ((arr (make-array '(9))))
    (loop for x in (mapcar #'parse-integer (uiop:split-string in :separator ","))
          do (setf (aref arr x) (+ (aref arr x) 1)))
    (coerce arr 'list)))

(defun run-fish-once (in)
  (list (second in) (third in) (fourth in) (fifth in) (sixth in) (seventh in) (+ (eighth in) (first in)) (ninth in) (first in)))

(defun run-fish (in times)
  (if (= times 0)
      in
      (run-fish (run-fish-once in) (- times 1))))

(defparameter *input* (get-input))
(defparameter *fish* (make-fish (first *input*)))

(print (apply #'+ (run-fish *fish* 80)))
