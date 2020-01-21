import ballerina/http;

public function comment(string issueNumber, string comment) returns int {

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    request.setJsonPayload({
        "body": comment
    });
    string url = "/repos/" + ORANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber + "/comments";
    http:Response | error githubResponse = githubAPIEndpoint->post(url, request);
    if (githubResponse is http:Response) {
        return githubResponse.statusCode;
    } else {
        return http:STATUS_BAD_REQUEST;
    }
}

public function getComments(string issueNumber) returns @untainted json[] | error {

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    string url = "/repos/" + ORANIZATION_NAME + "/" + REPOSITORY_NAME + "/issues/" + issueNumber + "/comments";
    http:Response | error githubResponse = githubAPIEndpoint->get(url, request);

    json[] out = [];
    if (githubResponse is http:Response) {
        var payload = githubResponse.getJsonPayload();
        if (payload is json) {
            json[] comments = <json[]>payload;
            foreach json comment in comments {
                map<json> user = <map<json>>comment.user;
                out[out.length()] = {"commentId":check comment.id, "user":check user.login, "comment":check comment.body};
            }
            return out;
        } else {
            return error("The error with response payload");
        }
    } else {
        return githubResponse;
    }
}
