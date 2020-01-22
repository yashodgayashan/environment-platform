import ballerina/http;

//201 204 404 400
public function addCollaborator(string userName) returns int {

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    string url = "/repos/" + ORANIZATION_NAME + "/" + REPOSITORY_NAME + "/collaborators/" + userName;

    http:Response | error githubResponse = githubAPIEndpoint->put(url, request);
    if (githubResponse is http:Response) {
        return githubResponse.statusCode;
    } else {
        return http:STATUS_BAD_REQUEST;
    }
}

//204 404 400
public function removeCollaborator(string userName) returns int {

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    string url = "/repos/" + ORANIZATION_NAME + "/" + REPOSITORY_NAME + "/collaborators/" + userName;

    http:Response | error githubResponse = githubAPIEndpoint->delete(url, request);
    if (githubResponse is http:Response) {
        return githubResponse.statusCode;
    } else {
        return http:STATUS_BAD_REQUEST;
    }
}

public function getCollaborators() returns @untainted string[] | error {

    http:Request request = new;
    request.addHeader("Authorization", ACCESS_TOKEN);
    string url = "/repos/" + ORANIZATION_NAME + "/" + REPOSITORY_NAME + "/collaborators";
    http:Response | error githubResponse = githubAPIEndpoint->get(url, request);
    string[] names = [];
    if (githubResponse is http:Response) {
        var payload = githubResponse.getJsonPayload();
        if (payload is json) {
            json[] collaborators = <json[]>payload;
            foreach json collaborator in collaborators {
                names[names.length()] = <string>collaborator.login;
            }
            return names;
        } else {
            return error("Invalid payload type");
        }
    } else {
        return error("Internal server error");
    }
}
