(load "../common.lisp")

(defun parse-line (l)
  (digit-char-p (elt l (- (length l) 1))))

(defun flip (x)
  (list (second x) (first x)))

(defun calc (state apos bpos ascore bscore)
  (let ((results
          (loop for next in '((3 1) (4 3) (5 6) (6 7) (7 6) (8 3) (9 1))
                collect (let* ((newapos (mod (+ apos (first next)) 10))
                               (newascore (+ ascore newapos 1)))
                          (if (>= newascore 21)
                              (list (second next) 0)
                              (let ((dest (aref state bpos newapos bscore newascore)))
                                (mapcar (lambda (x) (* x (second next)))
                                        (flip (if dest dest (calc state bpos newapos bscore newascore))))))))))
    (setf (aref state apos bpos ascore bscore)
          (reduce (lambda (r s) (list (+ (first r) (first s)) (+ (second r) (second s))))
                  results))))

(defparameter *input* (get-input #'parse-line))

;; 0 is current player's position
;; 1 is other player's position
;; 2 is current player's score
;; 3 is other player's score
;; value is (wins, losses) for current player
(defparameter *state* (make-array '(10 10 21 21) :initial-element nil))

(print (apply #'max (calc *state* (- (first *input*) 1) (- (second *input*) 1) 0 0)))
