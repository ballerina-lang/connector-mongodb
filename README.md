# Ballerina MongoDB Connector

[![Build Status](https://github.com/ballerina-platform/module-ballerinax-mongodb/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-mongodb/actions?query=workflow%3ACI)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-mongodb.svg)](https://github.com/ballerina-platform/module-ballerinax-mongodb/commits/master)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[MongoDB](https://docs.mongodb.com/v4.2/) is a general purpose, document-based, distributed database built for modern application developers and for the cloud era. MongoDB offers both a Community and an Enterprise version of the database.

Ballerina MongoDB connector connects to MongoDB from ballerina. 

For more information, go to the module(s).

- [`ballerinax/mongodb`](https://docs.central.ballerina.io/ballerinax/mongodb/2.0.9)

## Building from the Source

### Setting Up the Prerequisites

1. Download and install Java SE Development Kit (JDK) version 11 (from one of the following locations).

   * [Oracle](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html)

   * [OpenJDK](https://adoptopenjdk.net/)

        > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed JDK.

2. Download and install [Ballerina Swan Lake Beta2](https://ballerina.io/). 

3. Download and install gradle.

4. Export Github Personal access token with read package permissions as follows,

```
 export packageUser=<Username>
 export packagePAT=<Personal access token>
 ```

### Building the Source

Execute the commands below to build the connector from the source after setting up the prerequisites.

1. To build the entire connector:

Execute the following command from root directory
```shell script
    ./gradlew build
```

2. To build the ballerina module only without the tests:

change the directory to `mongodb`
```shell script
    cd mongodb
```
Then execute the following command
```shell script
    bal build -c --skip-tests
```
3. To test the connector, follow the instructions given in https://github.com/ballerina-platform/module-ballerinax-mongodb/blob/master/mongodb/tests/Ballerina.md

## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community. 

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of Conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful Links

* Discuss the code changes of the Ballerina project in [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Slack channel](https://ballerina.io/community/slack/).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
