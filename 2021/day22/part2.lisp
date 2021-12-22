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

(defun cuboid-intersect (a b)
  (destructuring-bind (((ax1 ax2) (ay1 ay2) (az1 az2)) ((bx1 bx2) (by1 by2) (bz1 bz2))) (list a b)
    (if (or (> ax1 bx2)
            (> bx1 ax2)
            (> ay1 by2)
            (> by1 ay2)
            (> az1 bz2)
            (> bz1 az2))
        nil
        (list (list (max ax1 bx1)
                    (min ax2 bx2))
              (list (max ay1 by1)
                    (min ay2 by2))
              (list (max az1 bz1)
                    (min az2 bz2))))))

(defun to-add (a b)
  (let ((intersection (cuboid-intersect (rest a) (rest b))))
    (if (null intersection)
        nil
        (cond
          ((first a)
           (list (cons nil intersection)))
          (t
           (list (cons t intersection)))))))

(defun apply-thing (state op)
  (concatenate 'list
               state
               (when (first op) (list op))
               (flatten (loop for s in state
                              collect (to-add s op)))))

(defun answer (state)
  (loop for s in state
        sum (* (if (first s) 1 -1) (apply #'* (mapcar (lambda (p) (- (second p) (first p) -1)) (rest s))))))

(defparameter *input* (get-input #'parse-line))

(print (answer (reduce #'apply-thing *input* :initial-value ())))
