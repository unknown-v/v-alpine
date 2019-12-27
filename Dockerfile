FROM alpine:3.11.2

RUN \
	apk update \ 
	&& apk upgrade \ 
	&& apk add --update gcc \ 
		make git musl-dev musl-dbg \ 
		sqlite-dev freetype-dev \ 
		glfw-dev openssl-dev \
	&& mkdir -p /opt/v && cd /opt/v \
	&& git clone --depth 1 --quiet https://github.com/vlang/v . \
	&& make && \
	rm -rf /tmp/* /var/tmp/* /var/cache/apk/* && /opt/v/v -v 
	
WORKDIR /opt/v

RUN  ./v test-compiler && ./v build-vbinaries && ./v -v
CMD [ "sh" ]