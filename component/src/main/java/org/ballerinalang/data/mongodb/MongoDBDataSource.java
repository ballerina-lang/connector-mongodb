/*
 * Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.ballerinalang.data.mongodb;

import com.mongodb.MongoClient;
import com.mongodb.MongoClientOptions;
import com.mongodb.MongoCredential;
import com.mongodb.ReadConcern;
import com.mongodb.ReadConcernLevel;
import com.mongodb.ReadPreference;
import com.mongodb.ServerAddress;
import com.mongodb.WriteConcern;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;
import org.ballerinalang.model.types.BType;
import org.ballerinalang.model.util.JsonGenerator;
import org.ballerinalang.model.util.JsonParser;
import org.ballerinalang.model.values.BJSON;
import org.ballerinalang.model.values.BStruct;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.util.exceptions.BallerinaException;
import org.bson.Document;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * {@code MongoDBDataSource} util class for MongoDB connector initialization.
 *
 * @since 0.95.0
 */
public class MongoDBDataSource implements BValue {
    private MongoDatabase db;
    private MongoClient client;

    public MongoDBDataSource() {}

    public MongoDatabase getMongoDatabase() {
        return db;
    }

    public MongoClient getMongoClient() {
        return client;
    }


    public boolean init(String host, String dbName, BStruct options) {
        if (options != null) {
            String username = options.getStringField(3);
            String password = options.getStringField(4);
            List<MongoCredential> credentials = new ArrayList<>();
            if (!username.isEmpty() && !password.isEmpty()) {
                credentials.add(MongoCredential.createCredential(username, dbName, password.toCharArray()));
                this.client = new MongoClient(
                        this.createServerAddresses(host),
                        credentials, this.createOptions(options)
                );
            } else {
                this.client = new MongoClient(this.createServerAddresses(host), this.createOptions(options));
            }
        } else {
            this.client = new MongoClient(this.createServerAddresses(host));
        }
        this.db = this.client.getDatabase(dbName);
        return true;
    }

    private MongoClientOptions createOptions(BStruct options) {
        MongoClientOptions.Builder builder = MongoClientOptions.builder();
        boolean sslEnabled = options.getBooleanField(0) != 0;
        if (sslEnabled) {
            builder = builder.sslEnabled(true);
        }
        String readConsern = options.getStringField(0);
        if (!readConsern.isEmpty()) {
            builder = builder.readConcern(new ReadConcern(ReadConcernLevel.valueOf(readConsern)));
        }
        String writeConsern = options.getStringField(1);
        if (!writeConsern.isEmpty()) {
            builder = builder.writeConcern(WriteConcern.valueOf(writeConsern));
        }
        String readPreference = options.getStringField(2);
        if (!readPreference.isEmpty()) {
            builder = builder.readPreference((ReadPreference.valueOf(readPreference)));
        }
        int socketTimeout = (int) options.getIntField(0);
        if (socketTimeout != -1) {
            builder = builder.socketTimeout(socketTimeout);
        }
        int connectionTimeout = (int) options.getIntField(1);
        if (connectionTimeout != -1) {
            builder = builder.connectTimeout(connectionTimeout);
        }
        int connectionsPerHost = (int) options.getIntField(2);
        if (connectionsPerHost != -1) {
            builder = builder.connectionsPerHost(connectionsPerHost);
        }
        int serverSelectionTimeout = (int) options.getIntField(3);
        if (serverSelectionTimeout != -1) {
            builder = builder.serverSelectionTimeout(serverSelectionTimeout);
        }
        return builder.build();
    }

    private List<ServerAddress> createServerAddresses(String hostStr) {
        List<ServerAddress> result = new ArrayList<ServerAddress>();
        String[] hosts = hostStr.split(",");
        for (String host : hosts) {
            result.add(this.createServerAddress(host));
        }
        return result;
    }

    private ServerAddress createServerAddress(String hostStr) {
        String[] hostPort = hostStr.split(":");
        String host = hostPort[0];
        int port;
        if (hostPort.length > 1) {
            try {
                port = Integer.parseInt(hostPort[2]);
            } catch (NumberFormatException e) {
                throw new BallerinaException("the port of the host string must be an integer: " + hostStr, e);
            }
        } else {
            port = ServerAddress.defaultPort();
        }
        return new ServerAddress(host, port);
    }

    @Override
    public String stringValue() {
        return null;
    }

    @Override
    public BType getType() {
        return null;
    }

    @Override
    public BValue copy() {
        return null;
    }

    /**
     * MongoDB result cursor implementation of {@link BJSON}.
     */
    public static class MongoJSONDataSource implements BJSON.JSONDataSource {

        private MongoCursor<Document> mc;

        public MongoJSONDataSource(MongoCursor<Document> mc) {
            this.mc = mc;
        }

        @Override
        public void serialize(JsonGenerator jsonGenerator) throws IOException {
            jsonGenerator.writeStartArray();
            while (this.mc.hasNext()) {
                JsonParser.parse(this.mc.next().toJson()).serialize(jsonGenerator);
            }
            jsonGenerator.writeEndArray();
        }
    }
}
