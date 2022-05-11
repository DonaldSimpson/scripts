# For each line beginning with "variable" in variables.tf, get the variable name
# then count and note the number of times var.{variable name} appears in main.tf
for VAR in `grep '^variable' variables.tf | awk -F\" '{print $2}' | sort`; do
  COUNT=`grep -c var.${VAR} main.tf`
  if [ $COUNT == 0 ] 
  then
    UNUSED="$UNUSED\n${VAR}"   
    COUNTER=$((COUNTER+1))
  else
    USED="$USED\n${VAR}: $COUNT"   
  fi
done
echo "## USED VARS   : $USED\n"
echo "## UNUSED VARS : $UNUSED\n"
echo "## UNUSED COUNT: $COUNTER"

