(load "../common.lisp")

(defun score (target list success)
  (let ((f (first list))
        (r (rest list)))
    (cond
      ((not list) target)
      ((eql f (first target)) (funcall success r))
      (t (let ((next (lambda (l) (score target l success))))
        (case f
          (#\( (score (cons #\) target) r next))
          (#\[ (score (cons #\] target) r next))
          (#\{ (score (cons #\} target) r next))
          (#\< (score (cons #\> target) r next))
          (#\) ())
          (#\] ())
          (#\} ())
          (#\> ())))))))

(defun score-line (l)
  (let ((s 0))
    (loop for x in (score () l nil)
          do (setq s (+ (* s 5) (case x (#\) 1) (#\] 2) (#\} 3) (#\> 4)))))
    s))
    
(defun mid-score (in)
  (let* ((scores (remove-if (lambda (s) (= s 0)) (mapcar #'score-line in)))
         (scores-length (length scores)))
    (elt (sort scores #'<) (floor scores-length 2))))

(defparameter *input* (get-input (lambda (l) (coerce l 'list))))

(print (mid-score *input*))
