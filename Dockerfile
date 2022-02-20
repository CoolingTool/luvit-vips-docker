FROM frolvlad/alpine-glibc


WORKDIR /bot
RUN apk add --no-cache git curl vips-dev luarocks5.1
RUN curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh \
	&& mv lit luvi luvit /usr/bin


COPY package.lua ./
RUN luarocks-5.1 --tree /usr/local install lua-vips
RUN lit install | tee install.log \
	; grep -q "stack traceback" install.log ; [ $? -eq 1 ]

COPY *.lua ./
CMD ["luvit", "."]