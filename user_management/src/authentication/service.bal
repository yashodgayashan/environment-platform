import ballerina/crypto;
import ballerina/http;
import ballerina/io;
import ballerina/jwt;
// import ballerina/log;
import ballerina/time;

crypto:KeyStore keyStore = {
    path: "dependencies/security/ballerinaKeystore.p12",
    password: "ballerina"
};

jwt:JwtKeyStoreConfig config = {
    keyStore: keyStore,
    keyAlias: "ballerina",
    keyPassword: "ballerina"
};

listener http:Listener endPoint = new (USER_SERVICES_PORT);

@http:ServiceConfig {
    basePath: BASEPATH,
    cors: {
        allowOrigins: ["*"]
    }
}
service userService on endPoint {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/register-user"
    }
    resource function registerUser(http:Caller caller, http:Request req) returns @untainted error? {

        http:Response response = new;
        var payload = req.getJsonPayload();

        if (payload is json) {
            [string, string, string, int, string, string][firstName, lastName, email, phoneNumber, address, password] = check checkUser(payload);
            error | boolean user = insertUser(firstName, lastName, email, phoneNumber, address, password, "user");
            if (user is error) {
                response.statusCode = http:STATUS_CONFLICT;
                response.setJsonPayload({"Message": <@untainted>user.reason()});
            } else {
                if (user) {
                    response.statusCode = http:STATUS_CREATED;
                    response.setJsonPayload({"Message": "Successfully added"});
                } else {
                    response.statusCode = http:STATUS_FORBIDDEN;
                    response.setJsonPayload({"Message": "Cannot create the user"});
                }
            }
        } else {
            response.statusCode = http:STATUS_BAD_REQUEST;
            response.setJsonPayload({"Message": "Invalid Json Payload"});
        }
        error? result = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/register-admin"
    }
    resource function registerAdmin(http:Caller caller, http:Request req) returns @untainted error? {

        http:Response response = new;
        var payload = req.getJsonPayload();

        if (payload is json) {
            [string, string, string, int, string, string][firstName, lastName, email, phoneNumber, address, password] = check checkUser(payload);
            error | boolean user = insertUser(firstName, lastName, email, phoneNumber, address, password, "admin");
            if (user is error) {
                response.statusCode = http:STATUS_CONFLICT;
                response.setJsonPayload({"Message": <@untainted>user.reason()});
            } else {
                if (user) {
                    response.statusCode = http:STATUS_CREATED;
                    response.setJsonPayload({"Message": "Successfully added"});
                } else {
                    response.statusCode = http:STATUS_FORBIDDEN;
                    response.setJsonPayload({"Message": "Cannot create the user"});
                }
            }
        } else {
            response.statusCode = http:STATUS_BAD_REQUEST;
            response.setJsonPayload({"Message": "Invalid Json Payload"});
        }
        error? result = caller->respond(response);
    }

}


public function main() {
    error | boolean code = createTable();
    error | boolean us = insertUser("yashod", "gayashan", "yashodgayashan@gmail.com", 772424889, "no 4040, Bambukuliya kochchikade", "testPassword", "user");

    User | error usr = getUser("yashodgayashan@gmail.com", "testPassword");
    io:print(usr);
    jwt:JwtHeader header = {};
    header.alg = jwt:RS256;
    header.typ = "JWT";

    jwt:JwtPayload payload = {};
    payload.sub = "John";
    payload.iss = "wso2";
    payload.aud = ["ballerina", "ballerinaSamples"];
    payload.exp = time:currentTime().time / 1000 + 3600;
    string | error jwt = jwt:issueJwt(header, payload, config);
// io:print(jwt);
}

