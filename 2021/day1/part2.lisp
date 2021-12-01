(load "~/.quicklisp/setup.lisp")
(ql:quickload "uiop")

(defun calc (prev input)
  ""
  (if (null input) 0 (+ (if (< prev (car input)) 1 0) (calc (car input) (cdr input)))))

(defun maketriples (l)
  ""
  (if (< (length l) 3) () (cons (+ (first l) (second l) (third l)) (maketriples (cdr l))))
)

(let* ((input (uiop:read-file-string "input.txt"))
       (split (remove-if (lambda (s) (equal "" s)) (uiop:split-string input :separator "
  ")))
       (ints (mapcar #'parse-integer split))
       (inttrips (maketriples ints)))

    (print (calc (car inttrips) (cdr inttrips)))
    (terpri))
