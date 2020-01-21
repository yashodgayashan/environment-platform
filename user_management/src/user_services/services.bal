// import utilities;
import ballerina/http;
import yashodperera/utilities;
// import ballerina/lang.'int as ints;
// import ballerina/log;

http:Client githubAPIEndpoint = new (GITHUB_API_URL);

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
        path: "/post-request/{userName}"
    }
    resource function postRequest(http:Caller caller, http:Request request, string userName) returns @untainted error? {

        http:Response response = new;
        var payload = request.getJsonPayload();
        if (payload is json) {
            json title = check payload.issueTitle;
            json body = check payload.issueBody;
            int statusCode = utilities:createUserLabel(<@untainted>userName);
            if (statusCode == http:STATUS_CREATED || statusCode == STATUS_UNPROCESSIBLE) {
                int status = utilities:postIssue(<@untainted><string>title, <@untainted><string>body, <@untainted>userName);
                if (status == http:STATUS_CREATED) {
                    response.statusCode = http:STATUS_OK;
                    response.setJsonPayload({"Message": "Successfully added"});
                } else {
                    response.statusCode = http:STATUS_BAD_REQUEST;
                    response.setJsonPayload({"Message": "Issue with request title or description"});
                }
            } else {
                response.statusCode = http:STATUS_SERVICE_UNAVAILABLE;
                response.setJsonPayload({"Message": "Service unavailable"});
            }
        } else {
            response.statusCode = http:STATUS_BAD_REQUEST;
            response.setJsonPayload({"Message": "Invalid payload"});
        }
        error? result = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-requests/{userName}"
    }
    resource function getRequestRelatedToUser(http:Caller caller, http:Request request, string userName) returns @untainted error? {

        http:Response response = new;
        json[] | error issues = utilities:getUserIssues(userName);
        if (issues is json[]) {
            response.statusCode = http:STATUS_OK;
            response.setJsonPayload(issues);
        } else {
            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
            response.setJsonPayload({"Message": "Internal server error"});
        }
        error? result = caller->respond(response);
    }
}
