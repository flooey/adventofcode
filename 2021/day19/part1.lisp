(load "../common.lisp")

(defun parse-line (l)
  (if (uiop:string-prefix-p "---" l)
      (if (= (length l) 17)
          (parse-integer (subseq l 12 13))
          (parse-integer (subseq l 12 14)))
      (mapcar #'parse-integer (uiop:split-string l :separator ","))))

(defun split-into-scanners (l)
  (if (not l)
      nil
      (let ((thisscanner (loop for x in (rest l)
                           while (not (typep x 'integer))
                               collect x)))
        (cons thisscanner (split-into-scanners (subseq l (+ 1 (length thisscanner))))))))

(defun transform (s trnum)
  (loop for x in s
        collect (progn
                  (when (> (logand trnum 1) 0)
                    (setq x (list (* -1 (first x)) (second x) (third x))))
                  (when (> (logand trnum 2) 0)
                    (setq x (list (first x) (* -1 (second x)) (third x))))
                  (when (> (logand trnum 4) 0)
                    (setq x (list (first x) (second x) (* -1 (third x)))))
                  (case (ash trnum -3)
                    (1 (setq x (list (second x) (third x) (first x))))
                    (2 (setq x (list (third x) (second x) (first x))))
                    (3 (setq x (list (first x) (third x) (second x))))
                    (4 (setq x (list (second x) (first x) (third x))))
                    (5 (setq x (list (third x) (first x) (second x)))))
                  x)))

(defun offset (s val)
  (loop for x in s
        collect (mapcar #'- x val)))

(defun overlaps (s1 s2)
  (loop for x1 in s1
        do (let ((target (offset s1 x1)))
             (let ((result (loop for x in s2
                                 do (when (>= (length (intersection target (offset s2 x) :test #'equal)) 12)
                                      (return (mapcar #'- x1 x))))))
               (when result
                 (return result))))))

(defun overlaps-any (s1 s2)
  (loop for tr from 0 below 48
        do (let* ((transformed (transform s2 tr))
                  (offset (overlaps s1 transformed)))
             (when offset
               (return (offset transformed (mapcar #'- offset)))))))

(defun advance (found notfound)
  (loop for f in found
        do (loop for nf in notfound
                 do (let ((overlap (overlaps-any f nf)))
                      (when overlap
                        (return-from advance (values (cons overlap found) (remove nf notfound))))))))

(defun all-overlaps (in)
  (let ((found (list (first in)))
        (notfound (rest in)))
    (loop while notfound
          do (multiple-value-bind (newf newnf) (advance found notfound)
               (setq found newf)
               (setq notfound newnf)))
    found))

(defparameter *input* (split-into-scanners (get-input #'parse-line)))

(print (length (remove-duplicates (flatten (all-overlaps *input*)) :test #'equal)))
