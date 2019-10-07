FROM alpine:3.10.2

RUN \
	apk update apk upgrade && \
	apk add --no-cache --update gcc make \
		git musl-dev libexecinfo-dev openssl-dev \
		freetype-dev glfw-dev \
	&& \
	mkdir -p /opt/v && cd /opt/v && \
	git clone --depth 1 --quiet https://github.com/vlang/v . \
	&& make && \
	./v -o v compiler \
	&& \
	rm -rf /tmp/* /var/tmp/* /var/cache/apk/* \
	&& \
	/opt/v/v -v