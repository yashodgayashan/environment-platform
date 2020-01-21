import ballerina/lang.'int as ints;

public function checkUser(json payload) returns error | [string, string, string, int, string, string] {
    json firstName = check payload.firstName;
    json lastName = check payload.lastName;
    json email = check payload.email;
    json phoneNumber = check payload.phoneNumber;
    json address = check payload.address;
    json password = check payload.password;
    return [<string>firstName, <string>lastName, <string>email,check ints:fromString(<string>phoneNumber), <string>address, <string>password];
}
