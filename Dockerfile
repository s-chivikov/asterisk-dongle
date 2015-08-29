FROM debian:8

MAINTAINER Sergei S. Chivikov <sergei.chivikov@gmail.com>

# Get all asterisk prerequsites 
RUN apt-get update
RUN apt-get install -y build-essential openssl libxml2-dev libncurses5-dev uuid-dev sqlite3 libsqlite3-dev pkg-config curl libjansson-dev automake unzip wget pciutils  usbutils  usb-modeswitch usb-modeswitch-data minicom nano

# Download and decompress latest asterisk version
RUN curl -s  http://downloads.asterisk.org/pub/telephony/certified-asterisk/certified-asterisk-13.1-current.tar.gz | tar xz

# Asterisk compilation & installation
WORKDIR /certified-asterisk-13.1-cert2
RUN ./configure; make; make install; make samples

# chan-dongle module compilation & installation
RUN mkdir /usr/src/asterisk-chan-dongle
WORKDIR /usr/src/asterisk-chan-dongle
RUN wget  https://github.com/oleg-krv/asterisk-chan-dongle/archive/asterisk13.zip
RUN unzip asterisk13.zip
WORKDIR /usr/src/asterisk-chan-dongle/asterisk-chan-dongle-asterisk13
RUN aclocal; autoconf; automake -a; ./configure; make; make install
RUN cp etc/dongle.conf /etc/asterisk

# Add russian voice to Asterisk
RUN mkdir /usr/src/asterisk-russian-voice-core
RUN mkdir /var/lib/asterisk/sounds/ru
WORKDIR /usr/src/asterisk-russian-voice-core
RUN wget https://github.com/pbxware/asterisk-sounds/archive/master.zip
RUN unzip master.zip
RUN cp -fr asterisk-sounds-master/* /var/lib/asterisk/sounds/ru

RUN mkdir /usr/src/asterisk-russian-voice-additional
WORKDIR /usr/src/asterisk-russian-voice-additional
RUN wget https://github.com/pbxware/asterisk-sounds-additional/archive/master.zip
RUN unzip master.zip
RUN cp -fr asterisk-sounds-additional-master/* /var/lib/asterisk/sounds/ru

VOLUME /etc/asterisk

CMD ["/usr/sbin/asterisk", "-vvvvvvv"]