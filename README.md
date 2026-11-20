## aterm - for IRIX

Original aterm 1.0.1 source can be found at:
ftp://ftp.afterstep.org/apps/aterm/aterm-1.0.1.tar.bz2


# Modifications

- applied stropts patch
- applied dpy patch
- changed configure script (gcc only):

    LDFLAGS="$LDFLAGS -rdynamic"
    to 
    LDFLAGS="$LDFLAGS -Wl,--export-dynamic"

- rxvt.h: change DEFAULT_SHELL to /bin/tcsh
 if you want to override the shell start with: setenv SHELL /bin/bash && aterm

- command.c: changed DEFAULT_SHELL to query passwd file for users shell.

- k14: no changes required


# Compile

use mipspro cc compiler

$ ./configure
$ make
