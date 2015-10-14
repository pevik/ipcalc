USE_GEOIP?=yes
USE_DYN_GEOIP?=yes

LIBPATH?=/usr/lib64
#LIBPATH=/usr/lib/x86_64-linux-gnu

VERSION=0.1.4
CC?=gcc
CFLAGS?=-O2 -g -Wall
LDFLAGS=-lpopt

ifeq ($(USE_GEOIP),yes)
ifeq ($(USE_DYN_GEOIP),yes)
LDFLAGS+=-ldl
CFLAGS+=-DUSE_GEOIP -DUSE_DYN_GEOIP -DLIBPATH="\"$(LIBPATH)\""
else
LDFLAGS+=-lGeoIP
CFLAGS+=-DUSE_GEOIP
endif
endif

all: ipcalc

ipcalc: ipcalc.c ipcalc-geoip.c
	$(CC) $(CFLAGS) -DVERSION="\"$(VERSION)\"" $^ -o $@ $(LDFLAGS)

clean:
	rm -f ipcalc

check: ipcalc
	./ipcalc -bmnp 12.15.1.5 > out.tmp && cmp out.tmp tests/12.15.1.5
	./ipcalc -bmnp 129.15.31.5 > out.tmp && cmp out.tmp tests/129.15.31.5
	./ipcalc -bmnp 193.92.31.0 > out.tmp && cmp out.tmp tests/193.92.31.0
	./ipcalc -bmnp 192.168.1.5/31 > out.tmp && cmp out.tmp tests/192.168.1.5-31
	./ipcalc -bmnp 10.10.10.5/24 > out.tmp && cmp out.tmp tests/192.168.1.5-24
	./ipcalc -bmnp 10.100.4.1/30 > out.tmp && cmp out.tmp tests/192.168.1.5-30
	./ipcalc -bmnp 10.100.4.1/16 > out.tmp && cmp out.tmp tests/192.168.1.5-16
	./ipcalc -bmnp 10.10.10.10/8 > out.tmp && cmp out.tmp tests/192.168.1.5-8
	./ipcalc --addrspace -bmnp 193.92.150.3/24 > out.tmp && cmp out.tmp tests/193.92.150.3-24
	./ipcalc --addrspace -bmnp fd95:6be5:0ae0:84a5::/64 > out.tmp && cmp out.tmp tests/fd95:6be5:0ae0:84a5::-64
	./ipcalc --addrspace -bmnp fd0b:a336:4e7d::/48 > out.tmp && cmp out.tmp tests/fd0b:a336:4e7d::-48
	./ipcalc -i 2a03:2880:20:4f06:face:b00c:0:1|grep -v Coordinates|grep -v Country|sed '/^$$/d' > out.tmp && cmp out.tmp tests/i-2a03:2880:20:4f06:face:b00c:0:1
	./ipcalc -i fd0b:a336:4e7d::/48 > out.tmp && cmp out.tmp tests/i-fd0b:a336:4e7d::-48
	./ipcalc-tests
