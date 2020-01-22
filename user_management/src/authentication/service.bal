import ballerina/crypto;
import ballerina/http;
import ballerina/jwt;
// import ballerina/log;

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

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/register-authority"
    }
    resource function registerAuthority(http:Caller caller, http:Request req) returns @untainted error? {

        http:Response response = new;
        var payload = req.getJsonPayload();

        if (payload is json) {
            [string, string, string, int, string, string][firstName, lastName, email, phoneNumber, address, password] = check checkUser(payload);
            error | boolean user = insertUser(firstName, lastName, email, phoneNumber, address, password, "authority");
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
        methods: ["GET"],
        path: "/login"
    }
    resource function login(http:Caller caller, http:Request req) returns @untainted error? {

        http:Response response = new;
        var payload = req.getJsonPayload();

        if (payload is json) {
            json email = check payload.email;
            json password = check payload.password;
            User | error user = getUser(<string>email, <string>password);
            if (user is User) {
                response.statusCode = http:STATUS_OK;
                response.setJsonPayload({"user": <@untainted>user.userType});
            } else {
                response.statusCode = http:STATUS_NOT_FOUND;
                response.setJsonPayload({"Message": <@untainted>user.reason()});
            }
        } else {
            response.statusCode = http:STATUS_BAD_REQUEST;
            response.setJsonPayload({"Message": "Invalid Json Payload"});
        }
        error? result = caller->respond(response);
    }
}
