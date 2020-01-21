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

# Blueprint for the User record.
#
# + id - Id of the user
# + firstName - firstname of the user.
# + lastName - lastname of the user.
# + email - email the user.
# + phoneNumber - phoneNumber of the user.
# + address - address the user.
# + password  - password of the user.
# + userType - Type of the user.
public type User record {
    int id;
    string firstName;
    string lastName;
    string email;
    int phoneNumber;
    string address;
    string password;
    string userType;
};

# The `createTable` function used to create the users table.
# 
# + return - Boolean true if table is created, error if not.
public function createTable() returns @tainted boolean | error {

    // Create the users table.
    var dbResult = testDB->update("CREATE TABLE IF NOT EXISTS USERS (id INTEGER NOT NULL AUTO_INCREMENT, firstName VARCHAR(100), lastName VARCHAR(100), email VARCHAR(200) UNIQUE, phoneNumber INTEGER, address VARCHAR(200), password VARCHAR(150), userType VARCHAR(50), PRIMARY KEY (id))");
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
# + userType - Type of the user
# + return   - Boolean true if the insertion is successful, error if else.
public function insertUser(string firstName, string lastName, string email, int phoneNumber, string address, string password, string userType) returns @tainted boolean | error {

    // Insert a user to the table
    var dbResult = testDB->update("INSERT INTO USERS (firstName, lastName, email, phoneNumber, address, password, userType) VALUES (?, ?, ?, ?, ?, ?, ?)", firstName, lastName, email, phoneNumber, address, password, userType);
    error | boolean dbStatus = processUpdate(dbResult, "Insert data to USERS table");

    return dbStatus;
}

# Extract a user from the db given the username and password.
# 
# + email - Email of the user.
# + password - Password of the user.
# + return - user if avaliable, else an error representing the cause.
public function getUser(string email, string password) returns @tainted User | error {

    // Retrieving data from table.
    var dbResult = testDB->select("SELECT * FROM Users WHERE email = ? AND password = ?", User, email, password);
    // Check if the result is valid.
    if (dbResult is table<User>) {
        // Check if there is data.
        if (dbResult.hasNext()) {
            return dbResult.getNext();
        } else {
            return error("User cannot be extracted with the given username and password.");
        }
    } else {
        return error("Corrupted data extracted from database.");
    }
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
