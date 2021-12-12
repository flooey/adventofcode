(load "../common.lisp")

(defun paths-from (paths x)
  (mapcar #'second (remove-if-not (lambda (p) (equal (first p) x)) paths)))

(defun make-paths (l)
  (destructuring-bind (a b) (uiop:split-string l :separator "-")
    (cond
      ((equal a "start") (list (list a b)))
      ((equal b "start") (list (list b a)))
      ((equal a "end") (list (list b a)))
      ((equal b "end") (list (list a b)))
      (t (list (list a b) (list b a))))))

(defun num-paths (paths pos used)
  (let ((newused (if (lower-case-p (elt pos 0))
                     (cons pos used)
                     used)))
    (if (equal pos "end")
        1
        (loop for d in (paths-from paths pos)
              sum (if (find d used :test #'equal)
                      0
                      (num-paths paths d newused))))))
                    

(defparameter *input* (flatten (get-input #'make-paths)))

(print (num-paths *input* "start" ()))

