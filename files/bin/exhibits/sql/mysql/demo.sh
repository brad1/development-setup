# alternatively,specify db name on cli
# mysql -p example < demo.sql > out.tab

: > out.tab
# mysql -p < demo.sql >> out.tab
# mysql -p < demo_joins.sql >> out.tab
mysql -p < demo_joins_x2.sql >> out.tab
# mysql -p < demo_select.sql >> out.tab

cat out.tab | less
