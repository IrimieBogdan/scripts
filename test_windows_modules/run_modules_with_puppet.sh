MODULE=puppetlabs-registry
VM_HOST=$(floaty get win-2019-x86_64 | awk '{print $2}')
# VM_HOST=guttural-emcee.delivery.puppetlabs.net

echo $MODULE
echo $VM_HOST

bolt script run install_ruby.ps1 2.5.7 \
  --targets winrm://$VM_HOST \
  --user Administrator \
  --password $PASSWORD \
  --no-ssl-verify \
  --debug

 bolt script run run_tests_local.ps1\
  --targets winrm://$VM_HOST \
  --user Administrator \
  --password $PASSWORD \
  --no-ssl-verify \
  --debug
