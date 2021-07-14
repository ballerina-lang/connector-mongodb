## Overview
The Mongo DB connector allows you to connect to a Mongo DB from Ballerina and perform various operations such as `getDatabaseNames`, `getCollectionNames`, `count`, `listIndices`, `find`, `insert`, `update`, and `delete`.

This module supports Ballerina Swan Lake Beta2 version.

## Configuring connector
### Prerequisites

* A mongodb with username and password

* Java 11 Installed <br/> Java Development Kit (JDK) with version 11 is required.

* Ballerina Swan Lake Beta2 Installed <br/> Ballerina Swan Lake Beta2 is required.

## Quickstart

### Insert a document

#### Step 1: Import the Mongo DB module
First, import the `ballerinax/mongodb` module into the Ballerina project.
```ballerina
import ballerinax/mongodb;
```
#### Step 2: Set up configurable values
You can add required variables as configurable values in the ballerina file and can add those values in `Config.toml` file. 
1. In Ballerina file 
```ballerina
configurable string host = ?;
configurable int port = ?;
configurable string username = ?;
configurable string password = ?;
configurable string database = ?;
configurable string collection = ?;
```
2. In Config.toml

```
host = "<YOUR_HOST_NAME>""
port = <PORT>
username = "<DB_USERNAME>"
password = "<DB_PASSWORD>"

database = "<DATABASE_NAME>"
collection = "<COLLECTION_NAME>"
```

#### Step 3: Initialize the Mongodb Client giving necessary credentials

You can now enter the credentials in the mongo client config. If you use this client for a particular database then you can pass the database name along with config during client initialization(It is optional). Otherwise you can pass the database name for each remote method call. This is not recommended unless you need to connect more than one database using a client. You need to set the database using atleast one of these methods.
```ballerina
mongodb:ClientConfig mongoConfig = {
        host: host,
        port: port,
        username: username,
        password: password,
        options: {sslEnabled: false, serverSelectionTimeout: 5000}
    };

    mongodb:Client mongoClient = checkpanic new (mongoConfig, database);
```
#### Step 4: Insert the document
You can invoke the remote method `insert` to insert the document.
```ballerina
    map<json> doc = { "name": "Gmail", "version": "0.99.1", "type" : "Service" };

    check mongoClient->insert(doc, collection);
```
#### Step 5: Close the db client connection. 

```ballerina
mongoClient->close();
```

## Snippets

Snippets of some operations.

- Insert a document
    ```ballerina
    map<json> doc = { "name": "Gmail", "version": "0.99.1", "type" : "Service" };

    check mongoClient->insert(doc, collection);
    ```
- Querying
    ```ballerina
    map<json>[] jsonRet = check mongoClient->find(collection,(),());
    ``` 
- Count documents
    ```ballerina
    int count = checkpanic mongoClient->countDocuments(collection,());
    ``` 

### [You can find more samples here](https://github.com/ballerina-platform/module-ballerinax-mongodb/blob/master/mongodb/samples/)
