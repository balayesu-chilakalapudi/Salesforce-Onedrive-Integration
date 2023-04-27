public class OneDriveGrantAccessController {
    @AuraEnabled
    public static List<SFUser> getOnedriveUserslist(String p_recordId){
        List<SFUser> allSFusers=new List<SFUser>();
        Map<String,SFUser> sfuIdmap=new Map<String,SFUser>();
        
        for(User u:[select Id,Name,ProfileId,profile.Name from User
                    where isactive=true
                    and profileId!=null
                   // and Id!=:userinfo.getUserId()
                    Order by Name]){
                        if(u.profile.Name!=null &&
                           !u.profile.name.contains('Chatter')){
                               SFUser sfu=new SFUser();
                               sfu.UserId=u.Id;
                               sfu.Name=u.Name;
                               sfu.CanEdit=false;
                               sfu.CanView=false;
                               sfuIdmap.put(u.Id,sfu);
                           }
                    }   
        for(Onedrive_Permission__c op:[select onedrivefolder__c,user__c,can_view__c,can_edit__c
                                       from onedrive_permission__c 
                                       where onedrivefolder__r.record_Id__c=:p_recordId]){
                                           if(sfuIdmap.containsKey(op.User__c)){
                                               if(op.can_view__c){
                                                   sfuIdmap.get(op.User__c).CanView=true; 
                                               }
                                               if(op.can_edit__c){
                                                   sfuIdmap.get(op.User__c).CanEdit=true;
                                               }
                                           }
                                       }       
        allSFusers=sfuIdmap.values();
        System.debug('allSFusers:'+allSFusers);
        return allSFusers;
    }  
    public class SFUser{
        @AuraEnabled
        public boolean Selected;
        @AuraEnabled
        public String UserId;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public boolean CanEdit;
        @AuraEnabled
        public boolean CanView;
    }
    @AuraEnabled
    public static void savePermissionlist(String p_sfulist,String p_recordId){
        OnedriveFolder__c odf=[select Id,Name
                               from Onedrivefolder__c 
                               where record_Id__c=:p_recordId];
        String canedit_str='';
        String canview_str='';
        System.debug('p_sfulist:'+p_sfulist);
        System.debug('p_recordId:'+p_recordId);
        List<SFUser> sfulist=(List<SFUser>)JSON.deserialize(p_sfulist, List<SFUser>.class);
        Map<String,Onedrive_Permission__c> odpmap=new Map<String,Onedrive_Permission__c>();
        for(Onedrive_Permission__c odp:[select Id,onedrivefolder__r.onedrive_id__c, onedrivefolder__r.onedrive_driveId__c,onedrivefolder__r.Name,
                                        user__r.username, permission_Id__c,Can_edit__c,can_view__c
                                        from onedrive_permission__c
                                        where onedrivefolder__r.record_Id__c=:p_recordId]){
                                            odpmap.put(odp.user__c,odp);
                                        }       
        for(SFUser sfu:sfulist){
            //put new permission if not available
            if(!odpmap.containsKey(sfu.UserId)){
                odpmap.put(sfu.UserId,new Onedrive_Permission__c(User__c=sfu.UserId,
                                                                 Onedrivefolder__c=odf.id
                                                                ));
            }
            if(sfu.Selected!=null &&
               sfu.Selected){
                   if(sfu.CanEdit){
                       odpmap.get(sfu.UserId).Can_Edit__c=true;
                   }else{
                       odpmap.get(sfu.UserId).Can_Edit__c=false;
                   }
                   if(sfu.CanView){
                       odpmap.get(sfu.UserId).Can_View__c=true;
                   }else{
                       odpmap.get(sfu.UserId).Can_View__c=false;
                   }
                   addPermission(JSON.serialize(odpmap.get(sfu.UserId)));                    
               }
        }
    }
    
    @future(callout=true)
    public static void addPermission(String p_odp){
        system.debug('p_odp:'+p_odp);
        //get permission record froms salesforce
        Onedrive_permission__c odp=(Onedrive_Permission__c)JSON.deserialize(p_odp, Onedrive_Permission__c.class);
        OnedriveFolder__c odf=[select Id,Name,Onedrive_Id__c,onedrive_driveId__c from onedrivefolder__c where Id=:odp.onedrivefolder__c];        
        User usr=[select username from User where Id=:odp.user__c];
        String p_itemId=odf.onedrive_id__c;
        String p_email=usr.username;
        Boolean p_CanEdit=odp.can_edit__c;
        Boolean p_CanView=odp.can_view__c;
        String p_folderName=odf.Name;
        String p_driveId=odf.onedrive_driveId__c;       
        String p_permissionId=odp.permission_Id__c;
        String userId=System.Label.Onedrive_JamesClarke_UserId;
        //UserInfo.getUserId();
        OneDrive__c od=OneDrive__c.getValues(userId);        
        String client_id=od.client_id__c;
        String redirect_uri=od.redirect_uri__c;
        String client_secret=od.client_secret__c; 
        // String LHGlobalAPI_FolderId=od.LHGlobalAPI_Folder_Id__c;
        //Access token        
        String acc_expected_str=(od.access_token_part1__c+od.access_token_part2__c+od.access_token_part3__c+od.access_token_part4__c+od.access_token_part5__c+od.access_token_part6__c+od.access_token_part7__c+
                                 od.access_token_part8__c+od.access_token_part9__c+od.access_token_part10__c+od.access_token_part11__c+od.access_token_part12__c+od.access_token_part13__c+od.access_token_part14__c);
        if(acc_expected_str.contains('null')){
            acc_expected_str=acc_expected_str.replace('null', '');
        }
        acc_expected_str=acc_expected_str.trim();
        String access_token=acc_expected_str;
        
        // revoke access
        if(p_permissionId!=null){
            HttpRequest req = new HttpRequest();
            String driveId=p_driveId;
            String Id=p_itemId;
            ///drives/{drive-id}/items/{item-id}/permissions/{perm-id}
            String endpoint='https://graph.microsoft.com/v1.0/me/drives/'+driveId+'/items/'+Id+'/permissions/'+p_permissionId;     
            System.debug('endpoint: '+endpoint);
            req.setEndpoint(endpoint); 
            req.setHeader('Authorization', 'Bearer ' + access_token);
            req.setMethod('DELETE');
            req.setTimeout(60000);
            req.setHeader('Content-type', 'application/json');
            req.setHeader('Accept', 'application/json');
            Http h = new Http();
            HttpResponse res = h.send(req);
            string resp = res.getBody();
            System.debug(' response :: ' + resp);        
        }      
        
        if(p_CanView || p_CanEdit){
            //add permission
            HttpRequest req1 = new HttpRequest();  
            
            String endpoint='';
            
            //POST /me/drive/items/{item-id}/invite
            endpoint='https://graph.microsoft.com/v1.0/me/drive/items/'+p_itemId+'/invite';
            
            req1.setEndpoint(endpoint);
            // String name=getFolderName(p_recordId);
            /* {
"recipients": [
{
"email": "ryan@contoso.com"
}
],
"message": "Here's the file that we're collaborating on.",
"requireSignIn": true,
"sendInvitation": true,
"roles": [ "write" ]
} */
            String roles='';
            if(p_CanView){
                roles+='\"read\"';
            }
            if(p_CanEdit){
                roles+=', \"write\"';
            }
            
            roles=roles.removeStart(',');
            roles=roles.trim();
            roles='[ '+roles+']';
            
            String parameters = '{'+
                '\"recipients\": ['+
                ' {'+
                ' \"email\": \"'+p_email+'\"'+
                '}'+
                '],'+
                '\"message\": \"Here\'s the file that we\'re collaborating on.\",'+
                '\"requireSignIn\": true,'+
                '\"sendInvitation\": true,'+
                '\"roles\": '+roles+
                '}';
            System.debug('parameters: '+parameters);
            req1.setHeader('Authorization', 'Bearer ' + access_token);
            // req1.setHeader('data', parameters);
            req1.setMethod('POST');
            req1.setTimeout(60000);
            req1.setBody(parameters);
            req1.setHeader('Content-type', 'application/json');
            req1.setHeader('Accept', 'application/json');
            Http h = new Http();
            HttpResponse res1 = h.send(req1);
            string resp1 = res1.getBody(); 
            System.debug('res1 status:'+res1.getStatus());
            System.debug(' response :: ' + resp1);
            if(odp.Id==null){
            	insert odp;
            }
            Map<String,Object> respmap=(Map<String,Object>)JSON.deserializeUntyped(resp1);
            Set<String> permissionIdset=new Set<String>();
            if(respmap!=null && respmap.containsKey('value')){ 
                List<Object> valuelist=(List<Object>)respmap.get('value');   
                for(Object ob:valuelist){
                    Map<String,Object> mp=(Map<String,Object>)ob; 
                    if(mp!=null){
                        String email='';
                        
                        //skip owner
                        if(mp.containsKey('grantedTo')){
                            Map<String,Object> grantedobj=(Map<String,Object>)mp.get('grantedTo');
                            Map<String,Object> usermap=(Map<String,Object>)grantedobj.get('user');
                            if(usermap.containsKey('email')){
                                email=(String)usermap.get('email');
                            }
                        }
                        //skip users james and owner by email
                        if(mp.containsKey('grantedTo')  &&
                           mp.containsKey('id')){
                               String pId=(String)mp.get('id');
                               odp.permission_Id__c=pId;
                           }
                    }
                }   
            }
           
        }
        if(odp.Id!=null){
            update odp;
        }
    }
    
    /*  
@future(callout=true)
public static void updatePermission(String p_odp){
system.debug('p_odp:'+p_odp);
//get permission record froms salesforce
Onedrive_permission__c odp=(Onedrive_Permission__c)JSON.deserialize(p_odp, Onedrive_Permission__c.class);
OnedriveFolder__c odf=[select Id,Name,Onedrive_Id__c,onedrive_driveId__c from onedrivefolder__c where Id=:odp.onedrivefolder__c];        
User usr=[select username from User where Id=:odp.user__c];
String p_itemId=odf.onedrive_id__c;
String p_email=usr.username;
Boolean p_CanEdit=odp.can_edit__c;
Boolean p_CanView=odp.can_view__c;
String p_folderName=odf.Name;
String p_driveId=odf.onedrive_driveId__c;
String p_permissionId=odp.Permission_Id__c;

String userId=System.Label.Onedrive_JamesClarke_UserId;
//UserInfo.getUserId();
OneDrive__c od=OneDrive__c.getValues(userId);        
String client_id=od.client_id__c;
String redirect_uri=od.redirect_uri__c;
String client_secret=od.client_secret__c; 
// String LHGlobalAPI_FolderId=od.LHGlobalAPI_Folder_Id__c;
//Access token        
String acc_expected_str=(od.access_token_part1__c+od.access_token_part2__c+od.access_token_part3__c+od.access_token_part4__c+od.access_token_part5__c+od.access_token_part6__c+od.access_token_part7__c+
od.access_token_part8__c+od.access_token_part9__c+od.access_token_part10__c+od.access_token_part11__c+od.access_token_part12__c+od.access_token_part13__c+od.access_token_part14__c);
if(acc_expected_str.contains('null')){
acc_expected_str=acc_expected_str.replace('null', '');
}
acc_expected_str=acc_expected_str.trim();
String access_token=acc_expected_str;

//create Folder 
HttpRequest req1 = new HttpRequest();  

String endpoint='';
//PATCH /drives/{drive-id}/items/{item-id}/permissions/{perm-id}        	
endpoint='https://graph.microsoft.com/v1.0/me/drives/'+p_driveId+'/items/'+p_itemId+'/permissions/'+p_permissionId;        
req1.setEndpoint(endpoint);
// String name=getFolderName(p_recordId);

String roles='';
if(p_CanView){
roles+='\"read\"';
}
if(p_CanEdit){
roles+=',\"write\"';
}
roles=roles.removeStart(',');
roles=roles.trim();
roles='[ '+roles+']';

String parameters = '{'+          
'\"roles\": '+roles+','+            
'}';
System.debug('Endpoint:'+endpoint);
System.debug('parameters: '+parameters);
req1.setHeader('Authorization', 'Bearer ' + access_token);
// req1.setHeader('data', parameters);
req1.setHeader('X-HTTP-Method-Override','PATCH');
req1.setMethod('POST');
req1.setTimeout(60000);
req1.setBody(parameters);
req1.setHeader('Content-type', 'application/json');
req1.setHeader('Accept', 'application/json');
Http h = new Http();
HttpResponse res1 = h.send(req1);
string resp1 = res1.getBody(); 
System.debug('res1 status:'+res1.getStatus()); 
System.debug(' response :: ' + resp1);       
}    */
}