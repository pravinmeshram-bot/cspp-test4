@isTest
public class RESTLimitResource_Test implements HttpCalloutMock {

    @isTest
    public static void testRESTLimitResource() {
        
        PageReference pageRef = Page.OrgLimits;
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new RESTLimitResource_Test());
        String output = RESTLimitResource.JSONtext;
        System.assertEquals(output, null);
        output = 'Testing a string';
        RESTLimitResource.JSONtext = output;
        output = RESTLimitResource.JSONtext;
        System.assertEquals(output, 'Testing a string');
        HttpResponse res = RESTLimitResource.getLimitsResp();
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        
        System.assertEquals(200, res.getStatusCode());
        
        RESTLimitResource restLimitResourceInst = new RESTLimitResource();
        RESTLimitResource.limitExceeded();
        
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year(); 
        system.schedule('Test ScheduledBatchClass', CRON_EXP, new Schedule_OrgLimits());
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        
        List<ApexClass> apiVersionFromApexClass = [SELECT ApiVersion, Name FROM ApexClass WHERE Name = 'RESTLimitResource'];
        
        System.assertEquals(System.URL.getSalesforceBaseURL().toExternalForm() +'/services/data/v'+apiVersionFromApexClass[0].ApiVersion+'/limits', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"ConcurrentAsyncGetReportInstances":{"Max":200,"Remaining":1},"ConcurrentSyncReportRuns":{"Max":20,"Remaining":1},'+
                    '"DailyAnalyticsDataflowJobExecutions":{"Max":50,"Remaining":1},"DailyApiRequests":{"Max":527000,"Remaining":1},'+
                    '"DailyAsyncApexExecutions":{"Max":250000,"Remaining":1},"DailyBulkApiRequests":{"Max":10000,"Remaining":2},'+
                    '"DailyDurableGenericStreamingApiEvents":{"Max":200000,"Remaining":2},"DailyDurableStreamingApiEvents":{"Max":200000,"Remaining":1},'+
                    '"DailyGenericStreamingApiEvents":{"Max":10000,"Remaining":1},"DailyStandardVolumePlatformEvents":{"Max":25000,"Remaining":1},'+
                    '"DailyStreamingApiEvents":{"Max":200000,"Remaining":1},"DailyWorkflowEmails":{"Max":533000,"Remaining":1},"DataStorageMB":{"Max":100240,"Remaining":1},'+
                    '"DurableStreamingApiConcurrentClients":{"Max":1000,"Remaining":1},"FileStorageMB":{"Max":1110016,"Remaining":1},'+
                    '"HourlyAsyncReportRuns":{"Max":1200,"Remaining":1},"HourlyDashboardRefreshes":{"Max":200,"Remaining":1},"HourlyDashboardResults":{"Max":5000,"Remaining":1},'+
                    '"HourlyDashboardStatuses":{"Max":999999999,"Remaining":1},"HourlyLongTermIdMapping":{"Max":100000,"Remaining":1},'+
                    '"HourlyODataCallout":{"Max":20000,"Remaining":1},"HourlyShortTermIdMapping":{"Max":100000,"Remaining":1},"HourlySyncReportRuns":{"Max":500,"Remaining":1},'+
                    '"HourlyTimeBasedWorkflow":{"Max":50,"Remaining":1},"MassEmail":{"Max":5000,"Remaining":1},"MonthlyPlatformEvents":{"Max":750000,"Remaining":1},'+
                    '"Package2VersionCreates":{"Max":6,"Remaining":1},"PermissionSets":{"Max":1500,"Remaining":1,"CreateCustom":{"Max":1000,"Remaining":1}},'+
                    '"SingleEmail":{"Max":5000,"Remaining":1},"StreamingApiConcurrentClients":{"Max":1000,"Remaining":1}}');
        res.setStatusCode(200);
        return res;
    }
}