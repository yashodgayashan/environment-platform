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

