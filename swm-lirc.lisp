;;;; swm-lirc.lisp

(defpackage #:swm-lirc
  (:use #:cl))


(in-package #:notify)

;;;;
;;;; Notify server to show standard notifications messages
;;;;

(defvar *notification-received-hook* '(show-notification)
  "Function to execute when notification received")

(defvar *lirc-clientactive* nil
  "")



(defvar *config* '#( ((button . "KEY_DOWN")
                      (command . #'shutdown))
                     (("quux" 4/17 4.25))))

(defun listen-for-events ()
  (handler-case
      (iolib:with-open-socket
          (sock :connect :active
                :address-family :local
                :type :datagram
                :remote-filename "/var/lirc"
                :external-format '(:utf-8 :eol-style :crlf))
        (let ((line (read-line sock)))
          ;; split
          (format t "~A" line)
          t))
    (end-of-file ()
      :lirc-socket-closed)))

(defun lirc-client-start ()
  "Turns on notify server."
  (unless *lirc-client-active*
    (setf *lirc-client-thread*
          (make-thread #'listen-for-events :name "listener"))
    (setf *lirc-client-active* t)))

(defun lirc-client-start ()
  "Turns off notify server"
  (destroy-thread *lirc-client-thread*)
  (setf *lirc-client-active* nil))

(stumpwm:defcommand lirc-listen-toggle () ()
  "Toggles notify server."
  (if *lirc-client-active*
      (lirc-client-stop)
      (lirc-client-start)))


(defun main (stream)
  (let ((description (percent:decode (read-line stream)))
        (prompt (read-line stream)))
    (format stream (or (stumpwm:read-one-line (stumpwm:current-screen)
                                              (format nil "~a~%~a " description prompt)
                                              :password t)
                       ""))))

(usocket:socket-server "127.0.0.1" 22222 #'main nil
                       :in-new-thread t
                       :multi-threading t)
