(load "../common.lisp")

(defun score (target list success)
  (let ((f (first list))
        (r (rest list)))
    (cond
      ((not list) 0)
      ((eql f target) (funcall success r))
      (t (let ((next (lambda (l) (score target l success))))
        (case f
          (#\( (score #\) r next))
          (#\[ (score #\] r next))
          (#\{ (score #\} r next))
          (#\< (score #\> r next))
          (#\) 3)
          (#\] 57)
          (#\} 1197)
          (#\> 25137)))))))

(defun score-line (l)
  (score #\a l nil))

(defparameter *input* (get-input (lambda (l) (coerce l 'list))))

(print (apply #'+ (mapcar #'score-line *input*)))
