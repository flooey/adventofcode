(load "../common.lisp")

(defun correct (v dx dy)
  (let ((v2 (+ v dx dy)))
    (if (< v2 10)
        v2
        (- v2 9))))

(defun array-fill (target source dx dy)
  (let ((ddx (* (array-dimension source 0) dx))
        (ddy (* (array-dimension source 1) dy)))
    (loop for x from ddx below (+ ddx (array-dimension source 0))
          do (loop for y from ddy below (+ ddy (array-dimension source 1))
                   do (setf (aref target x y) (correct (aref source (- x ddx) (- y ddy)) dx dy))))))

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

(defparameter *input* (list-to-2d-array (get-input (lambda (l) (mapcar #'digit-char-p (coerce l 'list))))))
(defparameter *costs* (make-array (list (* (array-dimension *input* 0) 5) (* (array-dimension *input* 1) 5))))
(loop for x from 0 below 5
      do (loop for y from 0 below 5
               do (array-fill *costs* *input* x y)))
(defparameter *scores* (make-array (array-dimensions *costs*) :initial-element 100000))
(setf (aref *scores* (- (array-dimension *scores* 0) 1) (- (array-dimension *scores* 1) 1)) 0)

(loop until (not (improve-scores *costs* *scores*)))

(print (aref *scores* 0 0))
