DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
mbc="$DIR/methods_by_class"
mkdir -p "$mbc"

# shellcheck disable=SC2013
for cf in $(cat class-defn-files.list); do
  echo " --- '$cf' --- " >> "$DIR/methods-unstructured.txt"
  (
    cd ~/Projects/vmass || exit 1
    cat "$cf" | grep "def" >> $DIR/methods-unstructured.txt
    #cat "$cf"
  )
  #echo ''
  #echo ''
done

