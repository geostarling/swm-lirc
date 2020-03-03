;;;; swm-lirc.asd

(asdf:defsystem #:swm-lirc
  :description "Describe swm-lirc here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (:stumpwm :iolib)
  :components ((:file "package")
               (:file "swm-lirc")))
