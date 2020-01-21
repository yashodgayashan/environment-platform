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

# The `createTable` function used to create the users table.
# 
# + return - Boolean true if table is created, error if not.
public function createTable() returns @tainted boolean | error {

    // Create the users table.
    var dbResult = testDB->update("CREATE TABLE IF NOT EXISTS USERS (id INTEGER NOT NULL AUTO_INCREMENT, firstName VARCHAR(100), lastName VARCHAR(100), email VARCHAR(200), phoneNumber INTEGER, address VARCHAR(200), password VARCHAR(150), PRIMARY KEY (id))");
    // Check status of the table creation.
    error | boolean dbStatus = processUpdate(dbResult, "Create users table");

    return dbStatus;
}

# Insert a user record to the users table.
# 
# + firstName - firstname of the user.
# + lastName - lastname of the user.
# + email - email the user.
# + phoneNumber - phoneNumber of the user.
# + address - address the user.
# + password  - password of the user.
# + return   - Boolean true if the insertion is successful, error if else.
public function insertStudent(string firstName, string lastName, string email, int phoneNumber, string address, string password) returns @tainted boolean | error {

    // Insert a student to the table
    var dbResult = testDB->update("INSERT INTO USERS (firstName, lastName, email, phoneNumber, address, password) VALUES (?, ?, ?, ?, ?, ?)", firstName, lastName, email, phoneNumber, address, password);
    error | boolean dbStatus = processUpdate(dbResult, "Insert data to USERS table");

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
