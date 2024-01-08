#https://medium.com/alterway/deploying-a-steam-dedicated-server-on-kubernetes-645099d063e0
FROM debian:buster

ENV STEAM_DIR="/home/steam/"
ENV SATISFACTORY_DIR="${STEAM_DIR}SatisfactoryDedicatedServer/"
ARG DEBIAN_FRONTEND=noninteractive

RUN useradd -m steam \
      && apt-get update \ 
      && apt-get install wget -y \
      && dpkg --add-architecture i386 \
      && apt-get update \
      && apt-get install lib32gcc1 -y
RUN apt-get install tmux screen -y
USER steam

WORKDIR $STEAM_DIR



ADD --chown=steam:steam https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz "${STEAM_DIR}"
#RUN login anonymous
RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
  && tar xvf steamcmd_linux.tar.gz


# Public Beta
RUN /bin/bash "${STEAM_DIR}steamcmd.sh" +force_install_dir "${STEAM_DIR}SatisfactoryDedicatedServer" \
    +login anonymous \
    +app_update 1690800 \
    -beta public \
    validate +quit
RUN mkdir -p ~/.steam/sdk64/
RUN mkdir -p ~/.steam/sdk32/

RUN cp linux64/steamclient.so /home/steam/.steam/sdk64/
RUN cp linux32/steamclient.so /home/steam/.steam/sdk32/
ENV LD_LIBRARY_PATH=~./steam/sdk32:$LD_LIBRARY_PATH

EXPOSE 15777
EXPOSE 15000
EXPOSE 7777

ENTRYPOINT /bin/bash "${SATISFACTORY_DIR}FactoryServer.sh" -NOSTEAM -multihome=0.0.0.0