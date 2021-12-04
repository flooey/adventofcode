(load "../common.lisp")

(defun parse-input (in)
  (defun parse-vals (subl)
    (if (not subl)
        ()
        (concatenate 'list (split-on-spaces (first subl)) (parse-vals (rest subl)))))
  (if (not in)
      ()
      (cons (parse-vals (subseq in 0 5)) (parse-input (subseq in 5)))))

(defun mark-board (num board marks)
  (loop for n from 0 below (length board)
        do (if (equal (elt board n) num)
               (setf (aref marks n) t)))
  marks)

(defun mark-boards (num boards marks)
  (when boards
    (mark-board num (first boards) (first marks))
    (mark-boards num (rest boards) (rest marks))))

(defun check-winner (marks dim op)
  (every #'identity (loop for n from 0 below (length marks) collect (if (= (funcall op n 5) dim) (elt marks n) t))))

(defun winner (marks)
  (some #'identity (loop for n from 0 below 5 collect (or (check-winner marks n #'mod) (check-winner marks n #'floor)))))

(defun score (board marks lastnum)
  (* (parse-integer lastnum) (loop for n from 0 below (length board) sum (if (elt marks n) 0 (parse-integer (elt board n))))))

(defun bingo (nums boards marks)
  (mark-boards (first nums) boards marks)
  (if (some #'identity (loop for n from 0 below (length boards) collect (winner (elt marks n))))
      (loop for n from 0 below (length boards) sum (if (winner (elt marks n)) (score (elt boards n) (elt marks n) (first nums)) 0))
      (bingo (rest nums) boards marks)))


(defparameter input (get-input #'identity))
(defparameter nums (uiop:split-string (first input) :separator ","))
(defparameter boards (parse-input (rest input)))

(print (bingo nums boards (loop for n from 0 below (length boards) collect (make-array (list (length (first boards))) :initial-element nil))))
