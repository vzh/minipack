prefix = ./install
instname = usr/
outputdir = ${prefix}/${instname}

mingw-libs = mingw-libs/libgcc_s_sjlj-1.dll

packages = libtool mingw-libgnurx libffi gmp libiconv libunistring gettext libatomic_ops gc jpeg zlib libpng tiff freetype pixman glib atk cairo pango gdk-pixbuf gtk+ guile geda-gaf gd gtkglext pcb gerbv pkgconfig-wrapper

.PHONY: all install install-libs clean maintainer-clean ${packages}

# Main packages we want to compile
all: geda-gaf pcb gerbv


# Packages without dependencies are:
#   libtool
#   mingw-libgnurx
#   libiconv
#   libatomic_ops
#   jpeg
#   zlib
#   tiff
#   freetype
#   pixman
#   gd

# Time stamps directory
.stamp:
	[ -e $@ ] || mkdir $@

# Build commands for all packages
${packages}: .stamp
	if [ -e ".stamp/$@" ]; then : ; \
	  else \
	  ./mpk source $@ && \
	  ./mpk build $@ && \
	  touch ".stamp/$@"; \
	  fi

# dependencies
gettext: libiconv
# libtool is a soft dependency
gmp: libtool
libffi: libtool
# libtool & libiconv are soft dependencies
libunistring: libtool libiconv
gc: libatomic_ops
libpng: zlib
glib: pkgconfig-wrapper zlib libffi gettext
atk: glib
cairo: libpng pixman freetype
# cairo is a soft dependency
# it must be built before pango
pango: glib cairo
gdk-pixbuf: glib tiff jpeg libpng
gtk+: atk cairo pango gdk-pixbuf
guile: mingw-libgnurx gmp libunistring libffi gc
geda-gaf: guile glib gtk+
#gtkglext: gtk+
# pcb needs tk to be installed on the build system
# NOTE: Now pcb is not dependent on gtkglext since it is compiled with the
#   "--disable-gl" option. For compiling with "--enable-gl" other additional
#   libraries are needed.
pcb: mingw-libgnurx gtk+ gd
gerbv: mingw-libgnurx gtk+


install-libs: ${mingw-libs}
	cp $^ ./result/bin/

install: install-libs
	[ -e ${outputdir} ] && rm -rf ${outputdir}
	cp --preserve=timestamps ./result/ -r -L ${outputdir}

clean:
	for i in ${packages}; do ./mpk clean $$i; done
	rm -f .stamp/*

maintainer-clean: clean
	rm -rf result/*
