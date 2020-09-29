Safe Parallel Test Runner.
=================================
[![Build Status](https://travis-ci.com/Mondego/TLDR.svg?token=o5WYd55iTZU8HSqiSULp&branch=master)](https://travis-ci.com/Mondego/TLDR)


Running TLDR
-------------

To run TLDR with a project, follow these steps:

* Clone this repository.

* `cd` to TLDR repository and type `mvn install` in the terminal. This will compile and install TLDR in your local maven repository.

* Install Redis in your machine. For mac -- 
```
brew update
brew install redis
```

* Add this xml code in the `plugins` section of the `pom.xml` file of the project on which you want to use TLDR - 
```
<plugin>
    <groupId>com.mondego.ics.uci</groupId>
    <artifactId>testrunner-plugin</artifactId>
    <version>1.0.2-SNAPSHOT</version>
</plugin>
```
* Type the following maven command to run tests with TLDR - 
```
mvn testrunner:testrunner
```
If the project has used `rat` or `checkStyle` plugin turn them off - 
```
 mvn tldr:tldr -Dmaven.test.failure.ignore=true -Drat.skip=true -Dcheckstyle.skip=true
```

* Some optional flags - \
 `commit.hash` -- Hash code of a particular commit. This can be used to log TLDR result for a particular commit. \
 `commit.serial` -- Serial number of a commit. This is used then the tool is being evaluated on a series of commit one by one. \
 `parallel.retest.all` -- Setting it to `true` will turn off TLDR and perform `retest-all` parallelly. \
 `log.directory` -- The directory where the logs will be written. If this flag is not used then by default log is written to the home directory.  
 `debug.flag` -- Setting it to `true` will turn off debug logs. 
 `multimodule.projectname` -- Name of a multi-module is passed by this flag. 
 `thread.count` -- Number of threads
 `fork.count` -- Number of forks.
