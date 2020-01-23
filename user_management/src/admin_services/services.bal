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

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/create-labels"
    }
    resource function createLabel(http:Caller caller, http:Request request) returns @untainted error? {

        http:Response response = new;
        var payload = request.getJsonPayload();
        if (payload is json) {
            json title = check payload.title;
            json body = check payload.body;
            int status = utilities:createLabel(<@utilities><string>title, <@utilities><string>body);
            response.statusCode = status;
        } else {
            response.statusCode = 404;
        }
        error? result = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-labels"
    }
    resource function getLabels(http:Caller caller, http:Request request) returns @untainted error? {

        http:Response response = new;
        json[] | error labels = utilities:getLables();
        if (labels is json[]) {
            response.setJsonPayload(labels);
        } else {
            response.statusCode = 404;
        }
        error? result = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/assign-label/{issueNumber}/{label}"
    }
    resource function assignLabel(http:Caller caller, http:Request request, string label, string issueNumber) returns @untainted error? {

        http:Response response = new;
        int status = utilities:assignLabel(<@untainted>issueNumber, <@untainted>label);
        response.statusCode = status;
        error? result = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/delete-label/{issueNumber}/{label}"
    }
    resource function deleteLabel(http:Caller caller, http:Request request, string label, string issueNumber) returns @untainted error? {

        http:Response response = new;
        int status = utilities:removeLabel(<@untainted>issueNumber, <@untainted>label);
        response.statusCode = status;
        error? result = caller->respond(response);
    }
}
