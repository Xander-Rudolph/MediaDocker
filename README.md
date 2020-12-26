# MediaDocker

* Run this command to build the docker image for PIA VPN:

docker build ./PIAVPN -t pia_vpn:0.0.1

* Then update the values in the Example.env file and rename it to .env (the default value docker-compose looks for)

* Then run this to start the cluster:

docker-compose up -d

* After spooling the VPN you can use to confirm net routing on each container using the following:

curl checkip.amazonaws.com
