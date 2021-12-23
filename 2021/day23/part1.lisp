(load "../common.lisp")

(defun parse-input (ls)
  (let ((state (make-hash-table :test 'equal)))
    (setf (gethash '(1 1) state) (elt (third ls) 3))
    (setf (gethash '(1 2) state) (elt (fourth ls) 3))
    (setf (gethash '(2 1) state) (elt (third ls) 5))
    (setf (gethash '(2 2) state) (elt (fourth ls) 5))
    (setf (gethash '(3 1) state) (elt (third ls) 7))
    (setf (gethash '(3 2) state) (elt (fourth ls) 7))
    (setf (gethash '(4 1) state) (elt (third ls) 9))
    (setf (gethash '(4 2) state) (elt (fourth ls) 9))
    state))

(defun spaces-between (start dest)
  (cond
    ((and (typep start 'list) (typep dest 'list))
     (+ (second dest) (second start) (* 2 (abs (- (first start) (first dest))))))
    ((typep start 'list)
     (+ (second start) (abs (- (* 2 (first start)) dest))))
    ((typep dest 'list)
     (+ (second dest) (abs (- (* 2 (first dest)) start))))))

(defun cost-to-move (type start dest)
  (* (case type (#\A 1) (#\B 10) (#\C 100) (#\D 1000))
     (spaces-between start dest)))

(defun apply-move (state start dest)
  (setf (gethash dest state) (gethash start state))
  (remhash start state))

(defun dump (state)
  (maphash (lambda (k v) (format t "~a: ~a~%" k v)) state))

(defun path-blocked (state start end)
  (let ((left (min start end))
        (right (max start end)))
    (loop for x from left to right
          do (when (and (/= x start) (gethash x state)) (return-from path-blocked t)))))

(defun done (state)
  (and
   (eql (gethash '(1 1) state) #\A)
   (eql (gethash '(1 2) state) #\A)
   (eql (gethash '(2 1) state) #\B)
   (eql (gethash '(2 2) state) #\B)
   (eql (gethash '(3 1) state) #\C)
   (eql (gethash '(3 2) state) #\C)
   (eql (gethash '(4 1) state) #\D)
   (eql (gethash '(4 2) state) #\D)))

(defun col-for (type)
  (case type (#\A 1) (#\B 2) (#\C 3) (#\D 4)))

(defun valid-moves-from (state start)
  (let ((col (col-for (gethash start state))))
    (if (typep start 'integer)
        (when (and
               (or
                (null (gethash (list col 2) state))
                (and
                 (eql (gethash (list col 2) state) (gethash start state))
                 (null (gethash (list col 1) state))))
               (not (path-blocked state start (* col 2))))
          (list (list col (if (gethash (list col 2) state) 1 2))))
        (progn
          (when (and (= col (first start)) (= (second start) 2)) (return-from valid-moves-from nil))
          (when (and (= col (first start)) (= (second start) 1) (eql (gethash start state) (gethash (list (first start) 2) state)))
            (return-from valid-moves-from nil))
          (when (and (= (second start) 2)
                     (gethash (list (first start) 1) state))
            (return-from valid-moves-from nil))
          (let ((topspace (* 2 (first start)))
                (moves ()))
            (loop for d from (+ topspace 1) to 10
                  do (if (gethash d state) (return) (setq moves (cons d moves))))
            (loop for d from (- topspace 1) downto 0
                  do (if (gethash d state) (return) (setq moves (cons d moves))))
            (remove-if (lambda (d) (or (= d 2) (= d 4) (= d 6) (= d 8))) moves))))))

(defun valid-moves (state)
  (let ((starts (loop for key being the hash-keys of state collect key)))
    (flatten (loop for s in starts
                   collect (mapcar (lambda (d) (list s d)) (valid-moves-from state s))))))

(defun state-code (state)
  (loop for k being the hash-keys of state
        sum (* (col-for (gethash k state))
               (expt 5
                     (if (typep k 'integer)
                         k
                         (+ 8 (second k) (first k) (first k)))))))

(defun min-cost (state memo depth)
  (let* ((statecode (state-code state))
         (prev (gethash statecode memo)))
    (when prev (return-from min-cost prev))
    (let ((cost (if (done state)
                    0
                    (apply #'min (cons 100000 (loop for (start dest) in (valid-moves state)
                                                    collect (let ((cost (cost-to-move (gethash start state) start dest)))
                                                              (apply-move state start dest)
                                                              (setq cost (+ cost (min-cost state memo (+ depth 1))))
                                                              (apply-move state dest start)
                                                              cost)))))))
      (setf (gethash statecode memo) cost)
      cost)))

(defparameter *input* (parse-input (get-input)))

(print (min-cost *input* (make-hash-table) 1))
