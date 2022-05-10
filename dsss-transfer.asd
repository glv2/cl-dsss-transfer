;;; This file is part of cl-dsss-transfer
;;; Copyright 2022 Guillaume LE VAILLANT
;;; Distributed under the GNU GPL v3 or later.
;;; See the file LICENSE for terms of use and distribution.

(defsystem "dsss-transfer"
  :name "dsss-transfer"
  :description "Send and receive data with SDRs using DSSS modulation"
  :version "1.0"
  :author "Guillaume LE VAILLANT"
  :license "GPL-3"
  :depends-on ("cffi" "cl-octet-streams" "float-features")
  :in-order-to ((test-op (test-op "dsss-transfer/tests")))
  :components ((:file "dsss-transfer")))

(defsystem "dsss-transfer/tests"
  :name "dsss-transfer/tests"
  :description "Tests fot dsss-transfer"
  :version "1.0"
  :author "Guillaume LE VAILLANT"
  :license "GPL-3"
  :depends-on ("fiveam" "dsss-transfer" "uiop")
  :in-order-to ((test-op (load-op "dsss-transfer/tests")))
  :perform (test-op (o s)
             (let ((tests (uiop:find-symbol* 'dsss-transfer-tests
                                             :dsss-transfer-tests)))
               (uiop:symbol-call :fiveam 'run! tests)))
  :components ((:file "tests")))
