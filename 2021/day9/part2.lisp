(load "../common.lisp")

(defun value (l x y)
  (elt (elt l x) y))

(defun valuep (l p)
  (value l (first p) (second p)))

(defun neighbor-positions (l x y)
  (remove-if-not #'identity
		 (loop for dx in '(1 -1 0 0)
		       for dy in '(0 0 1 -1)
		       collect (when (and (>= (+ x dx) 0)
					  (< (+ x dx) (length l))
					  (>= (+ y dy) 0)
					  (< (+ y dy) (length (first l))))
				 (list (+ x dx) (+ y dy))))))
  

(defun neighbor-values (l x y)
  (mapcar (lambda (p) (value l (first p) (second p))) (neighbor-positions l x y)))

(defun is-low-point (l x y)
  (every (lambda (n) (> n (value l x y))) (neighbor-values l x y)))

(defun low-points (l)
  (remove-if-not #'identity (flatten (loop for x from 0 below (length l)
					   collect (loop for y from 0 below (length (first l))
							 collect (when (is-low-point l x y)
								   (list x y)))))))
(defun higher-neighbors (l x y)
  (remove-if-not #'identity
		 (loop for p in (neighbor-positions l x y)
		       collect (when (> (valuep l p) (value l x y))
				 p))))

(defun basin (l x y)
  (if (= (value l x y) 9)
      ()
      (remove-duplicates (cons (list x y)
			       (flatten
				(loop for p in (higher-neighbors l x y)
				      collect (basin l (first p) (second p)))))
			 :test #'equal)))

(defun basins (l)
  (mapcar (lambda (p) (basin l (first p) (second p))) (low-points l)))

(defun biggest-basins (l)
  (let* ((lengths (mapcar #'length (basins l)))
	 (lsorted (sort lengths #'>)))
    (* (first lsorted) (second lsorted) (third lsorted))))

(defparameter *input* (get-input (lambda (l) (map 'list #'digit-char-p l))))

(print (biggest-basins *input*))
