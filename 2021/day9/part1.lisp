(load "../common.lisp")

(defun value (l x y)
  (elt (elt l x) y))

(defun neighbors (l x y)
  (remove-if-not #'identity
		 (loop for dx in '(1 -1 0 0)
		       for dy in '(0 0 1 -1)
		       collect (when (and (>= (+ x dx) 0)
					  (< (+ x dx) (length l))
					  (>= (+ y dy) 0)
					  (< (+ y dy) (length (first l))))
				 (value l (+ x dx) (+ y dy))))))


(defun is-low-point (l x y)
  (every (lambda (n) (> n (value l x y))) (neighbors l x y)))

(defun risks (l)
  (apply #'+
	 (remove-if-not #'identity (flatten (loop for x from 0 below (length l)
						  collect (loop for y from 0 below (length (first l))
								collect (when (is-low-point l x y)
									  (+ 1 (value l x y)))))))))

(defparameter *input* (get-input (lambda (l) (map 'list #'digit-char-p l))))

(print (risks *input*))
