import ballerina/http;
import ballerina/io;

http:Client githubAPIEndpoint = new (GITHUB_API_URL);

public function createUserLabel(string userName) returns int {

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    request.setJsonPayload({
        "name": userName,
        "description": "userName",
        "color": "f29513"
    });
    string url = "/repos/" + ORANIZATION_NAME + "/" + REPOSITORY_NAME + "/labels";

    http:Response | error githubResponse = githubAPIEndpoint->post(url, request);
    if (githubResponse is http:Response) {
        io:println(githubResponse.statusCode);
    } else {
        io:println(githubResponse);
    }
    return 1;
}

public function main() {
    int one = createUserLabel("yashod");
}
