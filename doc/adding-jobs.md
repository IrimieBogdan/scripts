Adding Jobs
===========

This document is a supplement to [Using Jenkins Job Builder](usingjjb) and
[ci-jobs-config Guidelines](guidelines) and is meant to assist developers in setting
up CI jobs.

The bare minimum you need to get a job running on Jenkins is:

- A Project in `enterprise/production/`
- A Job Template in `resources/jobs/`

Additionally, you may also want/need:

- A Script in `resources/scripts/` to do any shell operations
- A Pipeline in `resources/pipelines` (optional but recommended if you have related jobs and/or a group a jobs that are sequential)

[This diagram show the relationship between projects, pipelines and jobs](images/jjb.png)

## Projects

Projects are what pull together all the other JJB configuration to create concrete job instances.
They define lists of jobs (or job-pipelines), declare variable values, and name the defaults to use for their jobs.
Projects names should correspond to a git repository name. See [Defaults](defaults) for more details.

## Job Templates

Job templates live in `resources/jobs/` and are grouped by file according to type.
See [the Jenkins Conventions Confluence page](conventions) for naming conventions. A single job
file may contain multiple `job-template` entries, see [unit-js](unitjs) for an example.

## Scripts

Shell scripts live in `resources/scripts` and can be included in your job templates
under the `builders` key:

    builders:
        - shell:
            !include-raw foo-bar-baz.sh


### A note about hashbang lines

If you're not using rvm/lein, the preferred form is:

    #!/usr/bin/env bash

    set -x
    set -e

If you are using rvm/lein, set -x and -e after executing any rvm/lein commands:

    #!/usr/bin/env bash

    rvm ...

    set -x
    set -e

## Pipelines

Pipelines live in `reources/pipelines/` and are used to group related jobs or jobs that are
alway run in sequence. They can contain multiple `job-group` entries that describe a sequence
of jobs to run serially.


[usingjjb]: https://confluence.puppetlabs.com/display/QE/Using+Jenkins+Job+Builder
[guidelines]: https://confluence.puppetlabs.com/display/QE/ci-job-configs+Guidelines
[conventions]: https://confluence.puppetlabs.com/display/QE/Jenkins+Conventions
[unitjs]: https://github.com/puppetlabs/ci-job-configs/blob/master/resources/jobs/unit-js.yaml
[defaults]: https://confluence.puppetlabs.com/display/QE/ci-job-configs+Guidelines#ci-job-configsGuidelines-defaults
