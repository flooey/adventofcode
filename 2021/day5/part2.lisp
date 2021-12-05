(load "../common.lisp")

(defun parse-line (line)
  (let* ((tokens (uiop:split-string line))
         (startend (list (first tokens) (third tokens)))
         (parsed (mapcar (lambda (x) (uiop:split-string x :separator ",")) startend)))
    (mapcar (lambda (l) (mapcar #'parse-integer l)) parsed)))

(defun inc (counts x y)
  (setf (aref counts x y) (+ 1 (aref counts x y))))

(defun mark-line (line counts)
  (cond ((= (first (first line)) (first (second line)))
         (let ((x (first (first line)))
               (ys (list (second (first line)) (second (second line)))))
           (loop for y from (apply #'min ys) to (apply #'max ys) do (inc counts x y))))
        ((= (second (first line)) (second (second line)))
         (let ((xs (list (first (first line)) (first (second line))))
               (y (second (first line))))
           (loop for x from (apply #'min xs) to (apply #'max xs) do (inc counts x y))))
        ((eql (> (first (first line)) (first (second line))) (> (second (first line)) (second (second line))))
         (let* ((xs (list (first (first line)) (first (second line))))
                (ys (list (second (first line)) (second (second line))))
                (minx (apply #'min xs))
                (miny (apply #'min ys))
                (maxx (apply #'max xs)))
           (loop for i from 0 to (- maxx minx) do (inc counts (+ minx i) (+ miny i)))))
        (t
         (let* ((xs (list (first (first line)) (first (second line))))
                (ys (list (second (first line)) (second (second line))))
                (minx (apply #'min xs))
                (maxy (apply #'max ys))
                (maxx (apply #'max xs)))
           (loop for i from 0 to (- maxx minx) do (inc counts (+ minx i) (- maxy i)))))))


(defun mark-lines (lines)
  (let* ((flat (flatten (flatten lines)))
         (m (+ (apply #'max flat) 1))
         (counts (make-array (list m m))))
    (loop for line in lines do (mark-line line counts))
    counts))

(defun count-overlap (counts)
  (let* ((dim (array-dimensions counts))
         (x (first dim)))
    (loop for i below x sum (loop for j below x sum (if (> (aref counts i j) 1) 1 0)))))

(defparameter input (get-input #'parse-line))

(print (count-overlap (mark-lines input)))

