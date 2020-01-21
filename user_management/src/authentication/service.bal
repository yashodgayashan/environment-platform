import ballerina/crypto;
import ballerina/io;
import ballerina/jwt;
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


public function main() {

    jwt:JwtHeader header = {};
    header.alg = jwt:RS256;
    header.typ = "JWT";

    jwt:JwtPayload payload = {};
    payload.sub = "John";
    payload.iss = "mit_iap";
    payload.jti = "100078234ba23";
    payload.aud = ["ballerina", "ballerinaSamples"];
    payload.exp = time:currentTime().time / 1000 + 600;

    string | error jwt = jwt:issueJwt(header, payload, config);
    io:println(jwt);
}
