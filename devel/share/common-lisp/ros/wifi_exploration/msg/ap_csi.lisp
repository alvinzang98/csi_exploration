; Auto-generated. Do not edit!


(cl:in-package wifi_exploration-msg)


;//! \htmlinclude ap_csi.msg.html

(cl:defclass <ap_csi> (roslisp-msg-protocol:ros-message)
  ((points
    :reader points
    :initarg :points
    :type (cl:vector geometry_msgs-msg:Point)
   :initform (cl:make-array 0 :element-type 'geometry_msgs-msg:Point :initial-element (cl:make-instance 'geometry_msgs-msg:Point)))
   (rssi
    :reader rssi
    :initarg :rssi
    :type cl:float
    :initform 0.0))
)

(cl:defclass ap_csi (<ap_csi>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <ap_csi>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'ap_csi)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name wifi_exploration-msg:<ap_csi> is deprecated: use wifi_exploration-msg:ap_csi instead.")))

(cl:ensure-generic-function 'points-val :lambda-list '(m))
(cl:defmethod points-val ((m <ap_csi>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader wifi_exploration-msg:points-val is deprecated.  Use wifi_exploration-msg:points instead.")
  (points m))

(cl:ensure-generic-function 'rssi-val :lambda-list '(m))
(cl:defmethod rssi-val ((m <ap_csi>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader wifi_exploration-msg:rssi-val is deprecated.  Use wifi_exploration-msg:rssi instead.")
  (rssi m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <ap_csi>) ostream)
  "Serializes a message object of type '<ap_csi>"
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'points))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_arr_len) ostream))
  (cl:map cl:nil #'(cl:lambda (ele) (roslisp-msg-protocol:serialize ele ostream))
   (cl:slot-value msg 'points))
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'rssi))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <ap_csi>) istream)
  "Deserializes a message object of type '<ap_csi>"
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'points) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'points)))
    (cl:dotimes (i __ros_arr_len)
    (cl:setf (cl:aref vals i) (cl:make-instance 'geometry_msgs-msg:Point))
  (roslisp-msg-protocol:deserialize (cl:aref vals i) istream))))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'rssi) (roslisp-utils:decode-double-float-bits bits)))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<ap_csi>)))
  "Returns string type for a message object of type '<ap_csi>"
  "wifi_exploration/ap_csi")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ap_csi)))
  "Returns string type for a message object of type 'ap_csi"
  "wifi_exploration/ap_csi")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<ap_csi>)))
  "Returns md5sum for a message object of type '<ap_csi>"
  "5a2bfbdb74cfb622759ba8388ef3bb0d")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'ap_csi)))
  "Returns md5sum for a message object of type 'ap_csi"
  "5a2bfbdb74cfb622759ba8388ef3bb0d")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<ap_csi>)))
  "Returns full string definition for message of type '<ap_csi>"
  (cl:format cl:nil "geometry_msgs/Point[] points~%float64 rssi~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'ap_csi)))
  "Returns full string definition for message of type 'ap_csi"
  (cl:format cl:nil "geometry_msgs/Point[] points~%float64 rssi~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <ap_csi>))
  (cl:+ 0
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'points) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ (roslisp-msg-protocol:serialization-length ele))))
     8
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <ap_csi>))
  "Converts a ROS message object to a list"
  (cl:list 'ap_csi
    (cl:cons ':points (points msg))
    (cl:cons ':rssi (rssi msg))
))
