(defpackage :simple
  (:use :cl :postgres-json))

(in-package :simple)

(defun create ()
  (unless (and pomo:*database* (pomo:connected-p pomo:*database*))
    ;; Change this to your Postmodern connect list...
    (pomo:connect-toplevel "cusoon" "gtod" "" "localhost" :port 5433))
  (unless (backend-exists-p)
    (create-backend))
  (unless (model-exists-p 'cat)
    (create-model 'cat)))

(defun insert-some-cats ()
  (insert 'cat (obj "name" "Joey" "coat" "tabby"))
  (insert 'cat (obj "name" "Maud" "coat" "tortoiseshell"))
  (insert 'cat (obj "name" "Max" "coat" "ginger"))

  (format t "Cat keys: ~A~%" (keys 'cat))

  (erase 'cat (first (keys 'cat)))

  (format t "Cat keys: ~A~%" (keys 'cat))

  (pp-json (fetch 'cat (second (keys 'cat))))

  (format t "~%Total cats: ~A~%" (tally 'cat))

  (let* ((key (first (keys 'cat)))
         (cat (fetch 'cat key)))
    (setf (gethash "age" cat) 7)
    (setf (gethash "likes" cat) '("rain" "sunflowers"))
    (update 'cat key cat))

  (pp-json (fetch-all 'cat)))

(defun drop ()
  (drop-model! 'cat))
