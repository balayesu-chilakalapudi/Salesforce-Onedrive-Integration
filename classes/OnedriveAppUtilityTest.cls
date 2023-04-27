@isTest
public class OnedriveAppUtilityTest {
	@testsetup
    static void testdata(){
        List<Onedrive__c> odlist=new List<Onedrive__c>();
        Onedrive__c od=new Onedrive__c();
        od.name=userinfo.getUserId();
        od.client_id__c='test';
        od.client_secret__c='test';
        od.LHGlobalAPI_Folder_Id__c='test';
        od.redirect_uri__c='https://test.com';
        od.code__c='483833';
        od.access_token_part1__c='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestte';
        od.access_token_part2__c='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestte';
        od.access_token_part3__c='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestte';
        od.access_token_part4__c='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestte';
        od.access_token_part5__c='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestte';
        od.access_token_part6__c='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestte';
        od.access_token_part7__c='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestte';
        od.access_token_part8__c='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestte';
        od.access_token_part9__c='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestte';
        od.access_token_part10__c='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestte';
        od.access_token_part11__c='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestte';
        od.access_token_part12__c='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestte';
        od.refresh_token_part1__c='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestte';
        od.refresh_token_part2__c='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestte';
        od.refresh_token_part3__c='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestte';
        od.refresh_token_part4__c='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestte';
		od.onedrive_username__c='test@test.com';
        odlist.add(od);         
        Onedrive__c od2=new Onedrive__c();
        od2.name='OneDriveTokens';
        od2.client_id__c='test';
        od2.client_secret__c='test';
        od2.LHGlobalAPI_Folder_Id__c='test';
        od2.redirect_uri__c='https://test.com';
        od2.code__c='483833';
        od2.access_token_part1__c='test1';
        od2.access_token_part2__c='test2';
        od2.access_token_part3__c='test3';
        od2.access_token_part4__c='test4';
        od2.access_token_part5__c='test5';
        od2.onedrive_username__c='test@test.com';
        odlist.add(od2);
        insert odlist;
        account acc=new account();
        acc.name='test';
        insert acc;
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
    }
    public class OnedriveMockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
       public  HTTPResponse respond(HTTPRequest req) {      
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"uploadUrl":"https://test.com","value":[{"id":"test","name":"test","size":443,"webUrl":"test","lastmodifiedDateTime":"test","createdDateTime":"test"}],"access_token":"testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest","start":0,"count":235,"data":[{"id":84,"firstName":"D","lastName":"Xie","email":null,"phone":null,"address":{"address1":null,"address2":null,"city":null,"state":null,"zip":null,"countryID":1,"countryName":"United States","countryCode":"US"},"lead":{"id":23},"owner":{"id":1,"firstname":"abc","lastname":"test"},"clientCorporation":{"id":1,"name":"test"}}]}');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }     
    }
	@isTest
    static void test1(){       
        String p_userId=userinfo.getUserId(); 
        Account acc=new Account();
        acc.name='TEST';
        insert acc;
        String p_recordId=acc.Id;        
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new OnedriveMockHttpResponseGenerator());
			OnedriveAppUtility.shareParentWithAll(p_userId);
        Test.stopTest();
    }
    @isTest
    static void test2(){       
        String p_userId=userinfo.getUserId(); 
        Account acc=new Account();
        acc.name='TEST';
        insert acc;
        String p_recordId=acc.Id;        
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new OnedriveMockHttpResponseGenerator());
        OnedriveAppUtility.getFolderName(p_recordId);
			OnedriveAppUtility.addOnedriveFolder('test','test','test',p_recordId);
        Test.stopTest();
    }
    @isTest
    static void test3(){       
        String p_userId=userinfo.getUserId(); 
        Account acc=new Account();
        acc.name='TEST';
        insert acc;
        String p_recordId=acc.Id;        
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new OnedriveMockHttpResponseGenerator());
			OnedriveAppUtility.listFiles('test','test');
        Test.stopTest();
    }
     @isTest
    static void test4(){
        account acc=[select id from account limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OnedriveMockHttpResponseGenerator());
         Map<String,String> uploadmap=new map<String,String>();
        String docId=[select contentdocumentId from contentversion limit 1].contentdocumentId;
        uploadmap.put('documentId',docId);      
        
        String uploads=JSON.serialize(new List<Map<String,String>>{uploadmap});
        
       
        Blob p_data=Blob.valueOf('test');
        Onedrive__c od=Onedrive__c.getValues(userinfo.getUserId());
        String odstr=JSON.serialize(od);
       OnedriveAppUtility.saveToOneDrive('test', p_data, acc.Id, 'test', 'test', odstr);
         OnedriveAppUtility.saveUploads(acc.Id, uploads); 
        Test.stopTest();
    }
    @isTest
    static void test5(){       
        String p_userId=userinfo.getUserId(); 
        Account acc=new Account();
        acc.name='TEST';
        insert acc;
        String p_recordId=acc.Id;        
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new OnedriveMockHttpResponseGenerator());
        OnedriveFolder__c p_odf=new OnedriveFolder__c();
        Onedrive__c p_od=onedrive__c.getValues(userinfo.getUserId());
			OnedriveAppUtility.removeAllPermissions(p_odf, p_od);
        Test.stopTest();
    }
    @isTest
    static void test6(){       
        String p_userId=userinfo.getUserId(); 
        Account acc=new Account();
        acc.name='TEST';
        insert acc;
        String p_recordId=acc.Id;        
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new OnedriveMockHttpResponseGenerator());
        OnedriveFolder__c p_odf=new OnedriveFolder__c();
        Onedrive__c p_od=onedrive__c.getValues(userinfo.getUserId());
			OnedriveAppUtility.deleteItem('test', 'test');
        Test.stopTest();
    }
}