@isTest
public class OneDriveAppControllerTest {
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
        OneDriveAppController.loadFiles(p_recordId);   
        OnedriveAppController.getOnedriveUsers();
        onedriveappcontroller.dogetOneDriveFolder(p_recordId);
        Test.stopTest();
    }   
    
    @isTest
    static void test2(){       
        String p_userId=userinfo.getUserId(); 
        Account acc=new Account();
        acc.name='TEST';
        insert acc;
        String p_recordId=acc.Id;           
         OneDriveFolder__c odf=new OneDriveFolder__c();
        odf.onedrive_Id__c='test';
        odf.onedrive_driveId__c='test';
        odf.record_id__c=acc.Id;
        odf.owner_name__c=userinfo.getName();
        insert odf;
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new OnedriveMockHttpResponseGenerator());  
        odf=[select Id,Name,onedrive_driveId__c, onedrive_id__c,shared_with__c,share__c,createdbyId,createdby.name,createdby.email
                     from OneDriveFolder__c 
                     where id=:odf.Id
                     ORDER BY createddate
                     LIMIT 1];  
        System.assertEquals(odf.CreatedById,userinfo.getUserId());
        OneDriveAppController.listFiles(odf);
        OneDriveAppController.sendRequestForShare(odf, acc.Id);
        Test.stopTest();
    }   
    
     @isTest
    static void test3(){       
        String p_userId=userinfo.getUserId(); 
        Account acc=new Account();
        acc.name='TEST';
        insert acc;
        OneDriveFolder__c odf=new OneDriveFolder__c();
        odf.onedrive_Id__c='test';
        odf.onedrive_driveId__c='test';
        odf.Record_Id__c=acc.Id;
        odf.Name=acc.name;
        odf.owner_name__c=userinfo.getName();
        insert odf;
        
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        String p_recordId=acc.Id;           
        Map<String,String> uploadmap=new map<String,String>();
        String docId=[select contentdocumentId from contentversion where Id=:contentVersionInsert.Id].contentdocumentId;
        uploadmap.put('documentId',docId);
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new OnedriveMockHttpResponseGenerator()); 
        String uploadedFiles=JSON.serialize(new List<Map<String,String>>{uploadmap});
        OneDriveAppController.saveUploads(p_recordId, uploadedFiles);
        Test.stopTest();
    }   
    
    @isTest
    static void test4(){  
       /*  Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='stan', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='tstcxstan@testorg.com');
        u.UserRoleId=[select Id from userRole limit 1].Id;
        u.CommunityNickname='stan';
        insert u;
        system.runas(u){ */
        String p_userId=userinfo.getUserId(); 
        Account acc=new Account();
        acc.name='TEST';
        insert acc;
        OneDriveFolder__c odf=new OneDriveFolder__c();
        odf.onedrive_Id__c='test';
        odf.onedrive_driveId__c='test';
        odf.Name=acc.name;
        odf.Record_Id__c=acc.Id;
        odf.owner_name__c=userinfo.getName();
        insert odf;
        String p_recordId=acc.Id;        
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new OnedriveMockHttpResponseGenerator());
      //  OneDriveAppController.shareWithAllLHGlobalUsers(p_recordId);
       String p_selectedUsers=userinfo.getUserId();
       OneDriveAppController.shareFolderWithUsers(p_recordId, p_selectedUsers);
        Test.stopTest();
       // }
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
        OneDriveAppController.loadFolder(p_recordId,'test');
        Test.stopTest();
    }   
    @isTest
    static void test6(){       
        String p_userId=userinfo.getUserId(); 
        Account acc=new Account();
        acc.name='TEST';
        insert acc;
        String p_recordId=acc.Id;
		OneDriveFolder__c odf=new OneDriveFolder__c();
        odf.onedrive_Id__c='test';
        odf.onedrive_driveId__c='test';
        odf.Name=acc.name;
        odf.Record_Id__c=acc.Id;
        odf.owner_name__c=userinfo.getName();
       // insert odf;        
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new OnedriveMockHttpResponseGenerator());
        OneDriveAppController.removeAllPermissions(odf);
        Test.stopTest();
    }   
    @isTest
    static void test7(){       
        String p_userId=userinfo.getUserId(); 
        Account acc=new Account();
        acc.name='TEST';
        insert acc;
        String p_recordId=acc.Id;
		OneDriveFolder__c odf=new OneDriveFolder__c();
        odf.onedrive_Id__c='test';
        odf.onedrive_driveId__c='test';
        odf.Name=acc.name;
        odf.Record_Id__c=acc.Id;
        odf.owner_name__c=userinfo.getName();
        insert odf;        
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new OnedriveMockHttpResponseGenerator());
        OneDriveAppController.deletePermission(new Set<String>{'test'}, 'te', 'te');
        Test.stopTest();
    }  
     @isTest
    static void test8(){
        String p_userId=userinfo.getUserId(); 
        Account acc=new Account();
        acc.name='TEST';
        insert acc;
        OneDriveFolder__c odf=new OneDriveFolder__c();
        odf.onedrive_Id__c='test';
        odf.onedrive_driveId__c='test';
        odf.Name=acc.name;
        odf.Record_Id__c=acc.Id;
        odf.owner_name__c=userinfo.getName();
        odf.Shared_With__c=Userinfo.getUserName()+'('+userinfo.getUserId()+')';
        insert odf;
        String p_recordId=acc.Id;        
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new OnedriveMockHttpResponseGenerator());
       String p_selectedUsers=userinfo.getUserId();
       OneDriveAppController.removeAccessAction(p_recordId, p_selectedUsers);
        Test.stopTest();
    }   
}