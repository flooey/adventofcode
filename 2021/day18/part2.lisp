(load "../common.lisp")

(defun parse-line (l)
  (read-from-string (ppcre:regex-replace-all "[[]" (ppcre:regex-replace-all "[]]" (ppcre:regex-replace-all "," l " ") ")") "(")))

(defun add-first (n amt)
  (typecase n
    (integer (+ n amt))
    (list (list (add-first (first n) amt) (second n)))))

(defun add-second (n amt)
  (typecase n
    (integer (+ n amt))
    (list (list (first n) (add-second (second n) amt)))))

; Returns newn changed addleft addright
(defun explode-helper (n depth)
  (typecase n
    (integer (values n nil 0 0))
    (list (if (= depth 5)
              (values 0 t (first n) (second n))
              (multiple-value-bind (n2 changed addleft addright)
                  (explode-helper (first n) (+ depth 1))
                (if changed
                    (values (list n2 (add-first (second n) addright)) t addleft 0)
                    (multiple-value-bind (n2 changed addleft addright)
                        (explode-helper (second n) (+ depth 1))
                      (if changed
                          (values (list (add-second (first n) addleft) n2) t 0 addright)
                          (values n nil 0 0)))))))))

(defun explode (n)
  (explode-helper n 1))

(defun split (n)
  (typecase n
    (integer (if (> n 9)
                 (values (list (floor n 2) (ceiling n 2)) t)
                 (values n nil)))
    (list (multiple-value-bind (n2 changed)
              (split (first n))
            (if changed
                (values (list n2 (second n)) t)
                (multiple-value-bind (n3 changed)
                    (split (second n))
                  (values (list (first n) n3) changed)))))))

(defun num-reduce (n)
  (let ((c t))
    (loop while c
          do (multiple-value-bind (n2 changed)
                 (explode n)
               (setq n n2)
               (if changed
                   (setq c t)
                   (multiple-value-bind (n2 changed)
                       (split n)
                     (setq n n2)
                     (setq c changed))))))
  n)

(defun add (n1 n2)
  (num-reduce (list n1 n2)))

(defun magnitude (n)
  (typecase n
    (integer n)
    (list (+ (* (magnitude (first n)) 3) (* (magnitude (second n)) 2)))))

(defparameter *input* (get-input #'parse-line))

(print (apply #'max (mapcar #'magnitude
                           (flatten (loop for x from 0 below (length *input*)
                                          collect (loop for y from 0 below (length *input*)
                                                       collect (if (= x y)
                                                                   (add 1 1)
                                                                   (add (elt *input* x) (elt *input* y)))))))))
