(load "../common.lisp")

(defun parse-line (l)
  (let ((parts (uiop:split-string l)))
    (if (or (= (length parts) 2) (null (ppcre:scan "-?[0-9]+" (third parts))))
        parts
        (list (first parts) (second parts) (parse-integer (third parts))))))

(defun make-state ()
  (let ((result (make-hash-table :test 'equal)))
    (loop for a in '("w" "x" "y" "z")
          do (setf (gethash a result) 0))
    (setf (gethash "in" result) "in1")
    result))

(defun next-input (in)
  (format nil "in~d" (+ 1 (parse-integer (subseq in 2)))))

(defun process-command (command a b state)
  (if (equal command "inp")
      (progn (setf (gethash a state) (gethash "in" state))
             (setf (gethash "in" state) (next-input (gethash "in" state))))
      (let ((arg1 (gethash a state))
            (arg2 (if (typep b 'integer) b (gethash b state))))
        (cond
          ((equal command "add")
           (setf (gethash a state) (list '+ arg1 arg2)))
          ((equal command "mul")
           (setf (gethash a state) (list '* arg1 arg2)))
          ((equal command "div")
           (setf (gethash a state) (list 'div arg1 arg2)))
          ((equal command "mod")
           (setf (gethash a state) (list 'mod arg1 arg2)))
          ((equal command "eql")
           (setf (gethash a state) (list '= arg1 arg2)))))))

(defun run (input state)
  (loop for (command a b) in input
        for i from 1
        do (progn
             (process-command command a b state)
             (loop for var in (list "w" "x" "y" "z")
                   do (setf (gethash var state) (simplify (gethash var state))))))
  state)

(defun remove-mul-26 (x)
  (cond
    ((not (typep x 'list)) x)
    ((and (eql (first x) '*) (eql (third x) 26)) nil)
    ((eql (first x) 'div) x)
    (t (let ((a (remove-mul-26 (second x)))
             (b (remove-mul-26 (third x))))
         (cond
           ((null a) b)
           ((null b) a)
           (t (list (first x) a b)))))))

(defun replace-in (thing to-replace replace-with)
  (if (equal thing to-replace)
      replace-with
      (if (typep thing 'list)
          (list (first thing) (replace-in (second thing) to-replace replace-with) (replace-in (third thing) to-replace replace-with))
          thing)))

(defun multi-replace-in (thing replacements)
  (loop while replacements
        do (progn
             (setq thing (replace-in thing (first replacements) (second replacements)))
             (setq replacements (cddr replacements))))
  thing)

(defun answer (x)
  (deduce x (make-possibles x) "in1" 13))

(defun deduce (x possibles nextin expectedlen)
  (if (equal "in15" nextin)
      nil
      (loop for i in (gethash nextin possibles)
            do (multiple-value-bind (replaced values) (simplify (replace-in x nextin i))
                 ;(when (> expectedlen 11) (format t "~vd~%" (* (- 14 expectedlen) 2) i))
                 (when (member 0 values)
                   (let ((deduced (deduce replaced possibles (next-input nextin) (- expectedlen 1))))
                     (when (= (length deduced) expectedlen)
                         (return-from deduce (cons i deduced)))))))))

(defun make-possibles (x)
  (let ((possibles (make-hash-table :test #'equal)))
    (loop for i from 1 to 14
          do (loop for j from 1 to 9
                   do (let ((in (format nil "in~d" i)))
                        (multiple-value-bind (replaced values) (simplify (replace-in x in j))
                          (declare (ignore replaced))
                          (when (member 0 values)
                            (setf (gethash in possibles) (cons j (gethash in possibles))))))))
    possibles))

(defparameter *max-range* 30)

;; Returns (simplified tree, list of values)
(defun simplify (x)
  (cond
    ((typep x 'string) (values x '(1 2 3 4 5 6 7 8 9)))
    ((typep x 'integer) (values x (list x)))
    (t (multiple-value-bind (arg1 arg1range) (simplify (second x))
         (multiple-value-bind (arg2 arg2range) (simplify (third x))
           (let ((litargs (and (typep arg1 'integer) (typep arg2 'integer)))
                 (arg1range (if (< (length arg1range) *max-range*) arg1range (subseq (sort (copy-list arg1range) #'<) 0 *max-range*)))
                 (arg2range (if (< (length arg2range) *max-range*) arg2range (subseq (sort (copy-list arg2range) #'<) 0 *max-range*))))
             (case (first x)
               (+ (cond
                    (litargs (let ((x (+ arg1 arg2))) (values x (list x))))
                    ((eql arg1 0) (values arg2 arg2range))
                    ((eql arg2 0) (values arg1 arg1range))
                    ;; Check for nested adds, combine
                    ((and (typep arg2 'integer) (typep arg1 'list) (eql (first arg1) '+) (typep (third arg1) 'integer))
                     (simplify (list '+ (second arg1) (+ arg2 (third arg1)))))
                    (t (values (list '+ arg1 arg2)
                               (remove-duplicates (flatten (loop for x1 in arg1range collect (loop for x2 in arg2range collect (+ x1 x2)))))))))
               (* (cond
                    (litargs (let ((x (* arg1 arg2))) (values x (list x))))
                    ((or (eql arg1 0) (eql arg2 0)) (values 0 '(0)))
                    ((eql arg1 1) (values arg2 arg2range))
                    ((eql arg2 1) (values arg1 arg1range))
                    (t (values (list '* arg1 arg2)
                               (remove-duplicates (flatten (loop for x1 in arg1range collect (loop for x2 in arg2range collect (* x1 x2)))))))))
               (div (cond
                      (litargs (let ((x (truncate arg1 arg2))) (values x (list x))))
                      ((eql arg1 0) (values 0 (list 0)))
                      ((eql arg2 1) (values arg1 arg1range))
                      ;; Weird special case because this happens a lot in practice
                      ;((and (eql arg2 26)
                      ;      (eql (first arg1) '+)
                      ;      (typep (second arg1) 'list)
                      ;      (eql (first (second arg1)) '*)
                      ;      (eql (third (second arg1)) 26))
                      ; (simplify (second (second arg1))))
                      (t (values (list 'div arg1 arg2)
                                 (remove-duplicates (flatten (loop for x1 in arg1range collect (loop for x2 in arg2range collect (truncate x1 x2)))))))))
               (mod (cond
                      (litargs (let ((x (mod arg1 arg2))) (values x (list x))))
                      ((eql arg1 0) (values 0 (list 0)))
                      ((eql arg2 1) (values 0 (list 0)))
                      ;; Weird special case because this happens a lot in practice
                      ((and (eql arg2 26)
                            (eql (first arg1) '+)
                            (typep (second arg1) 'list)
                            (eql (first (second arg1)) '*)
                            (eql (third (second arg1)) 26))
                       (simplify (list 'mod (third arg1) 26)))
                      ((and (eql arg2 26)
                            (every (lambda (x) (< x 26)) arg1range))
                       (simplify arg1))
                      ((eql arg2 26) (values (list 'mod (remove-mul-26 arg1) 26)
                                             (remove-duplicates (flatten (loop for x1 in arg1range collect (loop for x2 in arg2range collect (mod x1 x2)))))))
                      (t (values (list 'mod arg1 arg2)
                                 (remove-duplicates (flatten (loop for x1 in arg1range collect (loop for x2 in arg2range collect (mod x1 x2)))))))))
               (= (cond
                    (litargs (if (= arg1 arg2) (values 1 (list 1)) (values 0 (list 0))))
                    (t (if (null (intersection arg1range arg2range))
                           (values 0 '(0))
                           (if (equal arg1 arg2)
                               (values 1 '(1))
                               (values (list '= arg1 arg2) '(0 1))))))))))))))

(defparameter *input* (get-input #'parse-line))

(format t "~{~d~}" (answer (gethash "z" (run *input* (make-state)))))
