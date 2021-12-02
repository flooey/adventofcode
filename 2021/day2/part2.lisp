(load "~/.quicklisp/setup.lisp")
(ql:quickload "uiop")

(defun get-input (f)
  (let* ((input (uiop:read-file-string "input.txt"))
         (split (remove-if (lambda (s) (equal "" s)) (uiop:split-string input :separator "
")))
         )
    (mapcar f split)))

(defun move (moves horz depth aim)
  (if (not moves)
      (* horz depth)
      (let* ((move (first moves))
             (dir (first move))
             (amt (parse-integer (second move))))
        (move (rest moves)
              (cond ((equal "forward" dir) (+ horz amt)) (t horz))
              (cond ((equal "forward" dir) (+ depth (* aim amt))) (t depth))
              (cond ((equal "up" dir) (- aim amt)) ((equal "down" dir) (+ aim amt)) (t aim))))))

(print (move (get-input (lambda (l) (uiop:split-string l :separator " "))) 0 0 0))

