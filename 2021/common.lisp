(load "~/.quicklisp/setup.lisp")
(ql:quickload "uiop")
(ql:quickload "cl-ppcre")

(defun get-file (f fname)
  (let* ((input (uiop:read-file-string fname))
         (split (remove-if (lambda (s) (equal "" s)) (uiop:split-string input :separator "
")))
         )
    (mapcar f split)))

(defun get-input (&optional (f #'identity))
  (get-file f "input.txt"))

(defun get-sample (&optional (f #'identity))
  (get-file f "sample.txt"))

(defun split-on-spaces (s)
  (remove-if (lambda (s) (equal "" s)) (uiop:split-string s :separator " ")))

(defun flatten (ls)
  (loop for outer in ls
        nconcing (loop for inner in outer collecting inner)))

(defun dprint (x)
  (print x)
  x)

(defun list-to-2d-array (l)
  (make-array (list (length l) (length (first l)))
              :initial-contents l))

(defun dump-hash (state)
  (maphash (lambda (k v) (format t "~a: ~a~%" k v)) state))
