(load "../common.lisp")

(defun parse-line (l)
  (if (search "->" l)
      (list (subseq l 0 2) (subseq l 6))
      l))

(defun convert-transforms (ts)
  (let ((result (make-hash-table :test 'equal)))
    (loop for tr in ts
          do (setf (gethash (first tr) result)
                   (list (concatenate 'string (subseq (first tr) 0 1) (second tr))
                         (concatenate 'string (second tr) (subseq (first tr) 1)))))
    result))

(defun freq-sum (a b shared)
  (let ((result (make-hash-table)))
    (loop for k being the hash-keys of a
          do (incf (gethash k result 0) (gethash k a)))
    (loop for k being the hash-keys of b
          do (incf (gethash k result 0) (gethash k b)))
    (decf (gethash shared result))
    result))

(defun freq-next (prev trs)
  (let ((result (make-hash-table :test 'equal)))
    (loop for k being each hash-key of prev
          do (let ((next (gethash k trs)))
               (setf (gethash k result)
                     (freq-sum (gethash (first next) prev)
                               (gethash (second next) prev)
                               (elt (first next) 1)))))
    result))

(defun freq-start (trs)
  (let ((result (make-hash-table :test 'equal)))
    (loop for k being each hash-key of trs
          do (let ((thishash (make-hash-table)))
               (incf (gethash (elt k 0) thishash 0))
               (incf (gethash (elt k 1) thishash 0))
               (setf (gethash k result) thishash)))
    result))

(defun freqs-after (level trs state)
  (let ((h (freq-start trs)))
    (dotimes (i level)
      (setq h (freq-next h trs)))
    (let ((result (gethash (subseq state 0 2) h)))
      (loop for i from 1 below (- (length state) 1)
            do (setq result (freq-sum result (gethash (subseq state i (+ i 2)) h) (elt state i))))
      result)))

(defun calc (f)
  (let ((vals (loop for k being each hash-key of f collect (gethash k f))))
    (- (apply #'max vals) (apply #'min vals))))

(defparameter *input* (get-input #'parse-line))
(defparameter *state* (first *input*))
(defparameter *transforms* (convert-transforms (rest *input*)))

(print (calc (freqs-after 40 *transforms* *state*)))
