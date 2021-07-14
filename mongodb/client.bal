// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/jballerina.java;

# Represents the MongoDB client.
@display {label: "MongoDB", iconPath: "MongoDBLogo.png"}
public client class Client {

    handle datasource;
    handle database = java:createNull();

    # Initialises the `Client` object with the provided `ClientConfig` properties.
    # 
    # + config - `ClientConfig` properties. Even though all fields are optional, in order to authenticate the database, 
    #             relavent fields should be given in config record. Following are some examples :
    #             (1) Username, Password
    #             (2) URL - Connection URL
    #             (3) Username, secureSocket, authMechanism etc.
    #             
    # + databaseName - Database name to connect
    # + return - A `mongodb:Error` if there is any error in the provided configurations or database name
    public isolated function init(ClientConfig config, @display {label: "Database Name"} string? databaseName = ())
                                  returns Error? {
        var configOptions = config?.options;
        if (configOptions is ConnectionProperties) {
            if (configOptions?.sslEnabled is boolean) {
                if (<boolean>configOptions?.sslEnabled && configOptions?.secureSocket is ()) {
                    return error ApplicationError("The connection property `secureSocket` is mandatory " +
                    "when ssl is enabled for connection.");
                }
            }
        }
        self.datasource = check initClient(config);
        if (databaseName is string){
            self.database = check self.getDatabase(databaseName);            
        }
    }

    //Database management operations
    # Lists the database names in the MongoDB server.
    #
    # + return - An array of database names on success or else a `mongodb:DatabaseError` if unable to reach the DB 
    @display {label: "Get Database Names"}
    remote isolated function getDatabasesNames() returns @display {label: "Database Names"} string[]|DatabaseError {
        return getDatabasesNames(self.datasource);
    }

    # Returns the `Database` handle.
    # 
    # + databaseName - Name of the database
    # + return - A database handle on success or else a `mongodb:Error` if unable to reach the DB
    isolated function getDatabase(string databaseName) returns handle|Error {
        if (databaseName.trim().length() == 0) {
            return error ApplicationError("Database Name cannot be empty.");
        }
        handle database = check getDatabase(self.datasource, databaseName);
        return database;
    }

    //Collection management operations 
    # Lists the collection names in the MongoDB database.
    #
    # + databaseName - Name of the database 
    # + return - An array of collection names on success or else a `mongodb:Error` if unable to reach the DB
    @display {label: "Get Collection Names"}
    remote isolated function getCollectionNames(@display {label: "Database Name"} string? databaseName = ()) 
                                       returns @display {label: "List of Collections"} string[]|Error {
        handle database = check self.getCurrentDatabase(databaseName);        
        return getCollectionNames(database); 
    }

    # Returns the collection handle.
    # 
    # + collectionName - Name of the collection
    # + databaseName - Name of the database 
    # + return - A collection object on success or else a `mongodb:Error` if unable to reach the DB
    isolated function getCollection(string collectionName, string? databaseName = ()) returns handle|Error {
        if (collectionName.trim().length() == 0) {
            return error ApplicationError("Collection Name cannot be empty.");
        }
        handle database = check self.getCurrentDatabase(databaseName);
        handle collection = check getCollection(database, collectionName);
        return collection;
    }

    // Collection service operations
    # Counts the documents based on the filter. When the filter is (), it counts all the documents in the collection.
    #
    # + collectionName - Name of the collection
    # + databaseName - Name of the database
    # + filter - Filter for the count ($where & $near can be used)
    # + return - Count of the documents in the collection or else `mongodb:Error` if unable to reach the DB
    @display {label: "Count Documents"}
    remote isolated function countDocuments(@display {label: "Collection Name"} string collectionName, 
                                   @display {label: "Database Name"} string? databaseName = (), 
                                   @display {label: "Filter"} map<json>? filter = ()) 
                                   returns @display {label: "Number of Documents"} int|Error {
        handle collection = check self.getCollection(collectionName, databaseName);
        if (filter is ()) {
            return countDocuments(collection, ());
        }
        string filterString = filter.toJsonString();
        return countDocuments(collection, java:fromString(filterString));
    }

    # Lists the indices associated with the collection.
    #
    # + collectionName - Name of the collection
    # + databaseName - Name of the database 
    # + return - a JSON object with indices on success or else a `mongodb:Error` if unable to reach the DB
    @display {label: "List Indices"}
    remote isolated function listIndices(@display {label: "Collection Name"} string collectionName, 
                                @display {label: "Database Name"} string? databaseName = ()) 
                                returns @display {label: "List of Indices"} map<json>[]|Error {
        handle collection = check self.getCollection(collectionName, databaseName);
        return listIndices(collection);
    }


    # Inserts one document.
    # 
    # ```ballerina
    #   mongodb:ClientConfig mongoConfig = {
    #       host: host,
    #       port: port,
    #       username: username,
    #       password: password,
    #       options: {sslEnabled: false, serverSelectionTimeout: 5000}
    #   };
    #   mongodb:Client mongoClient = checkpanic new (mongoConfig, database);
    #   map<json> document = { "name": "Gmail", "version": "0.99.1", "type" : "Service" };
    #   checkpanic  mongoClient->insert(doc, collection);
    # ```
    # 
    # + document - Document to be inserted as a JSON map
    # + collectionName - Name of the collection
    # + databaseName - Name of the database 
    # + return - `()` on success or else a `mongodb:Error` if unable to reach the DB
    @display {label: "Insert Document"}
    remote isolated function insert(@display {label: "Document"} map<json> document, 
                           @display {label: "Collection Name"} string collectionName, 
                           @display {label: "Database Name"} string? databaseName = ()) returns Error? {
        handle collection = check self.getCollection(collectionName, databaseName);
        string documentStr = document.toJsonString();
        return insert(collection, java:fromString(documentStr));
    }

    # The queries collection for documents, which sorts and limits the returned results.
    #
    # + collectionName - Name of the collection
    # + databaseName - Name of the database 
    # + filter - Filter for the query
    # + sort - Sort options for the query
    # + limit - Limit options for the query results. No limit is applied for -1
    # + return - JSON array of the documents in the collection or else a `mongodb:Error` if unable to reach the DB
    @display {label: "Query for Documents"}
    remote isolated function find(@display {label: "Collection Name"} string collectionName, 
                         @display {label: "Database Name"} string? databaseName = (),
                         @display {label: "Filter for Query"} map<json>? filter = (),
                         @display {label: "Sort Options"} map<json>? sort = (),
                         @display {label: "Limit"} int 'limit = -1) 
                         returns @display {label: "Documents"} map<json>[]|Error {
        handle collection = check self.getCollection(collectionName, databaseName);
        if (filter is ()) {
            if (sort is ()) {
                return find(collection, (), (), 'limit);
            }
            string sortString = sort.toJsonString();
            return find(collection, (), java:fromString(sortString), 'limit);
        }
        string filterStr = filter.toJsonString();
        if (sort is ()) {
            return find(collection, java:fromString(filterStr), (), 'limit);
        }
        string sortString = sort.toJsonString();
        return find(collection, java:fromString(filterStr), java:fromString(sortString), 'limit);
    }

    # Updates a document based on a condition.
    #
    # + set - Document for the update condition
    # + collectionName - Name of the collection
    # + databaseName - Name of the database
    # + filter - Filter for the query
    # + isMultiple - Whether to update multiple documents
    # + upsert - Whether to insert if update cannot be achieved
    # + return - JSON array of the documents in the collection or else a `mongodb:Error` if unable to reach the DB
    @display {label: "Update Document"}
    remote isolated function update(@display {label: "Document to Update"} map<json> set, 
                                    @display {label: "Collection Name"} string collectionName, 
                                    @display {label: "Database Name"} string? databaseName = (),
                                    @display {label: "Filter for Query"} map<json>? filter = (), 
                                    @display {label: "Is Multiple Documents"} boolean isMultiple = false,
                                    @display {label: "Is Upsert"} boolean upsert = false) 
                                    returns @display {label: "Number of Updated Documents"} int|Error {
        handle collection = check self.getCollection(collectionName, databaseName);
        string updateDoc = set.toJsonString();
        if (filter is ()) {
            return update(collection, java:fromString(updateDoc), (), isMultiple, upsert);
        }
        string filterStr = filter.toJsonString();
        return update(collection, java:fromString(updateDoc), java:fromString(filterStr), isMultiple, upsert);
    }

    # Deletes a document based on a condition.
    # 
    # + collectionName - Name of the collection
    # + databaseName - Name of the database 
    # + filter - Filter for the query
    # + isMultiple - Delete multiple documents if the condition is matched
    # + return - The number of deleted documents or else a `mongodb:Error` if unable to reach the DB
    @display {label: "Delete Document"}
    remote isolated function delete(@display {label: "Collection Name"} string collectionName, 
                           @display {label: "Database Name"} string? databaseName = (),
                           @display {label: "Filter"} map<json>? filter = (), 
                           @display {label: "Is Multiple Documents"} boolean isMultiple = false) 
                           returns @display {label: "Number of Deleted Documents"} int|Error {
        handle collection = check self.getCollection(collectionName, databaseName);
        if (filter is ()) {
            return delete(collection, (), isMultiple);
        }
        string filterStr = filter.toJsonString();
        return delete(collection, java:fromString(filterStr), isMultiple);
    }

    # Closes the client.
    @display {label: "Close the Client"}
    remote isolated function close() {
        close(self.datasource);
    }

    # Returns the `Current Database` handle.
    # 
    # + databaseName - Name of the database
    # + return - A database handle on success or else a `mongodb:Error` if unable to get the DB
    isolated function getCurrentDatabase(string? databaseName) returns handle|Error {
        if (databaseName is string) {
            handle database = check self.getDatabase(databaseName);
            return database;
        } else {
            if (!java:isNull(self.database)) {
                return self.database;
            } else {
                return error ApplicationError("No database is set. Set a database.");
            }
        }
    }
}

isolated function initClient(ClientConfig config) returns handle|ApplicationError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBDataSourceUtil"
} external;

isolated function getDatabasesNames(handle datasource) returns string[]|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBDataSourceUtil"
} external;

isolated function getDatabase(handle datasource, string databaseName) returns handle|Error = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBDataSourceUtil"
} external;

isolated function close(handle datasource) = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBDataSourceUtil"
} external;

//Database Client Java 

isolated function getCollectionNames(handle database) returns string[]|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBDatabaseUtil"
} external;

isolated function getCollection(handle database, string collectionName) returns handle|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBDatabaseUtil"
} external;

// Collection Client Java
isolated function countDocuments(handle collection, handle? filter) returns int|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
} external;

isolated function listIndices(handle collection) returns map<json>[]|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
} external;

isolated function insert(handle collection, handle document) returns DatabaseError? = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
} external;

isolated function find(handle collection, handle? filter, handle? sort, int 'limit)
              returns map<json>[]|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
} external;

isolated function update(handle collection, handle update, handle? filter, boolean isMultiple, boolean upsert)
                returns int|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
} external;


isolated function delete(handle collection, handle? filter, boolean isMultiple) returns int|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
} external;
