MONTH=$(date "+%m")
DAY=$(date "+%d")
path="/home/amr/misc/shell/prayer";
cat $path/res/prayer-${MONTH}.txt | sed -n "${DAY}p" | sed "s/\t/\n/g" > $path/temp/pray.txt
ZERO_ONE=$(expr $DAY % 2)
echo $ZERO_ONE
paste $path/res/commands-${ZERO_ONE}.txt $path/temp/pray.txt $path/res/ampm.txt > $path/pray.sh
paste $path/res/commands-2.txt $path/temp/pray.txt $path/res/ampm-2.txt >> $path/pray.sh
chmod 777 $path/pray.sh
$path/pray.sh
