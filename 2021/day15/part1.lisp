(load "../common.lisp")

(defun neighbor-positions (a x y)
  (remove-if-not #'identity
		             (loop for dx in '(1 -1 0 0)
		                   for dy in '(0 0 1 -1)
		                   collect (when (and (>= (+ x dx) 0)
					                                (< (+ x dx) (array-dimension a 0))
					                                (>= (+ y dy) 0)
					                                (< (+ y dy) (array-dimension a 1)))
				                         (list (+ x dx) (+ y dy))))))

(defun improve-scores (costs scores)
  (let ((changed nil))
    (loop for x from (- (array-dimension costs 0) 1) downto 0
          do (loop for y from (- (array-dimension costs 1) 1) downto 0
                   do (loop for n in (neighbor-positions scores x y)
                            do (when (> (aref scores x y) (+ (aref scores (first n) (second n)) (aref costs (first n) (second n))))
                                 (setf (aref scores x y) (+ (aref scores (first n) (second n)) (aref costs (first n) (second n))))
                                 (setq changed t)))))
    changed))

(defparameter *costs* (list-to-2d-array (get-input (lambda (l) (mapcar #'digit-char-p (coerce l 'list))))))
(defparameter *scores* (make-array (array-dimensions *costs*) :initial-element 100000))
(setf (aref *scores* (- (array-dimension *scores* 0) 1) (- (array-dimension *scores* 1) 1)) 0)

(loop until (not (improve-scores *costs* *scores*)))

(print (aref *scores* 0 0))
