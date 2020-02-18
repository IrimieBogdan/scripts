### Run Windows modules test using puppet gem on VMpooler using bolt


```
# run for single module
MODULE=puppetlabs-registry PASSWORD= GEM_SOURCE= FACTER_GEM_VERSION= ./run_acceptance.sh

# run for a subset of defined modules using iTerm2
PASSWORD= GEM_SOURCE= FACTER_GEM_VERSION= ./run_acceptance_parallel.sh
```

