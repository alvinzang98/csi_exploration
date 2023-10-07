
(cl:in-package :asdf)

(defsystem "wifi_exploration-msg"
  :depends-on (:roslisp-msg-protocol :roslisp-utils :geometry_msgs-msg
)
  :components ((:file "_package")
    (:file "PointArray" :depends-on ("_package_PointArray"))
    (:file "_package_PointArray" :depends-on ("_package"))
    (:file "ap_csi" :depends-on ("_package_ap_csi"))
    (:file "_package_ap_csi" :depends-on ("_package"))
  ))