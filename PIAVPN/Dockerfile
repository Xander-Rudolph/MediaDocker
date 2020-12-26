FROM ubuntu:18.04

ENV USERNAME=null
ENV PASSWORD=null
ENV REGION="us_east"
ENV CONNECTIONSTRENGTH="strong"

RUN apt update && \
	apt install -y openvpn curl unzip net-tools iptables

RUN mkdir /pia && \
	curl -sS "https://www.privateinternetaccess.com/openvpn/openvpn-strong.zip" -o /strong.zip && \
	unzip -q /strong.zip -d /pia/strong && \
	rm -f /strong.zip && \
	curl -sS "https://www.privateinternetaccess.com/openvpn/openvpn.zip" -o /normal.zip && \
	unzip -q /normal.zip -d /pia/normal && \
	rm -f /normal.zip && \
	groupadd -r vpn

COPY openvpn.sh /pia/openvpn.sh

WORKDIR /pia

CMD ["bash","/pia/openvpn.sh"]