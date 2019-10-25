FROM alpine:3.10.3

RUN \
	apk update && apk upgrade && \
	apk add --update gcc make \
		git musl-dev openssl-dev \
		freetype-dev glfw-dev \
	&& \
	mkdir -p /opt/v && cd /opt/v && \
	git clone --depth 1 --quiet https://github.com/vlang/v . \
	&& make && \
	rm -rf /tmp/* /var/tmp/* /var/cache/apk/* \
	&& \
	/opt/v/v -v
WORKDIR /opt/v
CMD [ "sh" ]