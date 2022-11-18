FROM debian:11.5-slim as builder
LABEL maintainer "5pyd3r.tarsylia@gmail.com"

COPY 0001_fix_libc_name_pt_redefinition_error.patch \
	 Kindle_src_5.6.1.1_2634130033.tar.gz /root/

WORKDIR /root

USER root

RUN apt update \
&& apt install -y --no-install-recommends gcc g++ wget make libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev patch \
&& mkdir -pv build && mkdir -pv source \
&& tar xf Kindle_src_5.6.1.1_2634130033.tar.gz -C source \
&& tar xf source/gplrelease/build_linaro-gcc_4.8.3.tar.gz -C build \
&& cd /root/build && make stamp/gcc-extract \
&& cd /root/build/src/gcc-linaro-4.8-2014.04 \
&& patch -s -f -p1 < /root/0001_fix_libc_name_pt_redefinition_error.patch \
&& cd /root/build \
&& make \
&& rm -rf /var/lib/apt/lists/* 

FROM debian:11.5-slim as base

COPY --from=builder /root/build/cross-arm-linux-gnueabi-gcc-linaro-4.8-2014.04.tar.gz /root/

RUN mkdir -pv /opt/toolchain \
&& tar xf /root/cross-arm-linux-gnueabi-gcc-linaro-4.8-2014.04.tar.gz -C /opt/toolchain \
&& rm /root/cross-arm-linux-gnueabi-gcc-linaro-4.8-2014.04.tar.gz \
&& apt update \
&& apt install -y --no-install-recommends libgmp10 libmpfr6 libmpc3 git make automake autoconf ninja-build \
&& rm -rf /var/lib/apt/lists/* 

ENV PATH="/opt/toolchain/cross-gcc-linaro/bin:$PATH"

VOLUME ["/src"]

