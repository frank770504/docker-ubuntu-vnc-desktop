FROM osrf/ros:kinetic-desktop
MAINTAINER Doro Wu <fcwu.tw@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's#http://archive.ubuntu.com/#http://tw.archive.ubuntu.com/#' /etc/apt/sources.list

# built-in packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common curl \
    && add-apt-repository ppa:fcwu-tw/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        supervisor \
        openssh-server pwgen sudo vim \
        net-tools \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        nginx \
        python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri \
        gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine \
        dbus-x11 x11-utils

# install ros packages
RUN apt-get update && apt-get install -y \
    ros-kinetic-desktop-full=1.3.0-0*
RUN apt-get install \ 
       ros-kinetic-serial -y \
       ros-kinetic-bfl -y \
       ros-kinetic-urg-c -y \
       ros-kinetic-laser-proc -y \
       ros-kinetic-move-base-msgs -y \
       ros-kinetic-ecl -y \
       libsdl-image1.2-dev -y \
       ros-kinetic-ros-control ros-kinetic-ros-controllers \
       ros-kinetic-gazebo-ros-control ros-kinetic-laser-proc \
       ros-kinetic-hector-gazebo-plugins -y \
       ros-kinetic-navigation-layers -y \
       ros-kinetic-robot-pose-publisher -y \
       ros-kinetic-tf2-web-republisher -y \
       ros-kinetic-rosapi -y \
       ros-kinetic-rosauth -y \
       ros-kinetic-rosbridge-library -y
RUN apt-get update --fix-missing && apt-get install ros-kinetic-hector-models -y
RUN ln -s /usr/include/gazebo-7/gazebo/ /usr/include/gazebo
RUN ln -s /usr/include/sdformat-4.0/sdf/ /usr/include/sdf
RUN ln -s /usr/include/ignition/math2/ignition/math.hh usr/include/ignition/math.hh
RUN ln -s /usr/include/ignition/math2/ignition/math usr/include/ignition/math

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install nodejs iputils-ping -y

RUN  apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*


# tini for subreap                                   
ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

ADD image /
RUN pip install setuptools wheel && pip install -r /usr/lib/web/requirements.txt

EXPOSE 80
WORKDIR /root
ENV HOME=/home/ubuntu \
    SHELL=/bin/bash

#LABEL com.nvidia.volumes.needed="nvidia_driver"
#ENV PATH /usr/local/nvidia/bin:${PATH}
#ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

RUN bash -c 'echo "source \$ROS_DIR/devel/setup.bash" >> /root/.bashrc'
RUN bash -c 'echo "export QT_DEVICE_PIXEL_RATIO=1" >> /root/.bashrc'
ENV ALIAS_DEF '"cd $ROS_DIR"'
RUN bash -c 'echo "alias ros=${ALIAS_DEF}" >> /root/.bashrc'
RUN bash -c 'echo "touch /root/.Xresources" >> /root/.bashrc'
ADD ./alias.txt /root/alias
RUN bash -c 'echo "source /root/alias" >> /root/.bashrc'

ENTRYPOINT ["/startup.sh"]
