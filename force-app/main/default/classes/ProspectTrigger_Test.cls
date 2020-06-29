@isTest
public class ProspectTrigger_Test implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
         // Create a fake response
        System.debug('::req::'+req);   
        String response;
        
        if (req.getEndpoint() == 'https://api.box.com/2.0/folders') {
        
            response = '{"type":"folder","id":"40414357179","sequence_id":"0","etag":"0","name":"Lead-0153-Test- 23","';
            response += 'created_at":"2017-10-13T00:47:34-07:00","modified_at":"2017-10-13T00:47:34-07:00","description":"",';
            response += '"size":0,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,';
            response += '"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"2755389993","name":"StrategicApp",';
            response += '"login":"AutomationUser_330074_vlD4SwfqgB@boxdevedition.com"},"modified_by":{"type":"user",';
            response += '"id":"2755389993","name":"StrategicApp","login":"AutomationUser_330074_vlD4SwfqgB@boxdevedition.com"},';
            response += '"trashed_at":null,"purged_at":null,"content_created_at":"2017-10-13T00:47:34-07:00","content_modified_at":';
            response += '"2017-10-13T00:47:34-07:00","owned_by":{"type":"user","id":"2755389993","name":"StrategicApp","login":';
            response += '"AutomationUser_330074_vlD4SwfqgB@boxdevedition.com"},"shared_link":null,"folder_upload_email":null,';
            response += '"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},"item_status":';
            response += '"active","item_collection":{"total_count":0,"entries":[],"offset":0,"limit":100,"order":[{"by":"type",';
            response += '"direction":"ASC"},{"by":"name","direction":"ASC"}]}}'; 
        } else {
        
            response = '{"access_token":"SBI5y9vqwn13m9cFCo0YbYms0uIhANNA","expires_in":3603,"restricted_to":[],"token_type":"bearer"}';
        }
        HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(response);
            res.setStatus('OK');
            res.setStatusCode(201);    
        return res;
    }
    
    @isTest static void testProspect() {
        
        Portfolio__c pp = new Portfolio__c();
        pp.name='TestPortfolio';
        pp.boxfolderid__c = '12312312312';
        insert pp;
        
        List<nu_dse__Prospect__c> newProspect = new List<nu_dse__Prospect__c>();
        nu_dse__Prospect__c proIns = new nu_dse__Prospect__c();
        proIns.nu_dse__First_Name__c = 'Test1';
        proIns.nu_dse__Last_name__c = 'test';
        proIns.portfolio__c = pp.id;
        newProspect.add(proIns);
        
        Box_settings__c box1 = new Box_settings__c(name = 'box', Folder_Endpoint__c = 'https://api.box.com/2.0/folders', Client_id__c = 'bavh341hkej16rw7424nmkidvwc0i6ks', Client_Secret__c = 'rd0Sl7kuSZvd9BrRvCGPfQaBz0CruNvo', access_token__c = '1aMun9nbCuKEryECskLX4Bp8nDX2fwcy', Refresh_Token__c = 'jx5QziOZ6DMY8QzXYIvtiYORO78Q4ZljAp6T0gt4v5t0fYS50XCdlBehb5deUW1F', expires__c = '4077', lastRefresh__c = '1507031579432');
        insert box1;
        
        Document document = new Document();

        document.Body = Blob.valueOf('privatekey=MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQClEuBJBf6ZpoZJraAy9/PICyWakegZXolGGn/ylzCyAbrj/B+2Gfssjh1cXvttI4yHGIk0Gx17goKg5H20gArMpd8Z1eCQiHx8oCLMx0es9GDaV11tTlekU+SvkXTSoNQc77EY7cqTTQsHliXs/LcqdQ7QHrqsmvnTdYDbThfjZ8ajqFvZILPeEE5okZY7VJXXDGF+i4IGvhFVmAefDElMnzP7SWpnvajKI+JfvbukrdnAG6EmIufABdlRdu9fYLsegbFA6E4TYCRjZmfcbXDlQCxwSvMn+fHR2qGbA8NgLnlVytaOcc9O1vc8Oh0xfPAmrcta5BLdMwspYpi6xEnNAgMBAAECggEAeBK18IgavTtDHR7dk5WGzzFEhh2x3ZpFcifef+B3/FOD1UhU7MoTSUKKmuFANBASrUYsryk2FdxGFrB9u6kTse7JzOolMh0FqEV3asteGLGeLdQ00kiVOaQIiajdeESiZfX4NTDrFKCK8FbIeY0N0yVYxAxGLz1/kdA8DcnNWIy99cuBDfndQnHEJpnMJ+PDhlWExc6ztGLiYUuvDfOR8Th5WDw40GN2XpYBdkS/9L2kv2Hj0NOk9qRnjkXf32O8xzQkujNhGpP3y+hEp61t4b3N4N6qBOq+ZJW6wemW0Zk7rZozRgYJ/8Y/ichrAycWItjpWDeiMd5Fxb4xRYf/JQKBgQDRNl4HPqoqi30h68Ro22NwQsPKidopKR/HrHMldAS19OL/krOYGFIaENLLftUmocHXYbk5xD7rin/gN8J1WiyQ0vDLbLyS7+GYxbZiLCRtRI6GWDzrt97SiFwDni82E8Iii0U53nXUpab90cv5Cj35hGaJrGUQBMp9xISrbRVxOwKBgQDJ/YZEdqkmE0hDMiQDhCXc/ZH/ubyfJk4tXq5tUNZf+RsN8vtCAuInK9Pfn6pg5v0UDAvEK1EUqyTAPjr59mffl2oPr+v6/WdNKBIGNxYG7I9CraR9ghIB5mCTIZDIPt0CK1dB9ovYWMCJa9kjE4KZSluu/Xr0VoCPDEU/l3OAlwKBgQCiwiIKjtTBfn0d65aEYNEOX9KD+hSv2t9vbpix9X1ItTf3zgBL/fe5cYccaxKWGFd+IPeBmku84KW1IIv20e1Dyecsyu41fctLF91YqLC6FRCwMWtLkmMV9KFo6yIdduecCi8T4x5WDX1Jj3KYz0ABouBGkMia2q9RgpYX6yg4SwKBgQCsXYjXIX8kO64dkUsEKR96XnPZCjF4ieKKetJT/HiDO3qnw6I/aWB9Vrwdhw2IVXS/R6w+wUwWXBknZ7NCHM/1ECt0qYWxD864G6qN3TIRxIpXtv+4Dme5cVMWGr2G84X7VOrIIlCh1NKwMfUAJqT6lGZ6hFoI6UwZRbpOErqAjwKBgHiHBgUJXD/u7387yudJ+mzN7A/XSpx7zWdvUElzYyxhCbxsvSSLxsOrFO4pXB640/LAzbLsaMMx+B1+7tNBlUol9/3zv2xHGerGK5I82QNnx/vV3QbY7W1o/Q942LpUhlNd066tS3vZwOPPGW8BKqWncLoL1U2p45R00kcW0m2j enterpriseId= 12928606 publicKeyId=hmn7yfll clientId=bavh341hkej16rw7424nmkidvwc0i6ks clientSecret=rd0Sl7kuSZvd9BrRvCGPfQaBz0CruNvo');
        document.IsPublic = true;
        document.Name = 'Box_Cred';
        document.FolderId = userInfo.getUserId();
        insert document;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ProspectTrigger_Test());
            insert newProspect; 
        Test.stopTest();
        
        List<nu_dse__Prospect__c> newPro = [SELECT Id, BoxFolderId__c FROM nu_dse__Prospect__c WHERE nu_dse__First_Name__c  = 'Test1'];
        //System.assertEquals('40414357179', newPro[0].BoxFolderId__c);
    }  
    
}