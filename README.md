# Memmo winter school tutorial docker image

Builds a docker image containing:
 - Unubtu 18.04 (with ROS melodic core)
 - Pinnochio (bianry)
 - Gepetto viewer corba (binary)
 - Jupyter notebook (numpy, scipy, matplotlib)
 - ssh server
 - Task space inverse dynamics (TSID from source)

 ## To build
  - `./build.sh`

## To run
  - `./run.sh`

Once the container is running, you can:
  - Run `notebook` inside the docker to start jupyter notebook. Copy the URL from the treminal connect to it from the host machine.
  - Connect to the container via ssh (supports graphical windows). From host machine run `./ssh.sh`
  - The `develop` directory gets mounted into the docker. Use this for writing the code from the host machine.