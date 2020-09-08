FROM ubuntu:20.04

ENV APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng \
    APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng \
    APT_CACHER_NG_USER=apt-cacher-ng

COPY entry_point.sh /sbin/entry_point.sh

RUN apt-get update \
# && apt-get upgrade -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
      apt-cacher-ng ca-certificates wget \
 && sed 's/# ForeGround: 0/ForeGround: 1/' -i /etc/apt-cacher-ng/acng.conf \
 && sed 's/# PassThroughPattern:.*this would allow.*/PassThroughPattern: .* #/' -i /etc/apt-cacher-ng/acng.conf \
 && sed 's/# PrecacheFor/PrecacheFor/' -i /etc/apt-cacher-ng/acng.conf \
 && chmod 755 /sbin/entry_point.sh \
 && rm -rf /var/lib/apt/lists/*

COPY resorces/* /usr/lib/apt-cacher-ng/
RUN chmod 644 /usr/lib/apt-cacher-ng/*.html \
&& chmod 644 /usr/lib/apt-cacher-ng/*.css

EXPOSE 3142/tcp

HEALTHCHECK --interval=10s --timeout=2s --retries=3 \
    CMD wget -q -t1 -O /dev/null  http://localhost:3142/acng-report.html || exit 1

ENTRYPOINT ["/sbin/entry_point.sh"]

CMD ["/usr/sbin/apt-cacher-ng"]
