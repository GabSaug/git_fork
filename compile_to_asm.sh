# $1: name of the c file to compile to assembly
# $2 output path


# We need to add some const values, taken directly from the Makefile

prefix=/usr/local
bindir=${prefix}/bin
mandir=${prefix}/share/man
infodir=${prefix}/share/info
gitexecdir=libexec/git-core
mergetoolsdir=${gitexecdir}/mergetools
sharedir=${prefix}/share
gitwebdir=${sharedir}/gitweb
gitwebstaticdir=${gitwebdir}/static
perllibdir=${sharedir}/perl5
localedir=${sharedir}/locale
template_dir=share/git-core/templates
htmldir=${prefix}/share/doc/git-doc
ETC_GITCONFIG=${sysconfdir}/gitconfig
ETC_GITATTRIBUTES=${sysconfdir}/gitattributes
lib=lib

bindir_relative=$(echo "$bindir" | sed "s|^${prefix}/||")
mandir_relative=$(echo "$mandir" | sed "s|^${prefix}/||")
infodir_relative=$(echo "$infodir" | sed "s|^${prefix}/||")
gitexecdir_relative=$(echo "$gitexecdir" | sed "s|^${prefix}/||")
localedir_relative=$(echo "$localedir" | sed "s|^${prefix}/||")
htmldir_relative=$(echo "$htmldir" | sed "s|^${prefix}/||")
perllibdir_relative=$(echo "$perllibdir" | sed "s|^${prefix}/||")

#DESTDIR_SQ=\"${DESTDIR//\'/\'\\\'\'}\"
#NO_GETTEXT_SQ=\"${NO_GETTEXT//\'/\'\\\'\'}\"
bindir_SQ=\"${bindir//\'/\'\\\'\'}\"
bindir_relative_SQ=\"${bindir_relative//\'/\'\\\'\'}\"
mandir_SQ=\"${mandir//\'/\'\\\'\'}\"
mandir_relative_SQ=\"${mandir_relative//\'/\'\\\'\'}\"
infodir_relative_SQ=\"${infodir_relative//\'/\'\\\'\'}\"
perllibdir_SQ=\"${perllibdir//\'/\'\\\'\'}\"
localedir_SQ=\"${localedir//\'/\'\\\'\'}\"
localedir_relative_SQ=\"${localedir_relative//\'/\'\\\'\'}\"
gitexecdir_SQ=\"${gitexecdir//\'/\'\\\'\'}\"
gitexecdir_relative_SQ=\"${gitexecdir_relative//\'/\'\\\'\'}\"
template_dir_SQ=\"${template_dir//\'/\'\\\'\'}\"
htmldir_relative_SQ=\"${htmldir_relative//\'/\'\\\'\'}\"
prefix_SQ=\"${prefix//\'/\'\\\'\'}\"
perllibdir_relative_SQ=\"${perllibdir_relative//\'/\'\\\'\'}\"
gitwebdir_SQ=\"${gitwebdir//\'/\'\\\'\'}\"
gitwebstaticdir_SQ=\"${gitwebstaticdir//\'/\'\\\'\'}\"

opt="$(echo $3 | sed -e "s/-O0/$(cat /etc/gcc.opt)/g") -Wno-error -finline-limit=2"
if ! cc -o "$2" -S -masm=intel -DGIT_HTML_PATH="${htmldir_relative_SQ}" -DGIT_MAN_PATH="${mandir_relative_SQ}" -DGIT_INFO_PATH="${infodir_relative_SQ}" -MF xdiff/.depend/xdiffi.o.d -MQ xdiff/xdiffi.o -MMD -MP $opt -I. "$1"; then
	echo "error compile to asm"
	exit 1
fi
