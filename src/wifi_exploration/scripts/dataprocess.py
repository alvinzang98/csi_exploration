import rosbag
import tqdm
import pickle
import argparse
import numpy as np
import argparse
import scipy.stats as stats
import matplotlib.pyplot as plt
from os import listdir, mkdir
from os.path import join,basename,exists

#load odom and map data and save for post-processing
def bagLoader(bag_path):
    bag = rosbag.Bag(bag_path,'r')
    bag_msg = bag.read_messages()
    bag_data = {}
    bag_data['odom'],bag_data['t_odom']=[],[]
    bag_data['grid'],bag_data['t_grid']=[],[]
    for topic, msg, t in tqdm.tqdm(bag_msg,desc="Extract data from {}:".format(basename(bag_path))):
        #only for one robot
        if "odom" in topic:
            bag_data['odom'].append(np.array([msg.pose.pose.position.x,msg.pose.pose.position.y]))
            bag_data['t_odom'].append(t.to_sec())
        elif "map" in topic:
            grid_count=np.unique(np.array(msg.data),return_counts=1)
            resolution = msg.info.resolution
            bag_data['grid'].append(grid_count)
            bag_data['t_grid'].append(t.to_sec())
    return bag_data, resolution

def distancebyTime(bag_data):
    temp_dist = 0
    prev_odom = 0
    t_odom_list = []
    dist_list = []
    t_copy = np.array(bag_data['t_odom'].copy())
    t_copy -=t_copy[0]
    for i in range(0,len(bag_data["odom"]),500): #interval depends on msg frequency
        cur_odom=bag_data['odom'][i]
        temp_dist+=np.linalg.norm(cur_odom-prev_odom)
        dist_list.append(temp_dist)
        t_odom_list.append(t_copy[i])
        prev_odom = cur_odom
    return np.array(t_odom_list), np.array(dist_list)

def areabyTime(bag_data,resolution):
    area_list = []
    t_copy = np.array(bag_data['t_grid'].copy())
    t_copy -=t_copy[0]
    for i in range(len(bag_data['grid'])):
        uniq, counts = bag_data['grid'][i]
        area=np.sum(counts[np.where(uniq!=-1)[0]])*resolution**2
        area_list.append(area)
    return t_copy, np.array(area_list)

def areabyDist(t_dist, t_area, bag_data):
    #return the idx for dist
    t_dist += bag_data['t_odom'][0]
    t_area += bag_data['t_grid'][0]
    diff = np.abs(t_area[:,np.newaxis]- t_dist)
    # idx = diff.argmin(axis=1)
    return diff

def plotCombined(x,y):
    xs = x.copy()
    ys = np.mean(y, axis=0)
    yerrs = stats.sem(y, axis=0)
    fig,ax =plt.subplots()
    ax.fill_between(xs, ys - yerrs, ys + yerrs, alpha=0.25)
    ax.plot(xs, ys)
    ax.set_xlabel("Time Duration (s)")
    return fig, ax

if __name__=="__main__":
    #modify path before start to process data
    parser = argparse.ArgumentParser()
    parser.add_argument("-d","--dir",help="directory of data and results",required=1)
    parser.add_argument("-o","--prefix",help="bag file prefix",required=1)
    args = parser.parse_args()
    data_dir = args.dir
    prefix = args.prefix
    bag_folder = join(data_dir,"{}_bag".format(prefix)) #bag files only
    res_path = join(data_dir,"{}_res".format(prefix))
    fig_path = join(data_dir,"{}_fig".format(prefix))
    if not exists(bag_folder):
        mkdir(bag_folder)
    if not exists(res_path):
        mkdir(res_path)
    if not exists(fig_path):
        mkdir(fig_path)
    if len(listdir(bag_folder))!=len(listdir(res_path))-1:
        cutoff = np.zeros((len(listdir(bag_folder)),4))
        for idx, file in enumerate(listdir(bag_folder)):
            bag_file=join(bag_folder,file)
            bag_data, resolution = bagLoader(bag_file)
            t_dist, dist = distancebyTime(bag_data)
            t_area, area = areabyTime(bag_data,resolution)
            diff = areabyDist(t_dist,t_area,bag_data)
            dic = {'dist':dist,'t_dist':t_dist,'grid':area,'t_grid':t_area,'diff':diff}
            f = open(join(res_path,file[:-4]+".pkl"),'wb')
            pickle.dump(dic,f)
            cutoff[idx,:] = np.array([dist.shape[0],t_dist.shape[0],area.shape[0],t_area.shape[0]])
        np.save(join(res_path,"data_cutoff"),cutoff)
    else:
        cf = np.load(join(res_path,"data_cutoff.npy")).astype('int')#d,t_d,a,t_a,t_idx
        cf = np.min(cf,axis=0)
        num = len(listdir(res_path))-1
        d = np.zeros((num,cf[0]))
        t_d = np.zeros(cf[1])
        a = np.zeros((num,cf[2]))
        t_a = np.zeros(cf[3])
        t_i = np.zeros((num,cf[3]))
        
        for i in listdir(res_path):
            if ".npy" not in i:
                dic = pickle.load(open(join(res_path,i),'rb'))
                d[num-1] = dic['dist'][:cf[0]]
                t_d = dic['t_dist'][:cf[1]]
                a[num-1] = dic['grid'][:cf[2]]
                t_a = dic['t_grid'][:cf[3]]
                diff = dic['diff']
                diff = diff[:cf[3],:cf[1]]
                t_i[num-1] = np.argmin(diff,axis=1)
                num-=1
        gt_res_path = join(data_dir,'gt_res')
        cf_gt = np.load(join(gt_res_path,"data_cutoff.npy")).astype('int')#d,t_d,a,t_a,t_idx
        cf_gt = np.min(cf_gt,axis=0)
        num_gt = len(listdir(gt_res_path))-1
        d_gt = np.zeros((num_gt,cf_gt[0]))
        t_d_gt = np.zeros(cf_gt[1])
        a_gt = np.zeros((num_gt,cf_gt[2]))
        t_a_gt = np.zeros(cf_gt[3])
        t_i_gt = np.zeros((num_gt,cf_gt[3]))
        
        for i in listdir(gt_res_path):
            if ".npy" not in i:
                dic_gt = pickle.load(open(join(gt_res_path,i),'rb'))
                d_gt[num_gt-1] = dic_gt['dist'][:cf_gt[0]]
                t_d_gt = dic_gt['t_dist'][:cf_gt[1]]
                a_gt[num_gt-1] = dic_gt['grid'][:cf_gt[2]]
                t_a_gt = dic_gt['t_grid'][:cf_gt[3]]
                diff_gt = dic_gt['diff']
                diff_gt = diff_gt[:cf_gt[3],:cf_gt[1]]
                t_i_gt[num_gt-1] = np.argmin(diff_gt,axis=1)
                num_gt-=1

        fig,ax = plotCombined(t_d,d)
        ax.plot(t_d_gt - (t_d_gt[0]-t_d[0]),d_gt[0])
        ax.set_ylabel("Distance (m)")
        ax.set_title("Robot Travel Distance by Time")
        fig.savefig(join(fig_path,"{}_distance.png".format(prefix)))

        # t_a_gt = t_a_gt - t_a[0]
        fig,ax = plotCombined(t_a,a)
        ax.plot(t_a_gt-(t_a_gt[0]-t_a[0]),a_gt[0])
        ax.set_title("Robot Explored Area by Time")
        ax.set_ylabel("Explored Area ($m^2$)")
        fig.savefig(join(fig_path,"{}_area.png".format(prefix)))

        row,_ = np.indices((len(listdir(res_path))-1,cf[3]))
        area_dist = a/d[row,t_i.astype('int')]
        indx = np.max(np.argmax(area_dist,axis=1))
        print(row.shape,t_i.astype('int').shape,d.shape,d[row,t_i.astype('int')].shape,a.shape)
        

        row_gt,_ = np.indices((len(listdir(gt_res_path))-1,cf_gt[3]))
        area_dist_gt = a_gt/d_gt[row_gt,t_i_gt.astype('int')]

        indx_gt = np.max(np.argmax(area_dist_gt,axis=1))

        dd = d[row,t_i.astype('int')]
        # fig, axs = plt.subplots(3,2,figsize=(15,15))
        # axs[0,0].plot(dd[0],a[0])
        # axs[0,0].set_title('1')
        # axs[0,1].plot(dd[1],a[1])
        # axs[0,1].set_title('2')
        # axs[1,0].plot(dd[2],a[2])
        # axs[1,0].set_title('3')
        # axs[1,1].plot(dd[3],a[3])
        # axs[1,1].set_title('4')
        # axs[2,0].plot(d_gt[row_gt,t_i_gt.astype('int')][0], a_gt[0],'r')
        # axs[2,0].set_title('gt')
        # for ax in axs.flat:
        #     ax.set(xlabel='distance', ylabel='area')
        # fig.savefig(join(fig_path,"area_by_dist.png"))
        
        fig, axs = plt.subplots()
        for i in range(a.shape[0]):
            axs.plot(dd[i],a[i])
        axs.plot(d_gt[row_gt,t_i_gt.astype('int')][0], a_gt[0])
        axs.set_xlabel("distance")
        axs.set_ylabel("area")
        axs.legend(['1','2','3','gt'])
        fig.savefig(join(fig_path,"area_by_dist_1.png"))

        # area_dist=area_dist[area_dist<100]
        arr_col = np.unique(np.where(area_dist>100)[1])
        area_dist = np.delete(area_dist,arr_col,1)
        t_a = np.delete(t_a,arr_col)

        fig,ax = plotCombined(t_a,area_dist)

        arr_col = np.unique(np.where(area_dist_gt>100)[1])
        area_dist_gt = np.delete(area_dist_gt,arr_col,1)
        t_a_gt = np.delete(t_a_gt,arr_col)
        ax.plot(t_a_gt-(t_a_gt[0]-t_a[0]),area_dist_gt[0])
        ax.set_title(r"$\frac{Explored\ Area}{Travel\ Distance}$ by Time")
        ax.set_ylabel(r"$\frac{ Area}{ Dist}$")
        fig.savefig(join(fig_path,"{}_AoverD.png".format(prefix)))

        
        # fig,ax = plt.subplots()
        # ax.plot(dist, t_dist)
        # ax.set_title("Robot Travel Distance by Time")
        # ax.set_ylabel("Distance (m)")
        # ax.set_xlabel("Time Duration (s)")

        # fig,ax = plt.subplots()
        # ax.plot(t_area,area)
        # ax.set_title("Robot Explored Area by Time")
        # ax.set_ylabel("Explored Area ($m^2$)")
        # ax.set_xlabel("Time Duration (s)")

        # idx = areabyDist(t_dist, t_area, bag_data)
        # ax.plot(t_area,area/dist[idx])
        # ax.set_title("$\frac{Explored Area}{Travel Distance}$ by Time")
        # ax.set_ylabel("$\frac{ Area}{ Dist}$")
        # ax.set_xlabel("Time Duration (s)")
        # plt.show()
