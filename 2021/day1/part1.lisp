(load "~/.quicklisp/setup.lisp")
(ql:quickload "uiop")

(defun calc (prev input)
  ""
  (if (null input) 0 (+ (if (< prev (car input)) 1 0) (calc (car input) (cdr input)))))

(let* ((input (uiop:read-file-string "input.txt"))
       (split (remove-if (lambda (s) (equal "" s)) (uiop:split-string input :separator "
  ")))
       (ints (mapcar #'parse-integer split)))
    (print (calc (car ints) (cdr ints)))
    (terpri))
