FROM ubuntu:22.04

# Set username ENV
ARG USER
ARG PASS

# Set ENV to Non-Interactive Install
ENV DEBIAN_FRONTEND noninteractive

# Maker sure Ubuntu is up-to-date
RUN apt-get update -y
RUN apt-get install -y apt-utils software-properties-common apt-transport-https
RUN apt-get upgrade -y

RUN apt-get install -y gnupg \
    wget \
    curl \
    libnotify4 \
    libnss3 \
    libappindicator1 \
    libxss1 \
    libasound2 \
    alsa-utils \
    sudo

RUN curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"| tee /etc/apt/sources.list.d/brave-browser-release.list
RUN apt-get update -y
RUN apt-get install -y brave-browser libpulse0

# Replace 1000 with your user / group id
RUN export user=${USER} uid=1000 gid=1000 && \
    mkdir -p /home/${user} && \
    groupadd -g 1000 ${user} && \
    useradd --uid ${uid} --gid ${gid} -d /home/${user} -ms /bin/bash ${user} && \
    mkdir -p /home/${user}/.config/BraveSoftware/Brave-Browser/ && \
	  # If `First Run` file isn't present, Brave will assume this is the users first run and launch a tutorial.
	  touch /home/${user}/.config/BraveSoftware/Brave-Browser/First\ Run && \
    chown -R ${user}:${user} /home/${user}

# Adding user to audio group so that Brave can play audio
RUN export user=${USER} && usermod -a -G audio ${user}
# Set container user password
RUN export user=${USER} pass=${PASS} && echo "${user}:${pass}" | chpasswd

RUN apt clean

# Set Environment
USER $USER
WORKDIR /home/$USER
ENV HOME /home/$USER
