/*
Refreshing access tokens
An access tokens expire after 12 minutes. Your app can refresh an access token without user interaction by using a refresh token.
*/
global class OneDriveTokenScheduler implements Database.AllowsCallouts,Database.Stateful, Schedulable {
    global void scheduleMe() {        
       // String CRON_Label= System.Label.XEROTokenScheduler; 
        if(!Test.isRunningTest()){
        	system.schedule('OneDriveTokenScheduler 1', '0 00 * * * ?', new OneDriveTokenScheduler());  
            system.schedule('OneDriveTokenScheduler 2', '0 30 * * * ?', new OneDriveTokenScheduler());
        }
    }
    global void execute(SchedulableContext sc){
     	refresh();
    }  
    global void refresh(){        
        //get all onedrive accounts
       List<OneDrive__c> odalist = OneDrive__c.getall().values();
        for(OneDrive__c oda:odalist){
            String userId=oda.Name;
           OneDrivePageController.doRefreshToken(userId); 
        } 
    }
}