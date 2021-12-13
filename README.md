# SUTURO installation

<!-- TOC -->
- [OpenCV 4.4.0](#opencv-440)
- [Caffe](#caffe)
- [Robosherlock](#robosherlock)
- [install old perception project](#install-old-perception-project)
<!-- /TOC -->

---

## [∞](#mongodb-4.4.5)
Before the installation of mongodb 4.4.5, first check if you already have that version by running  
`mongo --eval 'db.runCommand({ connectionStatus: 1 })'`.  
Look for the 2 mentions of `version`. If both are at least 4.4.5, you can skip the installation of mongodb.

If you have mongodb already installed but **don't have data stored**, a simple `sudo apt-get purge 'mongodb*'` followed by `sudo rm -r /var/lib/mongodb; sudo rm -r /var/log/mongodb` is enough to remove the old version.  
In case you **already use it, backup your data** somewhere else. Also look at https://docs.mongodb.com/manual/tutorial/upgrade-revision.

The following steps are for installing mongodb the first time on a computer or installing it after completly purging the previous version, including the data and log folders.  
In case of an questions, look at https://docs.mongodb.com/v4.4/tutorial/install-mongodb-on-ubuntu/.

There is an [interactive installation script](install-mongodb.sh) however it is not well tested currently.
It worked on at least 2 machines, so there is a good chance it will work for you.
If that doesn't work, look into the script or at the [official installation guide](https://docs.mongodb.com/v4.4/tutorial/install-mongodb-on-ubuntu/.)

# Perception
first, install the following dependencies: (instructions from https://qengineering.eu/install-caffe-on-ubuntu-20.04-with-opencv-4.4.html)

## [∞](#opencv-440) OpenCV 4.4.0
```
sudo apt-get update

# install dependencies
sudo apt install build-essential cmake git unzip pkg-config libjpeg-dev libpng-dev libtiff-dev libavcodec-dev libavformat-dev libswscale-dev libgtk2.0-dev libcanberra-gtk* python3-dev python3-numpy python3-pip libxvidcore-dev libx264-dev libgtk-3-dev libtbb2 libtbb-dev libdc1394-22-dev libv4l-dev v4l-utils libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libavresample-dev libvorbis-dev libxine2-dev libfaac-dev libmp3lame-dev libtheora-dev libopencore-amrnb-dev libopencore-amrwb-dev libopenblas-dev libatlas-base-dev libblas-dev liblapack-dev libeigen3-dev gfortran libhdf5-dev protobuf-compiler libprotobuf-dev libgoogle-glog-dev libgflags-dev
```
❗️ if `libcanberra-gtk*` can't be found, remove it from the list and try again

```
# a symlink to videodev.h
cd /usr/include/linux
sudo ln -s -f ../libv4l1-videodev.h videodev.h
cd ~

# download OpenCV
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.4.0.zip
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.4.0.zip

unzip opencv.zip
unzip opencv_contrib.zip

# administration
mv opencv-4.4.0 opencv
mv opencv_contrib-4.4.0 opencv_contrib

cd opencv
mkdir build
cd build

# build without CUDA, check website for CUDA
cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/usr/local \
-D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
-D BUILD_TIFF=ON \
-D WITH_FFMPEG=ON \
-D WITH_GSTREAMER=ON \
-D WITH_TBB=ON \
-D BUILD_TBB=ON \
-D WITH_EIGEN=ON \
-D WITH_V4L=ON \
-D WITH_LIBV4L=ON \
-D WITH_VTK=OFF \
-D WITH_QT=OFF \
-D WITH_OPENGL=ON \
-D OPENCV_ENABLE_NONFREE=ON \
-D INSTALL_C_EXAMPLES=OFF \
-D INSTALL_PYTHON_EXAMPLES=OFF \
-D BUILD_NEW_PYTHON_SUPPORT=ON \
-D OPENCV_GENERATE_PKGCONFIG=ON \
-D BUILD_TESTS=OFF \
-D BUILD_EXAMPLES=OFF ..

make -j$(nproc)

sudo make install
sudo ldconfig
sudo apt-get update

# check installation in python3
python3
# in python promt >>>
import cv2
cv2.__version__
```

## [∞](#caffe) Caffe
```
#install dependencies
sudo apt install cmake git unzip libprotobuf-dev libleveldb-dev liblmdb-dev libsnappy-dev libhdf5-serial-dev protobuf-compiler libatlas-base-dev libopenblas-dev the python3-dev python3-skimage graphviz

sudo apt install --no-install-recommends libboost-all-dev

sudo pip3 install pydot

# download caffe
cd ~
wget -O caffe.zip https://github.com/Qengineering/caffe/archive/ssd.zip
unzip caffe.zip
mv caffe-ssd caffe

# build caffe
cd ~/caffe

# build without CUDA, check website for CUDA
cp Makefile.config.cp38_x86_64-linux-gnu_example Makefile.config

make clean
make all -j$(nproc)
make test -j$(nproc)
make runtest -j$(nproc)

# runtest should run through ok, with 1266 passed tests

# if directory does not exist yet create with 'mkdir build'
cd build

cmake ..
make all
make install
make runtest
```


go to the file `~/caffe/CMakeLists.txt` (`gedit ~/caffe/CMakeLists.txt`)
in line `85` comment out `add_dependencies(pytest pycaffe)` like this

```
if(BUILD_python)
  add_custom_target(pytest COMMAND python${python_version} -m unittest discover -s caffe/test WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/python )
  #add_dependencies(pytest pycaffe)
endif()
```

⚠️ for python undefined reference error in `make all`: ` 73%] Linking CXX executable upgrade_solver_proto_text`
in line `33` change the python version to `3`

## [∞](#robosherlock) Robosherlock

now install robosherlock

first, make a workspace where robosherlock gets installed
```
mkdir rs_ws
cd rs_ws
mkdir src
# cd into the source folder and clone the following repositories
cd src
```

Clone the following repositories:
`git clone https://github.com/suturo21-22/robosherlock -b noetic --recursive`


`git clone https://github.com/suturo21-22/rs_addons -b noetic --recursive`

`git clone https://github.com/RoboSherlock/rs_resources --recursive`

download a .zip of `https://github.com/ros-perception/image_transport_plugins/tree/b21ed65f8136d9f9ef9c1fb0189b456ec92af305` and unpack it into your `rs_ws/src` folder


install missing dependencies
```
sudo apt install default-jdk libmongoclient-dev software-properties-common python3 python-is-python3 ros-noetic-jsk-data libboost-python-dev

sudo apt-add-repository ppa:swi-prolog/stable
sudo apt update
sudo apt install swi-prolog

```

⚠️ Check if caffe is recognized by robosherlock:

```
sudo apt install cmake-curses-gui

# put in the path to your rs_ws
cd PATH/rs_ws/src/robosherlock/robosherlock/cmake/
ccmake ..
c
e
```
check caffe path from `Caffe_DIR`, change it accordingly
```
c
g
```


go into the folder `rs_ws/src/robosherlock/robosherlock/src/annotation` and edit the file `CMakeLists.txt`

in line `30` and `37`, comment out or delete the if-condition like this:
```
#if(Caffe_FOUND)
  rs_add_library(rs_CaffeAnnotator src/CaffeAnnotator.cpp)
  target_link_libraries(rs_CaffeAnnotator rs_core rs_caffeProxy)
  install(
    TARGETS rs_CaffeAnnotator 
    LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
  )
#endif()
```

⚠️ If you get this error: `/usr/bin/ld: cannot find -lBoost::python`
```
cd /usr/lib/x86_64-linux-gnu
sudo ln -s libboost_python38.so libBoost::python.so
```


```
cd ..
catkin build
source devel/setup.bash
```

ℹ️ Optional: start demo

`rosrun robosherlock runAAE _ae:=demo _vis:=true`

ℹ️ Optional: start demo_addons (with caffe)

⚠️ to download the demo_addons to test caffe itegration, go to the folder `caffe/scripts` and edit the file `download_model_binary.py`

in line `6`, change `import urllib` to `from urllib.request import urlretrieve`

in line `72`, change `urllib.urlretrieve(` to `urlretrieve(`

download demo_addons:
⚠️ if you get the error `[ERROR] [1638716690.455948067]: CaffeAnnotator.cpp(103)[initialize] Couldn't find trained file - Maybe you forgot to put the (downloaded) reference network at /home/lucakrohm/SUTURO/rs_ws/src/rs_resources/caffe/models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel
`:

`cd PATHTORSWORKSPACE/rs_ws/src/rs_resources`

`~/caffe/scripts/download_model_binary.py ./caffe/models/bvlc_reference_caffenet`

start demo_addons:
`rosrun robosherlock runAAE _ae:=demo_addons _vis:=true`


## [∞](#install-old-perception-project) install old perception project

first, make a workspace where the old perception project gets installed
```
mkdir oldsuturo_ws
cd oldsuturo_ws
mkdir src
# cd into the source folder and clone the following repositories
cd src

git clone https://github.com/SUTURO/suturo_perception.git && git clone https://github.com/SUTURO/suturo_resources && git clone https://github.com/code-iai/hsr_description.git -b gripper_tool_frame_noetic

cd ..
catkin build
source devel/setup.bash
```

 ▶️ Start pipelines and action server:

if you read from database, you may have to start mongodb first 
`sudo systemctl start mongod`

`roslaunch suturo_perception hsrb_perception.launch`

# Manipulation

# Knowledge

# Navigation

# Planning
