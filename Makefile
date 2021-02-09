DKRIMAGE:=derjohn/pdf-e-mail-printer:latest
CNTNAME:=pdf-e-mail-printer
# See: envrc.sample how to override those
export MSMTPOPTSCMD?=echo "--auth=on --user=foobar@example.com --passwordeval=echo\ secret --protocol=smtp --port 587 --tls --tls-starttls=on --tls-trust-file=/etc/ssl/certs/ca-certificates.crt --host=smtp.example.com -f myemail@example.com"
export TARGETADDRESSCMD?=/usr/bin/pdfgrep -Ph '[a-zA-Z.-\\+][a-zA-Z.-\\+]*@[a-zA-Z.-]+\.[a-zA-Z.-]*' $${1} | head -n1 | egrep -o '[a-zA-Z.-\\+][a-zA-Z.-\\+]*@[a-zA-Z.-]+\.[a-zA-Z.-]*' | grep -v internet@net-lab.net
export FILENAMECMD?=echo "pdf-to-e-mail-printer-document"
export SUBJECTCMD?=echo "Document attached as PDF"
export BODYCMD?=echo "PDF Attachment"

.PHONY=help show-env docker-build docker-run docker-exec docker-logs

docker-build: ## Build the container - if you don't want to use the version available on docker hub.
	docker build -t $(DKRIMAGE) .

docker-run: ## Start the container
	docker stop $(CNTNAME) ||:
	docker rm $(CNTNAME) ||:
	docker run --rm -d -p 10631:10631 -v /var/run/dbus:/var/run/dbus \
	-e SWAKSENVVARS="$${SWAKSENVVARS}" \
	-e TARGETADDRESSCMD="$${TARGETADDRESSCMD}" \
	-e FILENAMECMD="$${FILENAMECMD}" \
	-e ARCHIVECMD="$${ARCHIVECMD}" \
	-e SUBJECTCMD="$${SUBJECTCMD}" \
	-e BODYCMD="$${BODYCMD}" \
	-v $(pwd)/archive:/archive \
	--name $(CNTNAME) $(DKRIMAGE) 

docker-exec: ## Enters the container. Only needed for debugging.
	docker exec -it $(CNTNAME) bash

docker-logs: ## Shows the logs of the running container.
	docker logs $(CNTNAME) 

docker-logs-follow: ## Shows the logs of the running container.
	docker logs $(CNTNAME) -f

docker-stop: ## Stop the container
	docker stop $(CNTNAME) ||:

show-env: ## Show the currently configured env vars
	@echo "\033[36mCurrently configureted variables:\033[0m"
	@env | grep CMD=

dockerhub:
	docker push $(DKRIMAGE)

help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

