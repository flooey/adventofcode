(load "../common.lisp")

(defun parse-line (l)
  (loop for c across l
        collect (if (eql c #\#) 1 0)))

(defun val (a x y)
  (loop for dx in '(-1 -1 -1 0 0 0 1 1 1)
        for dy in '(-1 0 1 -1 0 1 -1 0 1)
        for exp from 8 downto 0
        sum (* (expt 2 exp) (aref a (+ x dx) (+ y dy)))))

(defun expand-array (a amt)
  (let ((result (make-array (mapcar (lambda (x) (+ x (* 2 amt))) (array-dimensions a)))))
    (loop for x from 0 below (array-dimension a 0)
          do (loop for y from 0 below (array-dimension a 1)
                  do (setf (aref result (+ x amt) (+ y amt)) (aref a x y))))
    result))

(defun run (a alg)
  (let ((result (make-array (array-dimensions a) :initial-element (elt alg (if (= (aref a 0 0) 1) 511 0)))))
    (loop for x from 1 below (- (array-dimension a 0) 1)
          do (loop for y from 1 below (- (array-dimension a 1) 1)
                   do (setf (aref result x y) (elt alg (val a x y)))))
    result))

(defun result (a)
  (loop for x from 2 below (- (array-dimension a 0) 2)
        sum (loop for y from 2 below (- (array-dimension a 1) 2)
                  sum (aref a x y))))

(defun run-n (a alg n)
  (let ((result (expand-array a (+ n 5))))
    (dotimes (i n)
      (setf result (run result alg)))
    result))

(defparameter *input* (get-input #'parse-line))
(defparameter *alg* (first *input*))
(defparameter *image* (list-to-2d-array (rest *input*)))

(print (result (run-n *image* *alg* 50)))
