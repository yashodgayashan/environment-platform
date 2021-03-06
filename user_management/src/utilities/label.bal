import ballerina/http;

http:Client githubAPIEndpoint = new (GITHUB_API_URL);

//422, 201 , 404
public function createUserLabel(string userName) returns int {

    return createLabel(userName, "userName");
}

public function createLabel(string topic, string description) returns int {

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    request.setJsonPayload({
        "name": topic,
        "description": description,
        "color": "f29513"
    });
    string url = "/repos/" + ORANIZATION_NAME + "/" + REPOSITORY_NAME + "/labels";

    http:Response | error githubResponse = githubAPIEndpoint->post(url, request);
    if (githubResponse is http:Response) {
        return githubResponse.statusCode;
    } else {
        return http:STATUS_BAD_REQUEST;
    }
}

public function isValidLabel(string name, string issueNumber) returns int {

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    string url = "/repos/" + ORANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber + "/labels";
    http:Response | error githubResponse = githubAPIEndpoint->get(url, request);
    if (githubResponse is http:Response) {
        var payload = githubResponse.getJsonPayload();
        if (payload is json) {
            json[] labels = <json[]>payload;
            foreach json label in labels {
                if (name == label.name) {
                    return http:STATUS_OK;
                }
            }
            return http:STATUS_NOT_FOUND;
        } else {
            return http:STATUS_SERVICE_UNAVAILABLE;
        }
    } else {
        return http:STATUS_BAD_REQUEST;
    }
}

public function getLables() returns @untainted json[] | error {

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    string url = "/repos/" + ORANIZATION_NAME + "/" + REPOSITORY_NAME + "/labels";
    http:Response | error githubResponse = githubAPIEndpoint->get(url, request);

    json[] out = [];
    if (githubResponse is http:Response) {
        var payload = githubResponse.getJsonPayload();
        if (payload is json) {
            json[] labels = <json[]>payload;
            foreach json label in labels {
                out[out.length()] = {"id":check label.id, "name":check label.name, "description":check label.description};
            }
            return out;
        } else {
            return error("Invalid payload");
        }
    } else {
        return error("Internal server error");
    }
}

public function assignLabel(string issueNumber, string label) returns int {

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    request.setJsonPayload({
        "labels": [label]
    });
    string url = "/repos/" + ORANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber + "/labels";
    http:Response | error githubResponse = githubAPIEndpoint->post(url, request);
    if (githubResponse is http:Response) {
        return githubResponse.statusCode;
    } else {
        return http:STATUS_BAD_REQUEST;
    }
}

public function removeLabel(string issueNumber, string labelName) returns int {

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    string url = "/repos/" + ORANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber + "/labels/" + labelName;
    http:Response | error githubResponse = githubAPIEndpoint->delete(url, request);
    if (githubResponse is http:Response) {
        return githubResponse.statusCode;
    } else {
        return http:STATUS_BAD_REQUEST;
    }
}
