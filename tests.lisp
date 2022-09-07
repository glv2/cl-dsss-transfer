;;; This file is part of cl-dsss-transfer
;;; Copyright 2022 Guillaume LE VAILLANT
;;; Distributed under the GNU GPL v3 or later.
;;; See the file LICENSE for terms of use and distribution.

(defpackage :dsss-transfer-tests
  (:use :cl :fiveam :dsss-transfer)
  (:import-from :uiop
                #:with-temporary-file))

(in-package :dsss-transfer-tests)


(def-suite dsss-transfer-tests :description "Tests for dsss-transfer.")
(in-suite dsss-transfer-tests)

(defparameter *message*
  (asdf:system-relative-pathname "dsss-transfer" "README.org"))

(defun same-files-p (path-1 path-2)
  (with-open-file (file-1 path-1 :element-type '(unsigned-byte 8))
    (with-open-file (file-2 path-2 :element-type '(unsigned-byte 8))
      (let ((buffer-1 (make-array 1024 :element-type '(unsigned-byte 8)))
            (buffer-2 (make-array 1024 :element-type '(unsigned-byte 8))))
        (labels ((same-p ()
                   (let ((i (read-sequence buffer-1 file-1))
                         (j (read-sequence buffer-2 file-2)))
                     (cond
                       ((not (= i j)) nil)
                       ((zerop i) t)
                       ((mismatch buffer-1 buffer-2 :end1 i :end2 i) nil)
                       (t (same-p))))))
          (same-p))))))

(test transmit-and-receive-file
  (with-temporary-file (:pathname samples)
    (with-temporary-file (:pathname decoded)
      (let ((radio (format nil "file=~a" (namestring samples))))
        (transmit-file (namestring *message*)
                       :radio-driver radio
                       :bit-rate 2400)
        (receive-file (namestring decoded)
                      :radio-driver radio
                      :bit-rate 2400)
        (is (same-files-p *message* decoded))))))

(test transmit-and-receive-file-audio
  (with-temporary-file (:pathname samples)
    (with-temporary-file (:pathname decoded)
      (let ((radio (format nil "file=~a" (namestring samples))))
        (transmit-file (namestring *message*) :radio-driver radio
                                              :audio t
                                              :sample-rate 48000
                                              :frequency 1500
                                              :bit-rate 30)
        (receive-file (namestring decoded) :radio-driver radio
                                           :audio t
                                           :sample-rate 48000
                                           :frequency 1500
                                           :bit-rate 30)
        (is (same-files-p *message* decoded))))))

(test transmit-and-receive-stream
  (with-temporary-file (:pathname samples)
    (with-temporary-file (:pathname decoded :stream decoded-stream
                          :direction :output :element-type '(unsigned-byte 8))
      (with-open-file (message-stream *message*
                                      :element-type '(unsigned-byte 8))
        (let ((radio (format nil "file=~a" (namestring samples))))
          (transmit-stream message-stream :radio-driver radio :bit-rate 2400)
          (receive-stream decoded-stream :radio-driver radio :bit-rate 2400)))
      :close-stream
      (is (same-files-p *message* decoded)))))

(test transmit-and-receive-buffer
  (with-temporary-file (:pathname samples)
    (let ((data #(0 1 2 4 9 16 25 36 49 64 81 100 121 144 169 196 225))
          (radio (format nil "file=~a" (namestring samples))))
      (transmit-buffer data :radio-driver radio)
      (let ((decoded (receive-buffer :radio-driver radio)))
        (is (equalp data decoded))))))

(test receive-callback
  (with-temporary-file (:pathname samples)
    (let ((data #(0 1 2 4 9 16 25 36 49 64 81 100 121 144 169 196 225))
          (radio (format nil "file=~a" (namestring samples)))
          (decoded nil))
      (transmit-buffer data :radio-driver radio :bit-rate 600)
      (receive-callback (lambda (data)
                          (setf decoded (concatenate 'vector decoded data)))
                        :radio-driver radio
                        :bit-rate 600)
      (is (equalp data decoded)))))
