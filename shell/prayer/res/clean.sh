sed -i "s/^  //" $1
sed -i "s/[A-Z][a-z][a-z]\t//" $1
sed -i "s/[0-9]*\t//" $1
sed -i "s/[^\t]*\t//" $1
cat $1
