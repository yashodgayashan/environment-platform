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

jwt:InboundJwtAuthProvider jwtAuthProvider = new ({
    issuer: "wso2",
    audience: "ballerina",
    trustStoreConfig: {
        certificateAlias: "ballerina",
        trustStore: {
            path: "dependencies/security/ballerinaTruststore.p12",
            password: "ballerina"
        }
    }
});

http:BearerAuthHandler jwtAuthHandler = new (jwtAuthProvider);


listener http:Listener endPoint = new (USER_SERVICES_PORT);

@http:ServiceConfig {
    basePath: BASEPATH,
    cors: {
        allowOrigins: ["*"]
    }
}
service userService on endPoint {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/sayHello"
    }
    resource function hello(http:Caller caller, http:Request req) {
        error? result = caller->respond("Hello, World!!!");
    }
}

public function main() {
    error | boolean code = createTable();
    error | boolean err = insertStudent("yashod", "perera", "yashodgayashan@gmail.com", 772424889, "no 404, Bambukuliya kochchikade", "testPassword");
    jwt:JwtHeader header = {};
    header.alg = jwt:RS256;
    header.typ = "JWT";

    jwt:JwtPayload payload = {};
    payload.sub = "John";
    payload.iss = "wso2";
    payload.aud = ["ballerina", "ballerinaSamples"];
    payload.exp = time:currentTime().time / 1000 + 3600;
    string | error jwt = jwt:issueJwt(header, payload, config);
    io:print(jwt);
}

