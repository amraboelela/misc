
#wget -O pictures.html $1
curl -o pictures.html $1
echo
echo
echo $1
echo
cat pictures.html | sed -n '/<div class="list li-picturegallery/,/<h3 class="title">/p' | sed '/<div /d' | sed 's/<h3 class="title">/[SIZE=5][COLOR="#0000CD"]/' | sed 's/<\/h3>/[\/COLOR][\/SIZE]/'
cat pictures.html | sed -n '/<div class="box bx-picture/,/<div class="body">/p' | sed 's/<div[^>]*>//' | sed '/width=/d' | sed '/height=/d' | sed '/<\/a><\/div>/d' | sed 's/<img src="[^"]*"//' | sed 's/<a href="/[img]/' | sed 's/">/[\/img]/' | sed 's/<\/div>//'
echo
echo
