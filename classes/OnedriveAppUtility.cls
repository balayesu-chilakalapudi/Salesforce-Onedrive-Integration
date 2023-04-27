/*
 	Onedrive Utility 
	creating apex method for sharing top level folder with all onedrive users
*/
public class OnedriveAppUtility {
    public class OneDriveItem{
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String size;
        @AuraEnabled
        public String webUrl;
        @AuraEnabled
        public String createdDateTime; 
        @AuraEnabled
        public String createdBy;
        @AuraEnabled
        public String lastModifiedDateTime;
        @AuraEnabled
        public String cid;
        @AuraEnabled
        public String id;        
        @AuraEnabled
        public String driveId;
        @AuraEnabled
        public String parId;  
        @AuraEnabled
        public String downloadUrl;
        @AuraEnabled
        public String folder;
        @AuraEnabled
        public String file;
    }
    
    //Share onedrive top level parent folder (Salesforce Documents) with all users
    public static void shareParentWithAll(String p_userId){
        List<OneDrive__c> odalist = OneDrive__c.getall().values();
        for(OneDrive__c oda:odalist){
            String email=oda.onedrive_username__c;
            if(email!=null){
                shareParentFolder(p_userId,email);
            }
        } 
    }
    
    @Future(Callout=true)
    public static void shareParentFolder(String p_userId,String p_emal){        
        String userId=p_userId;
        OneDrive__c od=OneDrive__c.getValues(userId);  
        String p_itemId=od.Salesforce_Documents_Id__c;
        String p_email=p_emal;
        String p_folderName=od.Salesforce_Documents_FolderName__c;
        String p_driveId=od.Salesforce_Documents_DriveId__c;
        
        
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
        /*  if(od.Is_Business_Account__c){
// POST /drives/{drive-id}/items/{item-id}/invite
endpoint='https://graph.microsoft.com/v1.0/drives/'+p_driveId+'/items/'+p_itemId+'/invite';
}
else{*/
        //POST /me/drive/items/{item-id}/invite
        endpoint='https://graph.microsoft.com/v1.0/me/drive/items/'+p_itemId+'/invite';
        //  }
        req1.setEndpoint(endpoint);
        // String name=getFolderName(p_recordId);
        String parameters = '{'+
            '\"recipients\": ['+
            ' {'+
            ' \"email\": \"'+p_email+'\"'+
            '}'+
            '],'+
            '\"message\": \"Here\'s the file that we\'re collaborating on.\",'+
            '\"requireSignIn\": true,'+
            '\"sendInvitation\": true,'+
            '\"roles\": [ \"write\" ]'+
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
    }
     
       
    public static OneDriveFolder__c addOnedriveFolder(String p_driveId,String p_itemId,String p_foldername,String p_recordId){       
        String jamesId=System.Label.Onedrive_JamesClarke_UserId;
        OneDrive__c od=OnedriveToken.doRefreshToken(jamesId);                   
        String client_id=od.client_id__c;
        String redirect_uri=od.redirect_uri__c;
        String client_secret=od.client_secret__c;          
        
        //Access token      
        String acc_expected_str=(od.access_token_part1__c+od.access_token_part2__c+od.access_token_part3__c+od.access_token_part4__c+od.access_token_part5__c+od.access_token_part6__c+od.access_token_part7__c+
                                 od.access_token_part8__c+od.access_token_part9__c+od.access_token_part10__c+od.access_token_part11__c+od.access_token_part12__c+od.access_token_part13__c+od.access_token_part14__c);
        if(acc_expected_str.contains('null')){
            acc_expected_str=acc_expected_str.replace('null', '');
        }
        acc_expected_str=acc_expected_str.trim();
        String access_token=acc_expected_str;
        System.debug('access_token:'+access_token);
        
        //create Folder 
        HttpRequest req1 = new HttpRequest();
        //POST /drives/{drive-id}/items/{parent-item-id}/children
        String endpoint='https://graph.microsoft.com/v1.0/me/drives/'+p_driveId+'/items/'+p_itemId+'/children';        
        req1.setEndpoint(endpoint);
        String name=p_foldername;        
        String parameters = '{\"name\":\"'+name+'\",\"folder\":{}}';
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
        System.debug(' response :: ' + resp1);
        Map<String,Object> rspmp=(Map<String,Object>)JSON.deserializeUntyped(resp1);
        String id='';
        // Account acc=getAccount(p_recordId);
        OneDriveFolder__c odf=new OneDriveFolder__c();
        odf.Record_Id__c=p_recordId;
        odf.name=name;
        odf.Owner_Name__c=Userinfo.getName();
        if(rspmp!=null &&
           rspmp.containsKey('id')){
               odf.onedrive_id__c=(String)rspmp.get('id');
           }
        if(rspmp!=null && rspmp.containsKey('parentReference')){            
            Map<String,Object> prmap=(Map<String,Object>)rspmp.get('parentReference');
            if(prmap!=null && 
               prmap.containsKey('driveId')){
                   odf.onedrive_driveId__c=(String)prmap.get('driveId');
               }
        }
        //save one drive info on account
        if(odf.onedrive_Id__c!=null &&
           odf.onedrive_driveId__c!=null){               
               try{
                   removeAllPermissions(odf,od);                  
               }catch(Exception ex){
                   System.debug('exception:'+ex+'\n'+ex.getStackTraceString());
               }              
           }else{
               odf=null;
           }        
        return odf;
    }
    
    public static void removeAllPermissions(OnedriveFolder__c p_odf,onedrive__c p_od){       
        //#1 list folder permissions
       // String userId=System.Label.Onedrive_JamesClarke_UserId;        
        OneDrive__c od=p_od;
            //OnedriveToken.doRefreshToken(userId);
            //OneDrive__c.getValues(userId);        
        String client_id=od.client_id__c;
        String redirect_uri=od.redirect_uri__c;
        String client_secret=od.client_secret__c; 
        //Access token        
        String acc_expected_str=(od.access_token_part1__c+od.access_token_part2__c+od.access_token_part3__c+od.access_token_part4__c+od.access_token_part5__c+od.access_token_part6__c+od.access_token_part7__c+
                                 od.access_token_part8__c+od.access_token_part9__c+od.access_token_part10__c+od.access_token_part11__c+od.access_token_part12__c+od.access_token_part13__c+od.access_token_part14__c);
        if(acc_expected_str.contains('null')){
            acc_expected_str=acc_expected_str.replace('null', '');
        }
        acc_expected_str=acc_expected_str.trim();
        String access_token=acc_expected_str;
        
        
        HttpRequest req1 = new HttpRequest();
        String driveId=p_odf.onedrive_driveId__c;
        String Id=p_odf.onedrive_Id__c;
        // GET /drives/{drive-id}/items/{item-id}/permissions
        String endpoint='https://graph.microsoft.com/v1.0/me/drives/'+driveId+'/items/'+Id+'/permissions';     
        System.debug('endpoint: '+endpoint);
        req1.setEndpoint(endpoint); 
        req1.setHeader('Authorization', 'Bearer ' + access_token);
        req1.setMethod('GET');
        req1.setTimeout(60000);
        req1.setHeader('Content-type', 'application/json');
        req1.setHeader('Accept', 'application/json');
        Http h = new Http();
        HttpResponse res1 = h.send(req1);
        string resp1 = res1.getBody();
        System.debug(' response :: ' + resp1);
        //skip owner
        Onedrive__c owner_od=Onedrive__c.getValues(Userinfo.getUserId());
        String owner_email=owner_od.onedrive_username__c;
        Map<String,Object> respmap=(Map<String,Object>)JSON.deserializeUntyped(resp1);
        Set<String> permissionIdset=new Set<String>();
        if(respmap!=null && respmap.containsKey('value')){ 
            List<Object> valuelist=(List<Object>)respmap.get('value');   
            for(Object ob:valuelist){
                Map<String,Object> mp=(Map<String,Object>)ob; 
                if(mp!=null){
                    String email='';
                    OneDriveItem odi=new OneDriveItem(); 
                    //skip owner
                    if(mp.containsKey('grantedTo')){
                        Map<String,Object> grantedobj=(Map<String,Object>)mp.get('grantedTo');
                        Map<String,Object> usermap=(Map<String,Object>)grantedobj.get('user');
                        if(usermap.containsKey('email')){
                            email=(String)usermap.get('email');
                        }
                    }
                    //skip users james and owner by email
                    if(mp.containsKey('grantedTo') &&
                       !email.equals('james@lhglobal.co') &&
                       !owner_email.equals(email) &&
                       mp.containsKey('id')){
                           String pId=(String)mp.get('id');
                           permissionIdset.add(pId);
                       }
                }
            }                     
        }
        system.debug('permissionIdset:'+permissionIdset);
        String odfstr=JSON.serialize(p_odf);        
        String odstr=JSON.serialize(od);
        deletePermission(permissionIdset,p_odf.onedrive_Id__c,p_odf.onedrive_driveId__c,odfstr,odstr);
    }
    
    
    public static void deletePermission(Set<String> p_pidset,String p_Id,String p_driveId,String p_odfstr,String p_odstr){
        //#2 delete permissions
       // String userId=System.Label.Onedrive_JamesClarke_UserId;
        //Userinfo.getUserId();
        OneDrive__c od;
        try{
            od=(Onedrive__c)JSON.deserialize(p_odstr, Onedrive__c.class);
        }catch(Exception ex){
            System.debug(ex);
        }
       // =OneDrive__c.getValues(userId);        
        String client_id=od.client_id__c;
        String redirect_uri=od.redirect_uri__c;
        String client_secret=od.client_secret__c; 
        //Access token        
        String acc_expected_str=(od.access_token_part1__c+od.access_token_part2__c+od.access_token_part3__c+od.access_token_part4__c+od.access_token_part5__c+od.access_token_part6__c+od.access_token_part7__c+
                                 od.access_token_part8__c+od.access_token_part9__c+od.access_token_part10__c+od.access_token_part11__c+od.access_token_part12__c+od.access_token_part13__c+od.access_token_part14__c);
        if(acc_expected_str.contains('null')){
            acc_expected_str=acc_expected_str.replace('null', '');
        }
        acc_expected_str=acc_expected_str.trim();
        String access_token=acc_expected_str;
         String driveId=p_driveId;
        String Id=p_Id;
        for(String p_permissionId:p_pidset){
        HttpRequest req1 = new HttpRequest();
       
        ///drives/{drive-id}/items/{item-id}/permissions/{perm-id}
        String endpoint='https://graph.microsoft.com/v1.0/me/drives/'+driveId+'/items/'+Id+'/permissions/'+p_permissionId;     
        System.debug('endpoint: '+endpoint);
        req1.setEndpoint(endpoint); 
        req1.setHeader('Authorization', 'Bearer ' + access_token);
        req1.setMethod('DELETE');
        req1.setTimeout(60000);
        req1.setHeader('Content-type', 'application/json');
        req1.setHeader('Accept', 'application/json');
        Http h = new Http();
        HttpResponse res1 = h.send(req1);
        string resp1 = res1.getBody();
        System.debug(' response :: ' + resp1);
        }
        try{
            OnedriveFolder__c odf=(OnedriveFolder__c)JSON.deserialize(p_odfstr, OnedriveFolder__c.class);
            insert odf;            
        }catch(Exception ex){
            System.debug('Exception:'+ex+'\n'+ex.getStackTraceString());
        }
        try{
        	update od;
        }catch(Exception ex){
            System.debug(ex);
        }
    }
    
    public static String getFolderName(String p_recordId){
        String name='';
        try{
            Id myId=Id.valueOF(p_recordId);
            //get sobjectname
            String sObjName = myId.getSObjectType().getDescribe().getName();
            System.debug('sobjectname:'+sObjName);
            String rname='';
            if(sObjName.equals('Opportunity')){
                rname=(String)database.query('select Opportunity_Number__c from '+sobjName+' where Id=\''+p_recordId+'\'')[0].get('Opportunity_Number__c');
            } 
            else if(sObjName.equals('Case')){
                rname=(String)database.query('select CaseNumber from '+sobjName+' where Id=\''+p_recordId+'\'')[0].get('CaseNumber');
            }   
            else if(sObjName.equals('Campaign')){
                rname=(String)database.query('select Campaign_number__c from '+sobjName+' where Id=\''+p_recordId+'\'')[0].get('Campaign_number__c');
            } 
            else{
                rname=(String)database.query('select name from '+sobjName+' where Id=\''+p_recordId+'\'')[0].get('Name');
            }
            //remove "" * : < > ? / \ | .
            String[] spls=new String[]{'\"', '*', ':', '<', '>', '?', '/', '\\', '|', '.'};
                if(rname!=null){
                    for(String s:spls){
                        if(rname.contains(s)){
                            rname=rname.replace(s,'');
                        }
                    }
                    name=rname;                    
                }
            string namestr='%'+name+'%';
            integer autonum=0;
            for(onedrivefolder__c odf:[select Id,Name from Onedrivefolder__c where name like :namestr]){
                if(odf.name!=null &&
                   odf.name.containsIgnoreCase(name)){
                    autonum++;
                }
            }
            if(autonum!=0){
                name=name+'_'+autonum;
            }
        }catch(Exception ex){
            System.debug('Exception:'+ex+'\n'+ex.getStackTraceString());
        }
        
        return name;
    }
    
     public static void deleteItem(String itemId,String driveId){
         String userId=UserInfo.getUserId();
        OneDrive__c od=OnedriveToken.doRefreshToken(userId);
            //OneDrive__c.getValues(userId);        
        String client_id=od.client_id__c;
        String redirect_uri=od.redirect_uri__c;
        String client_secret=od.client_secret__c; 
         //Access token        
        String acc_expected_str=(od.access_token_part1__c+od.access_token_part2__c+od.access_token_part3__c+od.access_token_part4__c+od.access_token_part5__c+od.access_token_part6__c+od.access_token_part7__c+
                                 od.access_token_part8__c+od.access_token_part9__c+od.access_token_part10__c+od.access_token_part11__c+od.access_token_part12__c+od.access_token_part13__c+od.access_token_part14__c);
        if(acc_expected_str.contains('null')){
            acc_expected_str=acc_expected_str.replace('null', '');
        }
        acc_expected_str=acc_expected_str.trim();
        String access_token=acc_expected_str;
        
        //delete image 
        HttpRequest req1 = new HttpRequest();
        //DELETE /drives/{drive-id}/items/{item-id}
        String endpoint='https://graph.microsoft.com/v1.0/me/drives/'+driveId+'/items/'+itemid;       
       
        System.debug('endpoint: '+endpoint);
        req1.setEndpoint(endpoint);    
        req1.setHeader('Authorization', 'Bearer ' + access_token);       
        req1.setMethod('DELETE');
        req1.setTimeout(60000);
        req1.setHeader('Content-type', 'application/json');
        req1.setHeader('Accept', 'application/json');
        Http h = new Http();
        HttpResponse res1 = h.send(req1);
        string resp1 = res1.getBody();
        System.debug(' response :: ' + resp1);  
        try{
            update od;
        }catch(Exception ex){
            System.debug(ex);
        }
    }
    
    
    public static List<OnedriveItem> listFiles(String driveId,String id){          
        String userId=Userinfo.getUserId();
        OneDrive__c od=OnedriveToken.doRefreshToken(userId);
        String client_id=od.client_id__c;
        String redirect_uri=od.redirect_uri__c;
        String client_secret=od.client_secret__c; 
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
       
        String endpoint='https://graph.microsoft.com/v1.0/me/drives/'+driveId+'/items/'+id+'/children';
       
        System.debug('endpoint: '+endpoint);
        req1.setEndpoint(endpoint);            
        req1.setHeader('Authorization', 'Bearer ' + access_token);
        
        req1.setMethod('GET');
        req1.setTimeout(60000);
       
        req1.setHeader('Content-type', 'application/json');
        req1.setHeader('Accept', 'application/json');
        Http h = new Http();
        HttpResponse res1 = h.send(req1);
        string resp1 = res1.getBody();
        System.debug(' response :: ' + resp1);
        try{
            update od;
        }catch(Exception ex){
            System.debug(ex);
        }
       
        Map<String,Object> respmap=(Map<String,Object>)JSON.deserializeUntyped(resp1);
        List<OneDriveItem> itemlist=new List<OneDriveItem>();
        if(respmap!=null && respmap.containsKey('value')){
            String p_cid='';
            String p_parId='';            
            String ctx=(String)respmap.get('@odata.context');
            System.debug('ctx:'+ctx);
            //driveId
            if(ctx!=null){
                p_cid=ctx.substringBetween('/drives(\'', '\')/items');                        
                p_parId=ctx.substringBetween('/items(\'', '\')/children');
            }            
            List<Object> valuelist=(List<Object>)respmap.get('value');   
            for(Object ob:valuelist){
                Map<String,Object> mp=(Map<String,Object>)ob; 
                if(mp!=null){
                    OneDriveItem odi=new OneDriveItem(); 
                    if(mp.containsKey('name')){
                        odi.name=(String)mp.get('name');
                    }
                    if(mp.containsKey('size')){
                        Integer fsize=(Integer)mp.get('size');
                        Integer d=fsize/1000000;
                        if(d==0){
                            odi.size=(fsize/1000)+' KB';
                        }else{
                            odi.size=(fsize/1000000)+' MB';
                        }
                    }
                    if(mp.containsKey('webUrl')){
                        odi.webUrl=(String)mp.get('webUrl');
                    }
                    if(mp.containsKey('createdDateTime')){
                        odi.createdDateTime=(String)mp.get('createdDateTime');
                    }
                    if(mp.containsKey('createdBy')){
                        Map<String,Object> cbmap=(Map<String,Object>)mp.get('createdBy');
                        if(cbmap!=null && cbmap.containsKey('user')){
                            Map<String,Object> usermap=(Map<String,Object>)cbmap.get('user');
                            if(usermap!=null && usermap.containsKey('displayName')){
                                odi.createdBy = (String)usermap.get('displayName');
                            }
                        }
                    }
                    if(mp.containsKey('lastModifiedDateTime')){
                        odi.lastModifiedDateTime=(String)mp.get('lastModifiedDateTime');
                    }                    
                    if(mp.containskey('id')){
                        odi.id=(String)mp.get('id');
                        odi.cid=p_cid;
                        odi.parId=p_parId;                            
                    }
                    if(mp.containsKey('@microsoft.graph.downloadUrl')){
                        odi.downloadUrl=(String)mp.get('@microsoft.graph.downloadUrl');
                    }
                    if(mp.containsKey('folder')){
                        odi.folder=String.valueOf(mp.get('folder'));
                    }
                    if(mp.containsKey('file')){
                        odi.file=String.valueOf(mp.get('file'));
                    }
                    if(mp.containsKey('parentReference')){
                        Map<String,Object> cbmap=(Map<String,Object>)mp.get('parentReference');
                        if(cbmap!=null && cbmap.containsKey('driveId')){
                            if(cbmap!=null && cbmap.containsKey('driveId')){
                                odi.driveId = (String)cbmap.get('driveId');
                            }
                        }
                    }
                    itemlist.add(odi);
                }                
            }
            system.debug('itemlist:'+itemlist);
        }
        
        return itemlist;
    }
    
    
    public static void saveToOneDrive(String fileName,Blob p_data, String p_recordId,String p_itemId,String p_driveId,string p_odstr) {
        // OnedriveFolder__c odf=getOneDriveFolder(p_recordId); 
       
        // remove - and space from filename
        if(fileName!=null){
         fileName=fileName.escapeUnicode();
        }
        if(fileName!=null && fileName.contains('-')){
            fileName=fileName.replace('-','');
        } 
        if(fileName!=null && fileName.contains(' ')){
            fileName=fileName.replace(' ','');
        } 
        if(fileName!=null && fileName.contains('\\')){
         	fileName=fileName.replace('\\','');
        }
        if(fileName!=null && fileName.contains('/')){
         	fileName=fileName.replace('/','');
        }
        fileName=fileName.trim();        
        // base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Blob data= p_data;
        //EncodingUtil.base64Decode(base64Data);
        System.debug('data size: '+data.size());  
        // System.debug('createFolder > foldername:'+p_recordId);
        String userId='';
        /* if(odf!=null)
userId=odf.CreatedById;
else */
        
        OneDrive__c od; 
        try{
        	od=(Onedrive__c)JSON.deserialize(p_odstr, Onedrive__c.class);
        }catch(Exception ex){
            System.debug(ex);
        }
            //OneDrive__c.getValues(userId);        
        String client_id=od.client_id__c;
        String redirect_uri=od.redirect_uri__c;
        String client_secret=od.client_secret__c; 
        //Access token        
        String acc_expected_str=(od.access_token_part1__c+od.access_token_part2__c+od.access_token_part3__c+od.access_token_part4__c+od.access_token_part5__c+od.access_token_part6__c+od.access_token_part7__c+
                                 od.access_token_part8__c+od.access_token_part9__c+od.access_token_part10__c+od.access_token_part11__c+od.access_token_part12__c+od.access_token_part13__c+od.access_token_part14__c);
        if(acc_expected_str.contains('null')){
            acc_expected_str=acc_expected_str.replace('null', '');
        }
        acc_expected_str=acc_expected_str.trim();
        String access_token=acc_expected_str;
        
        
        String id=p_itemId;
        String driveId=p_driveId;
        /* if(odf!=null){
id=odf.onedrive_Id__c;
driveId=odf.onedrive_driveId__c;
}        */
        String foldername=onedriveapputility.getFolderName(p_recordId);
        //create Folder 
        HttpRequest req1 = new HttpRequest();
        // POST /drives/{driveId}/items/{itemId}/createUploadSession
         String endpoint='https://graph.microsoft.com/v1.0/me/drives/'+driveId+'/items/'+id+':/'+fileName+':/createUploadSession';   
     //  String endpoint='https://graph.microsoft.com/v1.0/me/drives/'+driveId+'/items/'+id+':/Image.jpg:/createUploadSession';   
        System.debug('endpoint:'+endpoint);
        req1.setEndpoint(endpoint);            
        String parameters = '{'+
            // '\"item\": {'+
            //  '\"@odata.type\": \"microsoft.graph.driveItemUploadableProperties\",'+
            '\"@microsoft.graph.conflictBehavior\": \"rename | fail | replace\"'+
            // '\"description\": \"description\",'+          
            // '\"fileSystemInfo\": { \"@odata.type\": \"microsoft.graph.fileSystemInfo\" },'+
           //  ',\"name\": \"'+fileName+'\"'+
            // '}'+
            '}';
        System.debug('parameters: '+parameters); 
        req1.setHeader('Authorization', 'Bearer ' + access_token);        
        req1.setMethod('POST');
        req1.setTimeout(60000);
        req1.setBody(parameters);
        req1.setHeader('Content-Type', 'application/json');
        req1.setHeader('Accept', 'application/json');
        Http h = new Http();
        HttpResponse res1 = h.send(req1);
        string resp1 = res1.getBody();
        System.debug(' response :: ' + resp1);
        
        Map<String,Object> respmap=(Map<String,Object>)JSON.deserializeUntyped(resp1);
        String uploadUrl='';
        if(respmap!=null){
            if(respmap.containsKey('uploadUrl')){
                uploadUrl=(String)respmap.get('uploadUrl');            
                //upload file to uploadUrl
                HttpRequest req2 = new HttpRequest();
                //LHGlobalAPI = 530BAD846FC1648C!115, top level folder
                String endpoint2=uploadUrl;
                System.debug('endpoint2:'+endpoint2);
                req2.setEndpoint(endpoint2);            
                // System.debug('parameters2: '+parameters2);
                req2.setHeader('Authorization', 'Bearer ' + access_token);
                // req1.setHeader('data', parameters);
                req2.setMethod('PUT');
                req2.setTimeout(60000);
                // req2.setBody(parameters);
                req2.setHeader('Content-type', 'application/json');
                Integer fileSize=data.size();
                Integer chunksize=fileSize/327680;
                Integer clength=chunksize+1;
                //  system.debug('content length: '+fileSize);
                String content_range='bytes 0-'+(fileSize-1)+'/'+fileSize;
                System.debug('content range:'+content_range);
                // System.debug('chunksize:'+chunksize);                
                req2.setHeader('Content-Length',String.valueOf(fileSize));
                req2.setHeader('Content-Range', content_range);   //Content-Range: bytes 0-25/128
                req2.setHeader('Accept', 'application/json');
                ///Blob cblob = data;
                req2.setBodyAsBlob(data);
                
                Http h2 = new Http();
                HttpResponse res2 = h2.send(req2);
                string resp2 = res2.getBody();
                System.debug(' response2 :: ' + resp2);
                
            }
        }
    }
    
    
    public static void saveUploads(String recordId,String uploadedFiles){
        if(recordId!=null){
         String p_userId=userinfo.getUserId();
        Onedrive__c od=OnedriveToken.doRefreshToken(p_userId);
        
        System.debug('recordId:'+recordId);
        System.debug('uploadedFiles:'+uploadedFiles);        
        List<Object> filelist=new List<Object>();
        try{
            filelist=(List<Object>)JSON.deserializeUntyped(uploadedFiles);
        }catch(Exception ex){
            System.debug('Exception: '+ex);
        }
        Set<Id> fileIdset=new Set<Id>();
        // traverse list of uploaded files
        for(Object ob:filelist){
            Map<String,Object> filemap=(Map<String,Object>)ob;  
            if(filemap!=null &&
               filemap.containsKey('documentId')){
                   fileIdset.add((String)filemap.get('documentId'));
               }
        }
       
        List<ContentVersion> cvlist=new List<ContentVersion>();
        set<Id> cdocIdset=new set<Id>();
        for(ContentVersion cv:[SELECT Id, VersionData, ContentDocumentId, Title, FileExtension,ContentSize 
                               FROM ContentVersion
                               WHERE ContentDocumentId IN:fileIdset]){
                                   cvlist.add(cv);                                  
                               }
        
        OnedriveFolder__c odf=getOneDriveFolder(recordId); 
        if(odf!=null &&
           odf.onedrive_Id__c!=null &&
           odf.onedrive_driveId__c!=null){
               //upload to onedrive
               String odstr=JSON.serialize(od);
               for(ContentVersion cv:cvlist){
                   if(cv.ContentDocumentId!=null){
                   		cdocIdset.add(cv.ContentDocumentId);
                   }
                   saveToOneDrive(cv.Title+'.'+cv.FileExtension,cv.versiondata,recordId,odf.onedrive_Id__c,odf.onedrive_driveId__c,odstr);
               }
           }
        try{
            update od;
        }catch(Exception ex){
            System.debug(ex);
        }
        //delete all content documents
           if(cdocIdset!=null){
            try{
                //now delete files in temporary storage
                delete [select Id 
                        from contentdocument 
                        where Id IN:cdocIdset];
            }catch(Exception ex){
                System.debug('Exception: '+ex);
            }
        } 
        }
    }
    
     
    public static OnedriveFolder__c getOneDriveFolder(String p_recordId){
        OneDriveFolder__c odf=null;
        if(p_recordId!=null &&
           !p_recordId.equals('')){
               try{
                   odf=[select Id,Name,onedrive_driveId__c, onedrive_id__c,shared_with__c,share__c,createdbyId,createdby.Name,Createdby.Email,Owner_Name__c 
                        from OneDriveFolder__c 
                        where onedrive_id__c!=null
                        and record_id__c=:p_recordId
                        ORDER BY createddate
                        LIMIT 1];   
               }catch(Exception ex){
                   System.debug('Exception: '+ex);                  
               }
           }
        return odf;
    }
}