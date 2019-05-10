#### [Home](../README.md)
## Notes for bashbot developers
This section is about help and best practices for new bashbot developers. The main focus on is creating new versions of bashbot, not on develop your individual bot. Nevertheless the rules and tools described here can also help you with your bot development.

bashbot development is done on github. If you want to provide fixes or new features [fork bashbot on githup](https://help.github.com/en/articles/fork-a-repo) and provide changes as [pull request on github](https://help.github.com/en/articles/creating-a-pull-request).

### Debuging Bashbot
In normal mode of operation all bashbot output is discarded one more correct sent to TMUX console.
To get these messages (and more) you can start bashbot in the current shell ```./bashbot.sh startbot```. Now you can see all output or erros from bashbot.
In addition you can change the change the level of verbosity by adding  a third argumant.
```
	"debug"		redirects all output to "DEBUG.log", in addtion every update is logged in "MESSAGE.LOG" and "INLINE.log"
	"debugterm	same as debug but output and errors are sent to terminal

	"xdebug"	same as debug plus set bash option '-x' to log any executed command
	"xdebugterm"	same as xdebug, but output and errors are sent to terminal
```



### Setup your develop environment

1. install git, install [shellcheck](5_practice.md#Test-your-Bot-with-shellcheck)
2. setup your [environment for UTF-8](4_expert.md#Setting-up-your-Environment)
3. clone your bashbot fork to a new directory ```git clone https://github.com/<YOURNAME>/telegram-bot-bash.git```, replace ```<YOURNAME>``` with your username on github
4. create and change to your develop branch ```git checkout -b <YOURBRANCH>```, replace ```<YOURBRANCH>``` with the name you want to name it, e.g. 'develop'
5. give your (dev) fork a new version tag: ```git tag vx.xx```(optional) 
6. setup github hooks by running ```dev/install-hooks.sh``` (optional)

### Test, Add, Push changes
A typical bashbot develop loop looks as follow:

1. start developing - *change, copy, edit bashbot files ...*
2. after changing a bash sript: ```shellcheck -x scipt.sh```
3. ```dev/all-tests.sh``` - *in case if errors back to 2.*
4. ```dev/git-add.sh``` - *check for changed files, update version string, run git add*
5. ```git commit -m "COMMIT MESSAGE"; git push```


**If you setup your dev environment with hooks and use the scripts above, versioning, addding and testing is done automatically.**

### Prepare a new version
After some development it may time to create a new version for the users. a new version can be in sub version upgrade, e.g. for fixes and smaller additions or
a new release version for new features. To mark a new version use ```git tag NEWVERSION``` and run ```dev/version.sh``` to update all version strings.

Usually I start with pre versions and when everything looks good I push out a release candidate (rc) and finally the new version.
```
 v0.x-devx -> v0.x-prex -> v0.x-rc -> v0.x  ... 0.x+1-dev ...
```

### Versioning

Bashbot is tagged with version numbers. If you start a new development cycle you can tag your fork with a version higher than the current version.
E.g. if you fork 'v0.60' the next develop version should tagged as ```git tag "v0.61-dev"``` for fixes or ```git tag "v0.70-dev"``` for new features.

To get the current version name of your develepment fork run ```git describe --tags```. The output looks like ```v0.70-dev-6-g3fb7796``` where your version tag is followed by the number of commits since you tag your branch and followed by the latest commit hash. see also [comments in version.sh](../dev/version.sh)

To update the Version Number in files run ```dev/version.sh files```, it will update the line '#### $$VERSION$$ ###' in all files to the current version name.
To update version in all files run 'dev/version.sh' without parameter.


### Shellcheck

For a shell script running as a service it's important to be paranoid about quoting, globbing and other common problems. So it's a must to run shellchek on all shell scripts before you commit a change. this is automated by a git hook activated in Setup step 6.

To run shellcheck for a single script run ```shellcheck -x script.sh```, to check all schripts run ```dev/hooks/pre-commit.sh```.


## bashbot tests
Starting with version 0.70 bashbot has a test suite. To start testsuite run ```dev/all-tests.sh```. all-tests.sh will return 'SUCCESS' only if all tests pass.

### enabling / disabling tests

All tests are placed in the directory  ```test```. To disable a test remove the execute flag from the '*-test.sh' script, to (re)enable a test make the script executable again.


### creating new tests
To create a new test run ```test/ADD-test-new.sh``` and answer the questions, it will create the usually needed files and dirs:

Each test consists of a script script named after ```p-name-test.sh``` *(where p is test pass 'a-z' and name the name
of your test)* and an optional dir ```p-name-test/``` *(script name minus '.sh')* for additional files.

Tests with no dependency to other tests will run in pass 'a', tests which need an initialized bahsbot environment must run in pass 'd' or later. 
A temporary test environment is created when 'ALL-tests.sh' starts and deleted after all tests are finished.

The file ```ALL-tests.inc.sh``` must be included from all tests and provide the test environment as shell variables:
```bash
# Test Evironment
 TESTME="$(basename "$0")"
 DIRME="$(pwd)"
 TESTDIR="$1"
 LOGFILE="${TESTDIR}/${TESTME}.log"
 REFDIR="${TESTME%.sh}"
 TESTNAME="${REFDIR//-/ }"

# common filenames
 TOKENFILE="token"
 ACLFILE="botacl"
 COUNTFILE="count"
 ADMINFILE="botadmin"
 DATADIR="data-bot-bash"

# SUCCESS NOSUCCES -> echo "${SUCCESS}" or echo "${NOSUCCESS}" 
 SUCCESS="   OK"
 NOSUCCESS="   FAILED!"

# default input, reference and output files
 INPUTFILE="${DIRME}/${REFDIR}/${REFDIR}.input"
 REFFILE="${DIRME}/${REFDIR}/${REFDIR}.result"
 OUTPUTFILE="${TESTDIR}/${REFDIR}.out"
```

Example test
```bash
#!/usr/bin/env bash
# file: b-example-test.sh

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

if [ -f "${TESTDIR}/bashbot.sh" ]; then
	echo "${SUCCESS} bashbot.sh exist!"
	exit 0
else
	echo "${NOSUCCESS} ${TESTDIR}/bashbot.sh missing!"
	exit 1
fi
```

#### [Prev Function Reference](6_reference.md)
#### [Next Bashbot Environment](8_custom.md)

#### $$VERSION$$ v0.72-dev-4-gbf00d33

