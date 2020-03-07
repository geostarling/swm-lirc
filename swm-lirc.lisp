;;;; swm-lirc.lisp


(in-package #:swm-lirc)

(defvar *lirc-client-active* nil
  "")

(defvar *lirc-client-thread* nil
  "")

(defvar *config* '#( ((button . "KEY_POWER")
                      (command . "exec sudo shutdown"))
                     ((button . "KEY_RED")
                      (command . "exec echo $(date) >> /tmp/test"))))

(defun find-commands (code)
  (let* ((matches (coerce (remove-if-not (lambda (item)
                                           (string= code (alexandria:assoc-value item 'button)))
                                         *config*)
                          'list)))
    (mapcan (lambda (item) (alexandria:assoc-value item 'command))
            matches)))

(defun listen-for-events ()
  (handler-case
      (iolib:with-open-socket
          (sock :connect :active
                :address-family :local
                :type :stream
                :remote-filename "/var/run/lirc/lircd")
        (loop
           (let* ((line (read-line sock))
                  (code (nth 2 (stumpwm:split-string line " ")))
                  (commands (find-commands code)))
             (when commands
               (run-commands commands))
             t)))
    (end-of-file ()
      :lirc-socket-closed)))

(defun lirc-client-start ()
  "Turns on notify server."
  (unless *lirc-client-active*
    (setf *lirc-client-thread*
          (bordeaux-threads:make-thread #'listen-for-events :name "listener"))
    (setf *lirc-client-active* t)))

(defun lirc-client-stop ()
  "Turns off notify server"
  ;; TODO: handle SB-THREAD:INTERRUPT-THREAD-ERROR
  (bordeaux-threads:destroy-thread *lirc-client-thread*)
  (setf *lirc-client-active* nil))

(stumpwm:defcommand lirc-listen-toggle () ()
  "Toggles notify server."
  (if *lirc-client-active*
      (lirc-client-stop)
      (lirc-client-start)))
