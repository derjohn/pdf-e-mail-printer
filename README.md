# E-Mail to PDF Printer, based on Cups / IPP

## Origin
The original source of this file resides on [github.com/derjohn](https://github.com/derjohn/pdf-e-mail-printer)

## Usage
Everything is a Makefile. Use ```make <TAB><TAB>``` or ```make help```

Basically ```make docker-run``` should work, if you have docker installed.

The container name is by default pdf-e-mail-printer, the image is derjohn/pdf-e-mail-printer. This is also available on [dockerhub](https://hub.docker.com/repository/docker/derjohn/pdf-e-mail-printer)

### make help
```
Usage: make <target>
  docker-build  Build the container - if you don't want to use the version available on docker hub.
  docker-run  Start the container
  docker-exec  Enters the container. Only needed for debugging.
  docker-logs  Shows the logs of the running container.
  show-env    Show the currently configured env vars
```

## Configuration of the container
The configuration is done via env vars. Look into the file envrc.sample.
Your might 
```
source your-envvarfile
```
or create a .envrc file and install direnv
```
apt install direnv
```

## Look into the container's GUI
If you want to check stuff in the containers print queue, you can access it like this.

### URL
http://127.0.0.1:10631

### Credentials
user: print / pass: print

## Configuration of your client
Personally I don't like cups very much. But by creating this system I got some insight :)
I see two ways to print over the container

## 1st way
Set the cups server env var, so you application will use it directly.

```
CUPS_SERVER=127.0.0.1:10631 kate fixtures/test.txt
```
or
```
CUPS_SERVER=127.0.0.1:10631 okular fixtures/sample.pdf
```

## 2nd way
You can configure your cups to have an additional printer, which resides inside the container.

You pobably need something like this in your /etc/cups/cups-browsed.conf
```
IPBasedDeviceURIs IPv4
BrowsePoll 127.0.0.1:10631
```

And maybe 
```
BrowseAllow 127.0.0.1:10631
```

## Nice to know
I personally use that printer with xfreerdp and inject it as a ressource in a virtual cloud-hosted windows system.

```
xfreerdp .... /printer:"pdf_to_email_in_docker,Apple Color LW 12/660 PS"
```

That Apple printer is a postscript one and is included in Windows since aeons. (Windows XP)

On Debian and Ubuntu the package printer-driver-cups-pdf contains the PPDs (Printer descriptions). They reside in /usr/share/ppd/cups-pdf/ , but the good thing is: Your client doesn't need them. The cups server delivers the details about the printer to the client.

## Other CUPS and clout print stuff & inspirations
https://wiki.ubuntuusers.de/CUPS-PDF/

https://github.com/olbat/dockerfiles/tree/master/cupsd

https://github.com/majochoc/cloudprint

## Todo
1. I already installed 'stapler' in the container. This is a utility to make stamp or watermarks over a PDF.
This might be handy, if you want to print e.g. a company logo on the PDF.
2. Create a sample Kubernetes deployment
3. Multiple printers with different configs
4. Save the PDFs on a volume, so that you can copy them from the filesystem

## Contact
If you do something with this system, I would like to hear, how you use it! I will happily accept pull requests.

