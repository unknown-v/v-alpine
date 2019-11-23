FROM alpine:3.10.3

LABEL MAINTAINER="Unknown-V UnknownVuser@protonmail.com (github.com/unknown-v)"
LABEL Name="V-Alpine"
LABEL Version="0.0.1"
#ENV SOURCE_BRANCH=at_v_commit-26fb7e0821fff32a8b6cccea0be1bcae0b56e631
ARG buildtime_chash
ENV chash=${buildtime_chash}

ARG maxdepth=101
ENV Maxdepth=${maxdepth}

RUN echo "date: '`date -u +"%d.%m.%Y-%H:%M:%S_%Z"`' - chash: '$chash' - '${SOURCE_BRANCH:12}'"
RUN sed -i -e 's/v[[:digit:]]\..*\//edge\//g' /etc/apk/repositories \
	&& apk upgrade --update-cache --available > /dev/null 
	# start 
RUN \
	apk update > /dev/null \
	&& apk upgrade > /dev/null \
	&& apk add --update gcc \
		git musl-dev musl-dbg \
		sqlite-dev freetype-dev \
		glfw-dev openssl-dev > /dev/null \
	&& \
	mkdir -p /opt/v && cd /opt/v \
	&& git clone --depth ${Maxdepth} --quiet https://github.com/vlang/v . \
	# done installing deps
	&& [ -z "${chash}" ] && [ "${SOURCE_BRANCH:0:12}" == "at_v_commit-" ] && \
	chash="${SOURCE_BRANCH:12}" || \
	chash="${buildtime_chash:-`git rev-parse --short HEAD`}" \
	&& chash=$(git rev-parse --verify "$chash") && echo "chash: '$chash' !!!!!!!!!!!!!!!!!!!!!!!" \
	&& git reset --hard "${chash}" \
	&& behind=$(git rev-list --right-only --count HEAD...origin/master) \
	&& echo $behind \
	# start vc setup - bootstrap | build v from vc with gcc
	&& git clone --depth $((behind + 5)) --quiet https://github.com/vlang/vc \
	#tests
	&& a=$(git -C vc log -$((behind + 5)) --format="%H %B%n") \
	# && idx=0 ; for i in $(git -C vc log -$((behind + 5)) --format='%H %B%n'); do echo $idx - $i ; idx=$((idx + 1)); done \
	# && for v in $(echo "$a" | sed  's/ update from master -//g' | tr ' ' '-') ; do echo  "${v:0:40} : ${v:41}" ; done \
	&& idx=0 ; for v in $(echo "$a" | tr ' ' '-') ; do [ "${chash:0:7}" == "${v:62:7}" ] && echo "### boom ###" && x=${v:0:40} ; done \
	# && for item in ${d[@]} ; do \
	# [ "${chash:0:7}" == "${item:0:7}" ] && echo "### boom ###" ; \
	# done \
	\
	&& echo "$x" && [ -n "$x" ] && git -C ./vc reset --hard "HEAD~$behind" || git -C ./vc reset --hard "$x" \
	#
	&& cc -std=gnu11 -w -o v vc/v.c -lm  \
	# rebuild v with v
	&& VC_V=`./v version | cut -f 3 -d " "` \
	&& V_V=`git rev-parse --short HEAD` \
	&& if [ "$VC_V" != "$V_V" ]; then \
		echo "Self rebuild ($VC_V => $V_V)" \
		&& ./v -o v v.v; \
	fi \
	&& rm -rf /tmp/* /opt/v/vc /var/tmp/* /var/cache/apk/* && ./v -v

# start test now ! 
# ENV VFLAGS="-show_c_cmd -g"
RUN /opt/v/v symlink && v test v && \
	v test $(find /opt/v -type f -not -wholename '/opt/v/vlib/math/math_test.v' -name '*_test.v')

CMD [ "sh" ]