import ballerina/http;
import ballerina/io;

public function postIssue(string issueTitle, string issueBody, string userName) returns int {

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    request.setJsonPayload({
        "title": issueTitle,
        "body": issueBody,
        "labels": [userName]
    });
    string url = "/repos/" + ORANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues";
    http:Response | error githubResponse = githubAPIEndpoint->post(url, request);
    if (githubResponse is http:Response) {
        return githubResponse.statusCode;
    } else {
        return http:STATUS_BAD_REQUEST;
    }
}

public function getUserIssues(string userName) returns @untainted json[] | error {

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);

    string url = "/repos/" + ORANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues";
    http:Response | error githubResponse = githubAPIEndpoint->get(url, request);
    json[] out = [];
    string state = "";
    boolean hasState = false;
    if (githubResponse is http:Response) {
        var jsonpayload = githubResponse.getJsonPayload();
        if (jsonpayload is json) {
            json[] issues = <json[]>jsonpayload;
            foreach json issue in issues {
                json[] labels = <json[]>issue.labels;
                foreach json label in labels {
                    if (label.name == userName) {
                        foreach json labelName in labels {
                            if (labelName.description == "state") {
                                state = <string>labelName.name;
                                hasState = true;
                            }
                        }
                        if (hasState) {
                            out[out.length()] = {"requsetTitle":check issue.title, "requestNumber":check issue.number, "requestDetails":check issue.body, "state": state};
                        } else {
                            out[out.length()] = {"requsetTitle":check issue.title, "requestNumber":check issue.number, "requestDetails":check issue.body, "state": "Pending"};
                        }
                        hasState = false;
                    }
                }
            }
            return out;
        } else {
            return error("The invalid payload received");
        }
    } else {
        return githubResponse;
    }
}

public function getAllIssues() returns @untainted json[] | error {

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);

    string url = "/repos/" + ORANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues";
    http:Response | error githubResponse = githubAPIEndpoint->get(url, request);
    json[] out = [];
    if (githubResponse is http:Response) {
        var jsonpayload = githubResponse.getJsonPayload();
        if (jsonpayload is json) {
            json[] issues = <json[]>jsonpayload;
            string userName = "";
            string status = "";
            json[] labelArray = [];
            string[] assigneeArray = [];
            foreach json issue in issues {
                json[] labels = <json[]>issue.labels;
                foreach json label in labels {
                    if (label.description == "userName") {
                        userName = <string>label.name;
                    } else if (label.description == "status") {
                        status = <string>label.name;
                    } else {
                        labelArray[labelArray.length()] = {"name":check label.name, "body":check label.description};
                    }
                }
                json[] assignees = <json[]>issue.assignees;
                foreach json assignee in assignees {
                    assigneeArray[assigneeArray.length()] = <string>assignee.login;
                }
                json test = {"requsetNumber":check issue.number, "requestTitle":check issue.title, "requestBody":check issue.body, "owner": userName, "status": status, "tags": labelArray, "assignees": assigneeArray};
                userName = "";
                status = "";
                labelArray = [];
                assigneeArray = [];
                out[out.length()] = test;
            }
            return out;
        } else {
            return error("The invalid payload received");
        }
    } else {
        return githubResponse;
    }
}

public function main() {
    string[] | error ret = getCollaborators();
    io:println(ret);
}
