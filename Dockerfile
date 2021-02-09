FROM debian:buster-slim
MAINTAINER himself@derjohn.de
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Install Packages (basic tools, cups, basic drivers, HP drivers)
RUN apt-get update \
&& apt-get install -y \
  vim \
  sudo \
  whois \
  cups \
  cups-client \
  cups-bsd \
  cups-filters \
  foomatic-db-compressed-ppds \
  printer-driver-cups-pdf \
  pdfgrep \
  python3 \
  python3-pip \
  msmtp \
  swaks \
  curl \
  locales \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# Stapler to create PDF Stamps/Watermarks
RUN pip3 install stapler

ADD ./bin/* /usr/local/bin/

# Add user and disable sudo password checking
RUN useradd \
  --groups=sudo,lp,lpadmin \
  --create-home \
  --home-dir=/home/print \
  --shell=/bin/bash \
  --password=$(mkpasswd print) \
  print \
&& sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers

# Configure the service's to be reachable
RUN /usr/sbin/cupsd \
  && while [ ! -f /var/run/cups/cupsd.pid ]; do sleep 1; done \
  && cupsctl --remote-admin --remote-any --share-printers \
  && kill $(cat /var/run/cups/cupsd.pid)

# Patch the default configuration file to only enable encryption if requested
RUN sed -e '0,/^</s//DefaultEncryption IfRequested\n&/' -i /etc/cups/cupsd.conf

RUN rm -f /etc/cups/printers.conf.0 /etc/cups/printers.conf
ADD conf/etc/cups/printers.conf /etc/cups/printers.conf
ADD conf/etc/cups/subscriptions.conf /etc/cups/subscriptions.conf
ADD conf/etc/cups/ppd/pdf_e-mail.ppd /etc/cups/ppd/pdf_e-mail.ppd

RUN chgrp lp /etc/cups/printers.conf

RUN sed -i -r 's|^Browsing On$|Browsing Off|' /etc/cups/cupsd.conf
RUN sed -i -r 's|^Port .*$|Port 10631|' /etc/cups/cupsd.conf
RUN sed -i -r 's|^BrowseProtocols.*$|BrowseRemoteProtocols none|' /etc/cups/cups-browsed.conf

# Make cups-pdf generate PDF/A-1b
#RUN sed -ie 's/^#GSCall /GSCall %s -q -dPDFA -dCompatibilityLevel=%s -dNOPAUSE -dBATCH -dSAFER -sDEVICE=pdfwrite -sOutputFile="%s" -dAutoRotatePages=\/PageByPage -dAutoFilterColorImages=false -dColorImageFilter=\/FlateEncode -dPDFSETTINGS=\/prepress -c .setpdfwrite -f %s/' /etc/cups/cups-pdf.conf
#RUN sed -ie 's|^#GSCall |GSCall %s -q -dPDFA -dCompatibilityLevel=%s -dNOPAUSE -dBATCH -dSAFER -sDEVICE=pdfwrite -sOutputFile="%s" -dAutoRotatePages=/PageByPage -dAutoFilterColorImages=false -dColorImageFilter=/FlateEncode -dPDFSETTINGS=/prepress -c .setpdfwrite -f %s|' /etc/cups/cups-pdf.conf

# Make the Postprocesser do it's magic and send E-Mails
RUN sed -i -r 's|^#PostProcessing.*$|PostProcessing /usr/local/bin/postprocessing|' /etc/cups/cups-pdf.conf
RUN sed -i -r 's|^#AnonUser.*$|AnonUser root|' /etc/cups/cups-pdf.conf

RUN mkdir -p /archive

CMD ["/usr/local/bin/dockercmd"]

