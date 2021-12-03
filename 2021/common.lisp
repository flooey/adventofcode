(load "~/.quicklisp/setup.lisp")
(ql:quickload "uiop")

(defun get-input (f)
  (let* ((input (uiop:read-file-string "input.txt"))
         (split (remove-if (lambda (s) (equal "" s)) (uiop:split-string input :separator "
")))
         )
    (mapcar f split)))

