import ballerina/http;
import yashodperera/utilities;

http:Client githubAPIEndpoint = new (GITHUB_API_URL);

listener http:Listener endPoint = new (ADMIN_SERVICES_PORT);

@http:ServiceConfig {
    basePath: BASEPATH,
    cors: {
        allowOrigins: ["*"]
    }
}
service adminService on endPoint {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-requests"
    }
    resource function getRequests(http:Caller caller, http:Request request) returns @untainted error? {

        http:Response response = new;
        json[] | error issues = utilities:getAllIssues();
        if (issues is json[]) {
            response.statusCode = http:STATUS_OK;
            response.setJsonPayload(issues);
        } else {
            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
            response.setJsonPayload({"Message": "Internal server error"});
        }

        error? result = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-collaborators"
    }
    resource function getCollaborators(http:Caller caller, http:Request request) returns @untainted error? {

        http:Response response = new;
        string[] | error collaborators = utilities:getCollaborators();
        if (collaborators is string[]) {
            response.statusCode = http:STATUS_OK;
            response.setJsonPayload({"collaborators": collaborators});
        } else {
            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
            response.setJsonPayload({"Message": "Internal server error"});
        }

        error? result = caller->respond(response);
    }
}
