DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
rm $DIR/class-* 2>/dev/null

# shellcheck disable=SC2013
for cn in $(cat classes); do
  # echo " --- '$cn' --- "
  (
    cd ~/Projects/vmass || exit 1
    ag "class $cn[^0-9-zA-Z]{1}" --ignore-dir={test,spec,ve7000}    >> $DIR/class-defn-unstructured.txt
    ag -l "class $cn[^0-9-zA-Z]{1}" --ignore-dir={test,spec,ve7000} >> $DIR/class-defn-files.list
  )
  #echo ''
  #echo ''
done

