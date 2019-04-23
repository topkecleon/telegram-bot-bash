#### [Home](../README.md)
## Notes for bashbot developers
This section is about help and best pratices for new bashbot developers. The main focus on is creating new versions of bashbot, not on develop your individual bot. Nevertheless the rules and tools described here can also help you with your bot development.

bashbot development is done on github. If you want to provide fixes or new features [fork bashbot on githup](https://help.github.com/en/articles/fork-a-repo) and provide changes as [pull request on github](https://help.github.com/en/articles/creating-a-pull-request).

### Setup your develop environment

1. install git, install [shellcheck](5_practice.md#Test-your-Bot-with-shellcheck)
2. setup your [environment for UTF-8](4_expert.md#Setting-up-your-Environment)
3. clone your bashbot fork to a new directory ```git clone https://github.com/<YOURNAME>/telegram-bot-bash.git```, replace ```<YOURNAME>``` with your username on github
4. create and change to your develop branch ```git checkout -b <YOURBRANCH>```, replace ```<YOURBRANCH>``` with the name you want to name it, e.g. 'develop'
5. give your (dev) fork a new version tag: ```git tag vx.xx```, version must be higher than current version
6. setup github hooks by running ```dev/install-hooks.sh``` (optional)

### Versioning

Bashbot is tagged with version numbers. If you start a new development cycle you must tag your fork with a version higher than the current version.
E.g. if you fork 'v0.60' the next develop version should tagged as ```git tag "v0.61-dev"``` for fixes or ```git tag "v0.70-dev"``` for new features.

To get the current version name of your develepment fork run ```git describe --tags```. The output looks like ```v0.70-dev-6-g3fb7796``` where your version tag is followed by the number of commits since you tag your branch and followed by the latest commit hash. see also [comments in version.sh](../dev/version.sh)

To update the Version Number in your scripts run ```dev/version.sh```, it will update the line '#### $$VERSION$$ ###' in all files to the current version name.

If you actived git hooks in Setup step 6, 'version.sh' updates the version name on every push

### Shellchecking

For a shell script running as a service it's important to be paranoid about quoting, globbing and other common problems. So it's a must to run shellchek on all shell scripts before you commit a change. this is automated by a git hook activated in Setup step 6.

In addition you can run ```dev/hooks/pre-commit.sh``` every time you want to shellcheck all files given in 'dev/shellcheck.files'.


## bashbot tests
Starting with version 0.70 bashbot has a test suite. To start testsuite run ```test/ALL-tests.sh```. ALL-tests.sh will only return 'SUCCESS' if all tests pass.

### enabling / disabling tests

All tests are placed in the directory  ```test```. To disable a test remove the x flag from the '*-test.sh' test script, to (re)enable
a test make the script executable again.


### creating new tests
Each test consists of a script script named like ```p-name-test.sh``` *(where p is test pass 'a-z' and name the name of your test)* and
an optional dir ```p-name-test/``` *(script name minus '.sh')* for additional files.

The file ```ALL-tests.inc.sh``` must be included from all tests, do not forget the shellcheck source directive to statisfy shellcheck.

Tests with no dependency to other tests will run in pass 'a', tests which need an initialized bahsbot environment must run in pass 'd' or later. 
If '$1' is present the script is started from 'ALL-tests.sh' and a temporary test environment is setup in directory '$1'.
The temporary test environment is created when 'ALL-tests.sh' starts and deleted after all tests are finished.

Example test
```bash
#!/usr/bin/env bash
# file: b-example-test.sh

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

if [ -f "bashbot.sh" ]; then
	echo "${SUCCESS} bashbot.sh exist!"
	exit 0
else
	echo "${NOSUCCESS} bashbot.sh missing!"
	exit 1
fi
```

#### [Prev Function Reference](6_function.md)
#### [Next Bashbot Environment](8_custom.md)

#### $$VERSION$$ v0.70-dev2-4-g893ee61

