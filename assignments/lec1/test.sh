ls > y
cat < y | sort | uniq | wc > y1
cat y1
rm y1
ls | sort | uniq | wc
rm y
echo "6.828 is cool" > x.txt | cat < x.txt
