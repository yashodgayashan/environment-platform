import ballerina/io;
import ballerinax/java.jdbc;

// JDBC Client for MySQL database. This client can be used with any JDBC
// supported database by providing the corresponding JDBC URL.
jdbc:Client testDB = new ({
    url: "jdbc:mysql://localhost:3306/user",
    username: "newuser",
    password: "password",
    dbOptions: {useSSL: false}
});

# The `createTable` function used to create the students table.
# 
# + return - Boolean true if table is created, error if not.email VARCHAR(200)email VARCHAR(200)
public function createTable() returns @tainted boolean | error {

    // Create the student table.
    var dbResult = testDB->update("CREATE TABLE IF NOT EXISTS USERS (id INTEGER, firstName VARCHAR(100), lastName VARCHAR(100), email VARCHAR(200), phoneNumber INTEGER, address VARCHAR(200), password VARCHAR(150), PRIMARY KEY (id))");
    // Check status of the table creation.
    error | boolean dbStatus = processUpdate(dbResult, "Create users table");

    return dbStatus;
}

# Process a request specified for an update query.
# 
# + returned - returned Parameter: Result from db.
# + message  - message Parameter: Custom message for the process. 
# + return   - Boolean true if the update is processed successfully, error if else.
function processUpdate(jdbc:UpdateResult | jdbc:Error returned, string message) returns error | boolean {

    if (returned is jdbc:UpdateResult) {
        io:println(message, " status: ", returned.updatedRowCount);
        return true;
    } else {
        io:println(message, " failed: " + <string>returned.detail()?.message);
        return error(message + " failed: " + <string>returned.detail()?.message);
    }
}
