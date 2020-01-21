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
