(load "../common.lisp")

(defun hex-to-bin (h)
  (loop for d in '(8 4 2 1)
        collect (if (= (logand h d) 0) 0 1)))

(defun parse-line (l)
  (flatten (map 'list (lambda (x) (hex-to-bin (digit-char-p x 16))) l)))

(defun bin-to-num (l)
  (loop for bit in l
        for pos from (- (length l) 1) downto 0
        sum (* bit (expt 2 pos))))

(defun do-varint (l)
  (let ((result 0)
        (numbits 0))
    (loop while (= (first l) 1)
          do (progn
               (setq result (+ (* 16 result) (bin-to-num (subseq l 1 5))))
               (setq l (subseq l 5))
               (setq numbits (+ numbits 5))))
    (setq result (+ (* 16 result) (bin-to-num (subseq l 1 5))))
    (setq numbits (+ numbits 5))
    (values result (subseq l 5))))

(defun parse-packet (l)
  (let ((version (bin-to-num (subseq l 0 3)))
        (type (bin-to-num (subseq l 3 6))))
    (cond
      ((= type 4)
       (multiple-value-bind (n newl) (do-varint (subseq l 6))
         (values (list version type n) newl)))
      ((= (elt l 6) 1)
       (let ((newl (subseq l 18)))
         (values (list version type (loop for i from 0 below (bin-to-num (subseq l 7 18))
                                          collect (multiple-value-bind (p newnewl) (parse-packet newl)
                                                    (setq newl newnewl)
                                                    p)))
                 newl)))
      (t
       (let ((newl (subseq l 22 (+ 22 (bin-to-num (subseq l 7 22))))))
         (values (list version type (loop while newl
                                          collect (multiple-value-bind (p newnewl) (parse-packet newl)
                                                    (setq newl newnewl)
                                                    p)))
                 (subseq l (+ 22 (bin-to-num (subseq l 7 22))))))))))

(defun sum-versions (p)
  (+ (first p)
     (if (= (second p) 4)
         0
         (loop for p2 in (third p)
               sum (sum-versions p2)))))

(defparameter *input* (first (get-input #'parse-line)))

(print (sum-versions (parse-packet *input*)))
