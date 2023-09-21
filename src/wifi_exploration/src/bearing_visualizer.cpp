/* ROS message docs
geometry_msgs/Point (float64 x,y,z)
geometry_msgs/PointStamped (Header; Point point)
geometry_msgs/Pose (Point position; Quaternion orientation)
geometry_msgs/Quaternion (float64 x,y,z,w)
geometry_msgs/transform (Vector3 translation; Quaternion rotation)
visualization_msgs/Marker (... ; geometry_msgs/Point[] points;geometry_msgs/Pose pose;
                                header; )
visualization_msgs/MarkerArray (Marker[] markers)
*/
#include <iostream>
#include <vector>
#include <algorithm>
#include "ros/ros.h"
#include "std_msgs/String.h"
#include "nav_msgs/OccupancyGrid.h"
#include "geometry_msgs/Quaternion.h"
#include "geometry_msgs/Pose.h"
#include "geometry_msgs/Point.h"
#include "geometry_msgs/TransformStamped.h"
#include "visualization_msgs/Marker.h"
#include "visualization_msgs/MarkerArray.h"
#include <tf2_ros/transform_listener.h>
#include <tf2/LinearMath/Quaternion.h>
#include <tf2_geometry_msgs/tf2_geometry_msgs.h>

nav_msgs::OccupancyGrid mapData;
visualization_msgs::Marker ap_loc;
// nav_msgs::Odometry wheel_odom;

void mapCallback(const nav_msgs::OccupancyGrid::ConstPtr& map)
{
    mapData = *map;
}
void rvizCallback(const geometry_msgs::PointStamped::ConstPtr& msg)
{
    geometry_msgs::Point p;
    p.x = msg->point.x;
    p.y = msg->point.y;
    p.z = msg->point.z;
    ap_loc.points.push_back(p);
}

int main(int argc, char **argv)
{
    std::string map_topic, base_frame_topic;
    
    ros::init(argc,argv,"bearing_visualizer");
    std::string ns = ros::this_node::getName();
    ros::NodeHandle nh;
    ros::param::param<std::string>(ns+"/map_topic", map_topic, "/robot_1/map");
    ros::param::param<std::string>(ns+"/robot_frame", base_frame_topic, "/robot_1/base_link");
    ros::Subscriber map_sub = nh.subscribe(map_topic, 100, mapCallback);
    ros::Subscriber rviz_sub = nh.subscribe("/clicked_point", 100, rvizCallback);
    // ros::Subscriber odom_sub = nh.subscribe("/odom", 100, odomCallback);
    ros::Publisher rviz_pub_ap = nh.advertise<visualization_msgs::Marker>(ns+"/ap_locations",10);
    ros::Publisher rviz_pub_bearing = nh.advertise<visualization_msgs::MarkerArray>(ns+"/AOA_RSSI",10);
    ros::Rate rate(100);
    while (mapData.header.seq<1 or mapData.data.size()<1)
    {  
        ros::spinOnce();  
        ros::Duration(0.1).sleep();
    }
    ROS_INFO_STREAM("The map topic is "<<map_topic);
    ROS_INFO_STREAM("The robot frame is "<<base_frame_topic);
    ap_loc.header.frame_id = mapData.header.frame_id;
    ap_loc.header.stamp= ros::Time(0);
    ap_loc.ns = "markers";
    ap_loc.id = 0;
    ap_loc.type = ap_loc.POINTS; 
    ap_loc.action = ap_loc.ADD;
    ap_loc.pose.orientation.w = 1.0;
    ap_loc.scale.x = 0.3; 
    ap_loc.scale.y = 0.3;
    ap_loc.color.r = 255.0/255.0; //std_msgs/ColorRGBA color #Color [0.0-1.0]
    ap_loc.color.g = 0.0/255.0;
    ap_loc.color.b = 0.0/255.0;
    ap_loc.color.a = 1;
    ap_loc.lifetime = ros::Duration();

    while(ap_loc.points.size()<3)
    {
        ros::spinOnce();
        rviz_pub_ap.publish(ap_loc);
    }
    ROS_INFO_STREAM("GET ALL 3 AP!");
    tf2_ros::Buffer tfBuffer;
    tf2_ros::TransformListener tfListener(tfBuffer);
    ros::Rate rate_1(10.0);
    ROS_INFO_STREAM("START to GET TRANSFORM");
    while(nh.ok())
    {
        geometry_msgs::TransformStamped getBotOdom;
        std::vector<double> botPos;
        std::vector<double> rssi;
        visualization_msgs::MarkerArray AOASet; 

        try
        {
            getBotOdom=tfBuffer.lookupTransform(map_topic,base_frame_topic,ros::Time(0));
        }
        catch(tf2::TransformException &ex)
        {
            ROS_WARN("%s", ex.what());
            ros::Duration(1.0).sleep();
            continue;
        }
        botPos.push_back(getBotOdom.transform.translation.x);
        botPos.push_back(getBotOdom.transform.translation.y);
        for(unsigned int i = 0;i<ap_loc.points.size();++i)
        {
            visualization_msgs::Marker AOA;
            tf2::Quaternion aoaQuat;

            AOA.type=0;
            AOA.header.frame_id = mapData.header.frame_id;
            AOA.header.stamp= ros::Time(0);
            AOA.action = AOA.ADD;
            AOA.ns = "AOA";
            AOA.id = i;
            AOA.scale.x = 0.35; 
            AOA.scale.y = 0.1;
            AOA.scale.z = 0.1;
            AOA.color.r = 0/255.0; //std_msgs/ColorRGBA color #Color [0.0-1.0]
            AOA.color.g = 255.0/255.0;
            AOA.color.b = 0/255.0;
            AOA.color.a = 1;
            AOA.lifetime = ros::Duration();

            AOA.pose.position.x = botPos[0];
            AOA.pose.position.y = botPos[1];
            AOA.pose.position.z =0;
            double d_y = ap_loc.points[i].y - botPos[1];
            double d_x = ap_loc.points[i].x-botPos[0];
            float yaw_bot_ap = std::atan2(d_y,d_x);//in radians
            aoaQuat.setRPY(0,0,yaw_bot_ap);
            aoaQuat.normalize();
            geometry_msgs::Quaternion aoaQuatMsg = tf2::toMsg(aoaQuat);
            AOA.pose.orientation = aoaQuatMsg;

            AOASet.markers.push_back(AOA);

            rssi.push_back(-10*std::log10(sqrt(pow(d_y,2)+pow(d_x,2))));

        }
        int max_rssi_index = std::max_element(rssi.begin(),rssi.end()) - rssi.begin();
        AOASet.markers[max_rssi_index].scale.x = 0.75;
        rviz_pub_bearing.publish(AOASet);
        ros::spinOnce;
        rate.sleep();
    }
    return 0;
}