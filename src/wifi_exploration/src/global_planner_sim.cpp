#include "ros/ros.h"
#include <vector>
#include "std_msgs/String.h"
#include "nav_msgs/OccupancyGrid.h"
#include "visualization_msgs/Marker.h"
#include "geometry_msgs/Point.h"
#include "geometry_msgs/PointStamped.h"
#include "plannerutils.h"
#include <Eigen/Dense>
// #include "wifi_exploration/aoa_rssi.h"


nav_msgs::OccupancyGrid mapData;
visualization_msgs::Marker ap_loc;
class Listener{
    public:
    void mapCallback(const nav_msgs::OccupancyGrid::ConstPtr& map){
        mapData = *map;
    }
    void rvizCallback(const geometry_msgs::PointStamped::ConstPtr& msg){
        geometry_msgs::Point p;
        p.x = msg->point.x;
        p.y = msg->point.y;
        p.z = msg->point.z;
        ap_loc.points.push_back(p);
    }
};

int main(int argc, char **argv){
    std::string map_topic, base_frame_topic;
    int ap_nums = 0;
    ros::init(argc, argv, "ap_pulisher");
    std::string ns = ros::this_node::getName();
    ros::NodeHandle nh;
    ros::param::param<std::string>(ns+"/map_topic", map_topic, "/robot_1/map");
    ros::param::param<std::string>(ns+"/robot_frame", base_frame_topic, "/robot_1/base_link");
    ros::param::param<int>(ns+"ap_nums",ap_nums,3);
    Listener ap_listener;
    ros::Subscriber map_sub = nh.subscribe(map_topic, 100,&Listener::mapCallback,&ap_listener);
    ros::Subscriber rivz_sub = nh.subscribe("/clicked_point",100,&Listener::rvizCallback,&ap_listener);
    ros::Publisher rviz_pub_ap = nh.advertise<visualization_msgs::Marker>(ns+"/ap_locations",10);
    
    ros::Rate rate(100);
    while (ap_loc.points.size()<ap_nums){
        ros::spinOnce();
        rviz_pub_ap.publish(ap_loc);
    }
    
    return 0;
}