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

(defparameter *input* (first (get-input #'parse-line)))


(let ((count 0))
  (loop for y from (first (second *input*)) below 1000
        do (loop for x from 0 upto (second (first *input*))
                 do (when (hits-target *input* x y)
                      (incf count))))
  (print count))
