(load "../common.lisp")

(defun parse-line (l)
  (digit-char-p (elt l (- (length l) 1))))

(defun play (a b)
  (let ((die 0)
        (ascore 0)
        (bscore 0))
    (loop for turn from 0
          do (progn
               (setq a (mod (+ a 6 (* 3 die)) 10))
               (incf ascore (+ a 1))
               (incf die 3)
               (when (>= ascore 1000)
                 (return-from play (* bscore 3 (+ (* turn 2) 1))))
               (setq b (mod (+ b 6 (* 3 die)) 10))
               (incf bscore (+ b 1))
               (incf die 3)
               (when (>= bscore 1000)
                 (return-from play (* ascore 3 (+ (* turn 2) 2))))))))

(defparameter *input* (get-input #'parse-line))

(print (play (- (first *input*) 1) (- (second *input*) 1)))
