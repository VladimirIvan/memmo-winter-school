FROM ros:melodic-ros-core

RUN apt-get update && apt-get install -y curl nano -y
RUN sh -c "echo 'deb [arch=amd64] http://robotpkg.openrobots.org/packages/debian/pub bionic robotpkg' >> /etc/apt/sources.list.d/robotpkg.list"
RUN curl http://robotpkg.openrobots.org/packages/debian/robotpkg.key | apt-key add -
RUN apt-get update && apt install -y robotpkg-py27-pinocchio robotpkg-gepetto-viewer-corba openssh-server python-pip python-tk robotpkg-py27-eigenpy apt-utils libeigen3-dev cmake 

RUN sh -c "echo 'export PATH=/opt/openrobots/bin:$PATH' >> /root/.bashrc"
RUN sh -c "echo 'export PKG_CONFIG_PATH=/opt/openrobots/lib/pkgconfig:$PKG_CONFIG_PATH' >> /root/.bashrc"
RUN sh -c "echo 'export LD_LIBRARY_PATH=/opt/openrobots/lib:$LD_LIBRARY_PATH' >> /root/.bashrc"
RUN sh -c "echo 'export PYTHONPATH=/opt/openrobots/lib/python2.7/site-packages:$PYTHONPATH' >> /root/.bashrc"

RUN mkdir /var/run/sshd

RUN echo 'root:root' |chpasswd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^#?X11UseLocalhost\s+.*/X11UseLocalhost no/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN mkdir /root/.ssh

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone --recursive https://github.com/stack-of-tasks/tsid.git --branch pinocchio_v2

RUN git clone --recursive https://github.com/stack-of-tasks/pinocchio.git --branch devel
RUN sed -i '/IF (NOT ${PYTHON_VERSION_STRING} STREQUAL ${PYTHONLIBS_VERSION_STRING})/d' /pinocchio/cmake/python.cmake
RUN sed -i '/  MESSAGE(FATAL_ERROR "Python interpreter and libraries are in different version")/d' /pinocchio/cmake/python.cmake
RUN sed -i '/ENDIF (NOT ${PYTHON_VERSION_STRING} STREQUAL ${PYTHONLIBS_VERSION_STRING})/d' /pinocchio/cmake/python.cmake

RUN . /root/.bashrc && mkdir -p /pinocchio/_build && cd /pinocchio/_build && cmake .. -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/opt/openrobots && cd /pinocchio/_build && make install
RUN pip install jupyter ipykernel matplotlib scipy numpy

RUN . /root/.bashrc && cd /tsid && git pull && mkdir -p /tsid/_build-RELEASE && cd /tsid/_build-RELEASE && cmake .. -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/opt/openrobots && make install
RUN rm -rf /tsid/_build-RELEASE

RUN wget http://robotpkg.openrobots.org/distfiles/talos_data-0.0.20.tar.gz && tar -xvf talos_data-0.0.20.tar.gz && mv talos_data-0.0.20 /opt/openrobots/share/talos_data

RUN sh -c "echo '#!/bin/bash' >> /usr/bin/notebook" && sh -c "echo 'jupyter notebook --no-browser --ip=0.0.0.0 --allow-root' >> /usr/bin/notebook" && chmod +x /usr/bin/notebook
RUN sh -c "echo '#!/bin/bash' >> /cmd.sh" && sh -c "echo 'service omniorb4-nameserver start' >> /cmd.sh" && sh -c "echo 'service ssh start && cd /develop && /bin/bash' >> /cmd.sh" && chmod +x /cmd.sh

EXPOSE 8888
EXPOSE 22

CMD ["/cmd.sh"]
