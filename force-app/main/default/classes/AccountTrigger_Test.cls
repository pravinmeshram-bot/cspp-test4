@isTest
public class AccountTrigger_Test implements HttpCalloutMock {
    
    static testMethod void TestUpdateFolderName_Success() {
        
        Id clientRecordTypeId;
        Map<String, Schema.RecordTypeInfo> accountRecordTypeMap = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
        
        if (accountRecordTypeMap.containsKey('Client')) {
                
           clientRecordTypeId = accountRecordTypeMap.get('Client').getRecordTypeId();
           system.debug('<<$$>>'+accountRecordTypeMap);          
           
        }
        
        Box_settings__c boxSettings = TestRecordCreator.createBoxsettings();
        boxSettings.Folder_Endpoint__c = 'https://api.box.com/2.0/folders';
        insert boxSettings;
        
        Account accStr = TestRecordCreator.createAccount('Client', clientRecordTypeId);
        accStr.BoxFolderId__c = '111222';      
         accStr.nu_dse__Work_Phone__c = '(646) 584-3653';
       accStr.nu_dse__Other_Phone__c = '(646) 584-3653';
        Document document = new Document();	

        document.Body = Blob.valueOf('privatekey=MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQClEuBJBf6ZpoZJraAy9/PICyWakegZXolGGn/ylzCyAbrj/B+2Gfssjh1cXvttI4yHGIk0Gx17goKg5H20gArMpd8Z1eCQiHx8oCLMx0es9GDaV11tTlekU+SvkXTSoNQc77EY7cqTTQsHliXs/LcqdQ7QHrqsmvnTdYDbThfjZ8ajqFvZILPeEE5okZY7VJXXDGF+i4IGvhFVmAefDElMnzP7SWpnvajKI+JfvbukrdnAG6EmIufABdlRdu9fYLsegbFA6E4TYCRjZmfcbXDlQCxwSvMn+fHR2qGbA8NgLnlVytaOcc9O1vc8Oh0xfPAmrcta5BLdMwspYpi6xEnNAgMBAAECggEAeBK18IgavTtDHR7dk5WGzzFEhh2x3ZpFcifef+B3/FOD1UhU7MoTSUKKmuFANBASrUYsryk2FdxGFrB9u6kTse7JzOolMh0FqEV3asteGLGeLdQ00kiVOaQIiajdeESiZfX4NTDrFKCK8FbIeY0N0yVYxAxGLz1/kdA8DcnNWIy99cuBDfndQnHEJpnMJ+PDhlWExc6ztGLiYUuvDfOR8Th5WDw40GN2XpYBdkS/9L2kv2Hj0NOk9qRnjkXf32O8xzQkujNhGpP3y+hEp61t4b3N4N6qBOq+ZJW6wemW0Zk7rZozRgYJ/8Y/ichrAycWItjpWDeiMd5Fxb4xRYf/JQKBgQDRNl4HPqoqi30h68Ro22NwQsPKidopKR/HrHMldAS19OL/krOYGFIaENLLftUmocHXYbk5xD7rin/gN8J1WiyQ0vDLbLyS7+GYxbZiLCRtRI6GWDzrt97SiFwDni82E8Iii0U53nXUpab90cv5Cj35hGaJrGUQBMp9xISrbRVxOwKBgQDJ/YZEdqkmE0hDMiQDhCXc/ZH/ubyfJk4tXq5tUNZf+RsN8vtCAuInK9Pfn6pg5v0UDAvEK1EUqyTAPjr59mffl2oPr+v6/WdNKBIGNxYG7I9CraR9ghIB5mCTIZDIPt0CK1dB9ovYWMCJa9kjE4KZSluu/Xr0VoCPDEU/l3OAlwKBgQCiwiIKjtTBfn0d65aEYNEOX9KD+hSv2t9vbpix9X1ItTf3zgBL/fe5cYccaxKWGFd+IPeBmku84KW1IIv20e1Dyecsyu41fctLF91YqLC6FRCwMWtLkmMV9KFo6yIdduecCi8T4x5WDX1Jj3KYz0ABouBGkMia2q9RgpYX6yg4SwKBgQCsXYjXIX8kO64dkUsEKR96XnPZCjF4ieKKetJT/HiDO3qnw6I/aWB9Vrwdhw2IVXS/R6w+wUwWXBknZ7NCHM/1ECt0qYWxD864G6qN3TIRxIpXtv+4Dme5cVMWGr2G84X7VOrIIlCh1NKwMfUAJqT6lGZ6hFoI6UwZRbpOErqAjwKBgHiHBgUJXD/u7387yudJ+mzN7A/XSpx7zWdvUElzYyxhCbxsvSSLxsOrFO4pXB640/LAzbLsaMMx+B1+7tNBlUol9/3zv2xHGerGK5I82QNnx/vV3QbY7W1o/Q942LpUhlNd066tS3vZwOPPGW8BKqWncLoL1U2p45R00kcW0m2j enterpriseId= 12928606 publicKeyId=hmn7yfll clientId=bavh341hkej16rw7424nmkidvwc0i6ks clientSecret=rd0Sl7kuSZvd9BrRvCGPfQaBz0CruNvo');
        document.IsPublic = true;
        document.Name = 'Box_Cred';
        document.FolderId = userInfo.getUserId();
        insert document;
        
        Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new AccountTrigger_Test());
            insert accStr;
            List<Account> accList1 = [SELECT Id,RecordType.Name,RecordTypeId FROM Account WHERE Id =:accStr.Id ];
           System.debug('<<--**-->>'+accList1[0].RecordType.Name);
           System.debug('--*()*--'+accList1[0].RecordTypeId);
            
        Test.stopTest();  
        List<Account> accList = [SELECT Id, BoxFolderId__c FROM Account WHERE Id =:accStr.Id ];
        System.assertEquals('111222', accList[0].BoxFolderId__c);   
    }
    
       
  /* This logic is commented because this is no more requried and 
     all the folder creation for accounts are handledd through batch class
     static testMethod void TestCreateAccountFolder() {
        
        Id clientRecordTypeId;
        Map<String, Schema.RecordTypeInfo> accountRecordTypeMap = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
        if (accountRecordTypeMap.containsKey('Client')) {
           clientRecordTypeId = accountRecordTypeMap.get('Client').getRecordTypeId();
        }
        
        List<Box_settings__c> boxSettingList = new List<Box_settings__c>();
        Box_settings__c boxSettings1 = TestRecordCreator.createBoxsettings();
        boxSettings1.Folder_Endpoint__c = 'https://api.box.com/2.0/folders';
        boxSettingList.add(boxSettings1);
        
        Box_settings__c boxSettings2 = TestRecordCreator.createBoxsettings();
        boxSettings2.Folder_Endpoint__c = 'https://api.box.com/2.0/folders';
        boxSettings2.name = 'FolderUpdate';
        boxSettings2.RootFolderId__c = '47510948398';
        boxSettingList.add(boxSettings2);
        
        insert boxSettingList;
        
        Account accStr = TestRecordCreator.createAccount('Client', clientRecordTypeId);
        accStr.BoxFolderId__c = '';     
        accStr.Attorney__c = True; 
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AccountTrigger_Test());
            insert accStr;
            System.enqueuejob(new  CreateParentAndSubFoldersInBox(new List<Account> {accStr}));
            
        Test.stopTest();  
    }*/
    
    static testMethod void TestUpdateFolderName_Failure() {
        
        Id clientRecordTypeId;
        Map<String, Schema.RecordTypeInfo> accountRecordTypeMap = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
        if (accountRecordTypeMap.containsKey('Client')) {
                
           clientRecordTypeId = accountRecordTypeMap.get('Client').getRecordTypeId();
        }
        
        Box_settings__c boxSettings = TestRecordCreator.createBoxsettings();
        boxSettings.Folder_Endpoint__c = 'https://api.box.com/2.2/folders';
        insert boxSettings;
        
        Account accStr = TestRecordCreator.createAccount('Client', clientRecordTypeId);
        accStr.BoxFolderId__c = '111222';
        accStr.nu_dse__Work_Phone__c = '1111111111';
      accStr.nu_dse__Other_Phone__c = '2222222222';
        accStr.PersonMobilePhone = '3333333333';
        accStr.nu_dse__Home_Phone__c = '4444444444';
        accStr.Phone = '5555555555';
        Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new AccountTrigger_Test());
            insert accStr;
            
        Test.stopTest(); 
        List<nu_dse__Error_Log__c> errorList = [SELECT Id, nu_dse__Message__c FROM nu_dse__Error_Log__c where nu_dse__Error_Causing_Record_Id__c = :accStr.Id ];
        System.assertEquals(True, errorList.isEmpty());   
    }
    
    @isTest static void testProspect() {
        
        List<nu_dse__Prospect__c> newProspect = new List<nu_dse__Prospect__c>();
        nu_dse__Prospect__c proIns = new nu_dse__Prospect__c();
        proIns.nu_dse__First_Name__c = 'Test1';
        proIns.nu_dse__Last_name__c = 'test';
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
    
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        
        if (req.getEndpoint().contains('/api.box.com/2.0/folders')) {
        
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setStatus('OK');
        } else if (req.getEndpoint().contains('/api.box.com/2.2/folders')) {
            
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(409);
            res.setBody('{"type":"error","status":409,"code":"item_name_in_use","message":"Item with the same name already exists"}');
            res.setStatus('Conflict');
        }
        return res;
    }
  
}