;; Auto-generated. Do not edit!


(when (boundp 'wifi_exploration::ap_csi)
  (if (not (find-package "WIFI_EXPLORATION"))
    (make-package "WIFI_EXPLORATION"))
  (shadow 'ap_csi (find-package "WIFI_EXPLORATION")))
(unless (find-package "WIFI_EXPLORATION::AP_CSI")
  (make-package "WIFI_EXPLORATION::AP_CSI"))

(in-package "ROS")
;;//! \htmlinclude ap_csi.msg.html
(if (not (find-package "GEOMETRY_MSGS"))
  (ros::roseus-add-msgs "geometry_msgs"))


(defclass wifi_exploration::ap_csi
  :super ros::object
  :slots (_points _rssi ))

(defmethod wifi_exploration::ap_csi
  (:init
   (&key
    ((:points __points) ())
    ((:rssi __rssi) 0.0)
    )
   (send-super :init)
   (setq _points __points)
   (setq _rssi (float __rssi))
   self)
  (:points
   (&rest __points)
   (if (keywordp (car __points))
       (send* _points __points)
     (progn
       (if __points (setq _points (car __points)))
       _points)))
  (:rssi
   (&optional __rssi)
   (if __rssi (setq _rssi __rssi)) _rssi)
  (:serialization-length
   ()
   (+
    ;; geometry_msgs/Point[] _points
    (apply #'+ (send-all _points :serialization-length)) 4
    ;; float64 _rssi
    8
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; geometry_msgs/Point[] _points
     (write-long (length _points) s)
     (dolist (elem _points)
       (send elem :serialize s)
       )
     ;; float64 _rssi
       (sys::poke _rssi (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; geometry_msgs/Point[] _points
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _points (let (r) (dotimes (i n) (push (instance geometry_msgs::Point :init) r)) r))
     (dolist (elem- _points)
     (send elem- :deserialize buf ptr-) (incf ptr- (send elem- :serialization-length))
     ))
   ;; float64 _rssi
     (setq _rssi (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;;
   self)
  )

(setf (get wifi_exploration::ap_csi :md5sum-) "5a2bfbdb74cfb622759ba8388ef3bb0d")
(setf (get wifi_exploration::ap_csi :datatype-) "wifi_exploration/ap_csi")
(setf (get wifi_exploration::ap_csi :definition-)
      "geometry_msgs/Point[] points
float64 rssi
================================================================================
MSG: geometry_msgs/Point
# This contains the position of a point in free space
float64 x
float64 y
float64 z

")



(provide :wifi_exploration/ap_csi "5a2bfbdb74cfb622759ba8388ef3bb0d")


