(load "../common.lisp")

(defun parse-line (l)
  (if (uiop:string-prefix-p "fold" l)
      (let ((split (uiop:split-string l :separator "=")))
        (list (elt (first split) 11) (parse-integer (second split))))
      (mapcar #'parse-integer (uiop:split-string l :separator ","))))

(defun fold-x (point coord)
  (destructuring-bind (x y) point
    (if (> x coord)
        (list (- coord (- x coord)) y)
        point)))

(defun fold-y (point coord)
  (destructuring-bind (x y) point
    (if (> y coord)
        (list x (- coord (- y coord)))
        point)))

(defun fold (points f)
  (remove-duplicates
   (destructuring-bind (dir coord) f
     (case dir
       (#\x (mapcar (lambda (p) (fold-x p coord)) points))
       (#\y (mapcar (lambda (p) (fold-y p coord)) points))))
   :test #'equal))

(defun fold-p (line)
  (typep (first line) 'character))

(defun split (lines)
  (list (remove-if #'fold-p lines) (remove-if-not #'fold-p lines)))

(defparameter *input* (split (get-input #'parse-line)))

(print (length (fold (first *input*) (first (second *input*)))))
