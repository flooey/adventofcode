(load "../common.lisp")

(ql:quickload "cl-ppcre")

(defun parse-line (l)
  (ppcre:register-groups-bind (xmin xmax ymin ymax)
      ("x=([0-9-]+)+[.][.]([0-9-]+), y=([0-9-]+)..([0-9-]+)" l)
    (list (list (parse-integer xmin) (parse-integer xmax)) (list (parse-integer ymin) (parse-integer ymax)))))

(defun hits-target (target x y)
  (let ((xpos 0) (ypos 0) (highest 0))
    (destructuring-bind ((xmin xmax) (ymin ymax)) target
      (loop while (and (<= xpos xmax) (>= ypos ymin))
            do (progn
                 (incf xpos x)
                 (incf ypos y)
                 (when (> x 0) (incf x -1))
                 (incf y -1)
                 (when (> ypos highest) (setq highest ypos))
                 (when (and (>= xpos xmin) (<= xpos xmax) (>= ypos ymin) (<= ypos ymax)) (return highest)))))))

(defun trinum (x)
  (if (= x 1) 1
      (+ x (trinum (- x 1)))))

(defun some-x (target)
  (destructuring-bind ((xmin xmax) (ymin ymax)) target
    (loop for x from 1
          do (let ((tn (trinum x)))
               (when (and (>= tn xmin) (<= tn xmax)) (return x))))))

(defparameter *input* (first (get-input #'parse-line)))

                                        ; x just needs to be a triangular number that hits the target
(defparameter *x* (some-x *input*))

(let ((best 0))
  (loop for y from 0 below 1000
        do (let ((res (hits-target *input* *x* y)))
             (when (and res (> res best)) (setq best res))))
  (print best))
