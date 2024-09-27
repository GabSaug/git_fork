# $1: name of the c file to compile to assembly
# $2 output path
opt="$(echo $3 | sed -e "s/-O0/$(cat /etc/gcc.opt)/g") -Wno-error -finline-limit=2"
if ! cc -o "$2" -S -masm=intel -MF xdiff/.depend/xdiffi.o.d -MQ xdiff/xdiffi.o -MMD -MP $opt -I. "$1"; then
	echo "error compile to asm"
	exit 1
fi
