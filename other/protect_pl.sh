protected_remote='origin'

policy='[Policy] Never push to the '$protected_remote' ! (Prevented with pre-push hook.)'

current_remote=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} | sed -r 's;^([^/]+)/.*;\1;')

push_command=$(ps -ocommand= -p $PPID)

echo $push_command

do_exit(){
  echo $policy
  exit 1
}

if [[ $push_command =~ $protected_remote ]]; then
  do_exit
fi


unset do_exit

exit 0
