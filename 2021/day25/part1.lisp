(load "../common.lisp")

(defun go-right (s)
  (let ((to-move (remove-if #'null (flatten
                                    (loop for x from 0 below (array-dimension s 0)
                                          collect (loop for y from 0 below (array-dimension s 1)
                                                        collect (when (and
                                                                       (eql (aref s x y) #\>)
                                                                       (eql (aref s x (mod (+ 1 y) (array-dimension s 1))) #\.))
                                                                  (list x y))))))))
    (loop for (x y) in to-move
          do (progn
               (setf (aref s x y) #\.)
               (setf (aref s x (mod (+ 1 y) (array-dimension s 1))) #\>)))
    (not (null to-move))))

(defun go-down (s)
  (let ((to-move (remove-if #'null (flatten
                                    (loop for x from 0 below (array-dimension s 0)
                                          collect (loop for y from 0 below (array-dimension s 1)
                                                       collect (when (and
                                                                      (eql (aref s x y) #\v)
                                                                      (eql (aref s (mod (+ 1 x) (array-dimension s 0)) y) #\.))
                                                                 (list x y))))))))
    (loop for (x y) in to-move
          do (progn
               (setf (aref s x y) #\.)
               (setf (aref s (mod (+ 1 x) (array-dimension s 0)) y) #\v)))
    (not (null to-move))))

(defun run (s)
  (loop for i from 1 do
    (let ((right-moved (go-right s))
          (down-moved (go-down s)))
      (when (not (or right-moved down-moved))
        (return-from run i)))))

(defparameter *input* (list-to-2d-array (get-input (lambda (l) (coerce l 'list)))))

(print (run *input*))
