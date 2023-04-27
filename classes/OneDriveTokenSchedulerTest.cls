@isTest
public class OneDriveTokenSchedulerTest {
	@isTest
    static void test1(){
        List<Onedrive__c> odlist=new List<Onedrive__c>();
        Onedrive__c od=new Onedrive__c();
        od.name=userinfo.getUserId();
        odlist.add(od);        
        Onedrive__c od2=new Onedrive__c();
        od2.name='OneDriveTokens';
        odlist.add(od2);
        insert odlist;        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OnedriveTokenMockHttpResponseGenerator());
        OnedriveTokenScheduler xs=new OnedriveTokenScheduler();
        xs.scheduleMe();
        xs.execute(null);
        Test.stopTest();
    }
    public class OnedriveTokenMockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public  HTTPResponse respond(HTTPRequest req) {      
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest","start":0,"count":235,"data":[{"id":84,"firstName":"D","lastName":"Xie","email":null,"phone":null,"address":{"address1":null,"address2":null,"city":null,"state":null,"zip":null,"countryID":1,"countryName":"United States","countryCode":"US"},"lead":{"id":23},"owner":{"id":1,"firstname":"abc","lastname":"test"},"clientCorporation":{"id":1,"name":"test"}}]}');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }        
    }
}