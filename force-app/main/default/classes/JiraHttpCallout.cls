public class JiraHttpCallout {

//Pass in the endpoint to be used using the string url
  public String getCalloutResponseContents(String url) {

    //Instantiate a new http object
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint('https://stratfs.atlassian.net/rest/api/3/version/10155');
    request.setMethod('GET');
    //request.setHeader('Authorization', 'Bearer ' + access_token);
    request.setHeader('Authorization', 'Basic YWJoYW5kYXJpQHN0cmF0ZnMuY29tOm9ZbGtUemNnYWx5eWZ5bEZCVUw5OUE0Qw==');
    HttpResponse response = http.send(request);
    
    return response.getBody();


    /*if (response.getStatusCode() == 200) {
        // Deserialize the JSON string into collections of primitive data types.
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> Variables = (List<Object>) results.get('Variables');
        for (Object Variable: Variables) {
        System.debug(Variable);
        }
    } */
      
  } 
}