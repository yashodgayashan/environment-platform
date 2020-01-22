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

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/post-comment/{issueNumber}/{userName}"
    }
    resource function postComment(http:Caller caller, http:Request request, string issueNumber, string userName) returns @untainted error? {

        http:Response response = new;
        var payload = request.getJsonPayload();
        int statusCode = utilities:isValidLabel(<@untainted>userName,<@untainted >issueNumber);
        if (statusCode == http:STATUS_OK) {
            if (payload is json) {
                json body = check payload.body;
                int status = utilities:comment(<@untainted>issueNumber, <@untainted><string>body);
                if (status == http:STATUS_CREATED) {
                    response.statusCode = http:STATUS_OK;
                    response.setJsonPayload({"Message": "Successfully added"});
                } else {
                    response.statusCode = http:STATUS_BAD_REQUEST;
                    response.setJsonPayload({"Message": "Issue is not available"});
                }
            } else {
                response.statusCode = http:STATUS_BAD_REQUEST;
                response.setJsonPayload({"Message": "Invalid payload"});
            }
        } else {
            response.statusCode = http:STATUS_BAD_REQUEST;
            response.setJsonPayload({"Message": "Invalid user"});
        }
        error? result = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-comments/{issueNumber}/{userName}"
    }
    resource function getComments(http:Caller caller, http:Request request, string issueNumber, string userName) returns @untainted error? {

        http:Response response = new;
        var payload = request.getJsonPayload();
        int statusCode = utilities:isValidLabel(<@untainted>userName, <@untainted >issueNumber);
        if (statusCode == http:STATUS_OK) {
                json[] | error status = utilities:getComments(<@untainted >issueNumber);
                if (status is json[]) {
                    response.statusCode = http:STATUS_OK;
                    response.setJsonPayload(status);
                } else {
                    response.statusCode = http:STATUS_BAD_REQUEST;
                    response.setJsonPayload({"Message": status.reason()});
                }
        } else {
            response.statusCode = http:STATUS_BAD_REQUEST;
            response.setJsonPayload({"Message": "Invalid user"});
        }
        error? result = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["PATCH"],
        path: "/edit-comments/{userName}/{commentId}"
    }
    resource function editComment(http:Caller caller, http:Request request, string userName, string commentId) returns @untainted error? {

        http:Response response = new;
        var payload = request.getJsonPayload();
        int statusCode = utilities:isCommentOwner(<@untainted > commentId, <@untainted >userName);
        if (payload is json){
            if (statusCode == http:STATUS_OK) {
                json body =check  payload.body;
                int status = utilities:editComments(<@untainted >commentId,<@untainted ><string>body);
                if (status == http:STATUS_OK){
                    response.statusCode = http:STATUS_OK;
                     response.setJsonPayload({"Message": "Successfully added"});
                } else {   
                    response.statusCode = http:STATUS_BAD_REQUEST;
                    response.setJsonPayload({"Message": "Comment is not available"});
                }
        } else {
            response.statusCode = http:STATUS_BAD_REQUEST;
            response.setJsonPayload({"Message": "Invalid user"});
        }
         } else {
                response.statusCode = http:STATUS_BAD_REQUEST;
                response.setJsonPayload({"Message": "Invalid payload"});
            }
        error? result = caller->respond(response);
    }
}
