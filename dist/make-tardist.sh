#!/bin/sh
#
# make-tardist.sh - bundle ../src/aterm into an IRIX 6.5.x inst tardist.
#
# Run on IRIX after "make" (needs gendist from the swpkg / IDO tools):
#
#   $ cd dist && ./make-tardist.sh
#
# Produces dist/aterm-YYYYMMDD.tardist which installs /usr/bin/aterm.
# Install with:  inst -f aterm-YYYYMMDD.tardist   (or swmgr)
#

PATH=/usr/sbin:/usr/bin:/sbin:/bin:$PATH
export PATH

PRODUCT=aterm
VERSION=`date +%Y%m%d`

DISTDIR=`cd \`dirname "$0"\` && pwd`
TOPDIR=`cd "$DISTDIR/.." && pwd`
BINARY=$TOPDIR/src/aterm

WORK=$DISTDIR/tardist.work.$$
STAGE=$WORK/stage
OUT=$WORK/out
SPEC=$WORK/$PRODUCT.spec
IDB=$WORK/$PRODUCT.idb
TARDIST=$DISTDIR/$PRODUCT-$VERSION.tardist

die() {
	echo "make-tardist: $*" >&2
	rm -rf "$WORK"
	exit 1
}

[ -f "$BINARY" ] || die "$BINARY not found - run make first"
[ -x "$BINARY" ] || die "$BINARY is not executable"
GENDIST=`which gendist 2>/dev/null`
[ -x "$GENDIST" ] || die "gendist not found (install the IRIX swpkg / IDO dev tools)"

rm -rf "$WORK"
mkdir -p "$STAGE" "$OUT" || die "cannot create $WORK"

# --- stage files (source paths are relative to -sbase) ---
cp "$BINARY" "$STAGE/aterm" || die "cannot copy $BINARY"
chmod 755 "$STAGE/aterm"

# --- product spec ---
cat > "$SPEC" <<EOF
product $PRODUCT
	id "aterm 1.0.1 - AfterStep X terminal (IRIX build $VERSION)"
	image sw
		id "aterm Software"
		version $VERSION
		order 9999
		subsys eoe default
			id "aterm terminal emulator"
			replaces self
			exp $PRODUCT.sw.eoe
		endsubsys
	endimage
endproduct
EOF

# --- idb: type mode owner group dest-path src-path subsystem [attrs] ---
# norqs: don't requickstart the ELF binary after installation
cat > "$IDB" <<EOF
f 0755 root sys usr/bin/aterm aterm $PRODUCT.sw.eoe norqs
EOF

# --- build the inst image ---
"$GENDIST" -rbase / -sbase "$STAGE" -idb "$IDB" -spec "$SPEC" \
	-dist "$OUT" -all || die "gendist failed"

# --- wrap the image files into a tardist ---
cd "$OUT" || die "cannot cd to $OUT"
FILES=`ls`
[ -n "$FILES" ] || die "gendist produced no files"
rm -f "$TARDIST"
tar cvf "$TARDIST" $FILES || die "tar failed"

cd "$DISTDIR"
rm -rf "$WORK"

echo
echo "Created $TARDIST"
echo "Install with: inst -f $TARDIST"
