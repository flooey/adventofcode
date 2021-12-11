(load "../common.lisp")

(defun neighbors (a x y)
  (remove-if (lambda (p)
               (or (equal p (list x y))
                   (< (first p) 0)
                   (< (second p) 0)
                   (>= (first p) (array-dimension a 0))
                   (>= (second p) (array-dimension a 1))))
             (flatten (loop for dx in '(-1 0 1)
                            collect (loop for dy in '(-1 0 1)
                                          collect (list (+ x dx) (+ y dy)))))))
             
(defun list-to-2d-array (l)
  (make-array (list (length l) (length (first l)))
              :initial-contents l))

(defun flash (a x y)
  (setf (aref a x y) (+ 1 (aref a x y)))
  (loop for n in (neighbors a x y)
        do (destructuring-bind (nx ny) n
                  (setf (aref a nx ny) (+ 1 (aref a nx ny)))
                  (when (= (aref a nx ny) 10)
                    (flash a nx ny)))))

(defun flash-all (a)
  (let ((toflash (remove-if-not (lambda (p) (= (aref a (first p) (second p)) 10))
                                (flatten (loop for x from 0 below (array-dimension a 0)
                                               collect (loop for y from 0 below (array-dimension a 1)
                                                             collect (list x y)))))))
    (loop for p in toflash
          do (flash a (first p) (second p)))))

(defun clear-flashed (a)
  (every #'identity (loop for i from 0 below (array-total-size a)
                          collect (when (> (row-major-aref a i) 9)
                                    (setf (row-major-aref a i) 0)))))

(defun inc-all (a)
  (dotimes (i (array-total-size a))
    (setf (row-major-aref a i) (+ 1 (row-major-aref a i)))))

(defun run-loop (a)
  (inc-all a)
  (flash-all a)
  (clear-flashed a))

(defparameter *input* (list-to-2d-array (get-input (lambda (l) (mapcar #'digit-char-p (coerce l 'list))))))

(print (+ 1 (loop for i from 0 do (when (run-loop *input*) (return i)))))
