(load "../common.lisp")

(defun parse-line (l)
  (if (search "->" l)
      (list (subseq l 0 2) (subseq l 6))
      l))

(defun convert-transforms (ts)
  (let ((result (make-hash-table :test 'equal)))
    (loop for tr in ts
          do (setf (gethash (first tr) result) (list (elt (second tr) 0) (elt (first tr) 1))))
    result))

(defun transform-state (state trs)
  (coerce
   (cons
    (elt state 0)
    (flatten (loop for i from 0 below (- (length state) 1)
                   collect (gethash (subseq state i (+ i 2)) trs))))
   'string))

(defun freqs (s)
  (let ((result (make-hash-table)))
    (loop for c across s
          do (incf (gethash c result 0)))
    result))

(defun calc (s)
  (let* ((f (freqs s))
         (vals (loop for k being each hash-key of f collect (gethash k f))))
    (- (apply #'max vals) (apply #'min vals))))

(defparameter *input* (get-input #'parse-line))
(defparameter *state* (first *input*))
(defparameter *transforms* (convert-transforms (rest *input*)))

(dotimes (i 10)
  (setq *state* (transform-state *state* *transforms*)))

(print (calc *state*))
