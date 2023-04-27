public class OneDriveAppController {
    @AuraEnabled
    public static OnedriveWrapper loadFiles(String p_recordId){
        OnedriveWrapper odw=new OnedriveWrapper();
        String userId=UserInfo.getUserId();       
        String result=checkConnection(userId);   
        List<OnedriveItem> p_odilist=new List<OnedriveItem>();
        OnedriveFolder__c p_odf=new OnedriveFolder__c();
        boolean p_connected=false;
        Onedrive_Permission__c p_odp=new Onedrive_Permission__c();
        if(result.equals('Available')){
            p_connected=true;
            p_odf=getOneDriveFolder(p_recordId); 
            System.debug('loadFiles > p_odf:'+p_odf);
            if(p_odf!=null &&
               p_odf.onedrive_id__c!=null){
                   // list all files and folders  			  
                   p_odilist=listFiles(p_odf);        
               }           
            else{                
                p_odf=addOnedriveFolder(p_recordId);
            }   
        }
        
        p_odp=getOneDrivePermission(p_recordId,p_odf);
        odw.connected=p_connected;
        odw.odf=p_odf;
        odw.odp=p_odp;
        odw.odilist=p_odilist;
        System.debug('odw:'+odw);
        return odw;
    }    
    @AuraEnabled
    public static OneDriveFolder__c addOnedriveFolder(String p_recordId){
        System.debug('createFolder > foldername:'+p_recordId);
        String username=Userinfo.getUserName();
        String userId=UserInfo.getUserId();
        OneDrive__c od=OneDrive__c.getValues(userId);        
        String client_id=od.client_id__c;
        String redirect_uri=od.redirect_uri__c;
        String client_secret=od.client_secret__c; 
        String LHGlobalAPI_FolderId='';
        //od.LHGlobalAPI_Folder_Id__c;
        //get object name
        Id myId=Id.valueOF(p_recordId);
        //get sobjectname
        String sObjName = myId.getSObjectType().getDescribe().getName();
        System.debug('sobjectname:'+sObjName);
        String jamesId=System.Label.Onedrive_JamesClarke_UserId;
        Onedrive__c jamesod=OneDrive__c.getValues(jamesId);
        String jamesdriveId=jamesod.Salesforce_documents_driveId__c;
        if(sobjName.equals('Account')){
            LHGlobalAPI_FolderId=jamesod.LHGlobalAPI_Folder_Id__c;
        }
        if(sobjName.equals('Opportunity')){
            LHGlobalAPI_FolderId=jamesod.Opportunities_Folder_Id__c;
        }
        if(sobjName.equals('Lead')){
            LHGlobalAPI_FolderId=jamesod.Leads_Folder_Id__c;
        }
        if(sobjName.equals('Contact')){
            LHGlobalAPI_FolderId=jamesod.Contacts_Folder_Id__c;
        }
        if(sobjName.equals('Case')){
            LHGlobalAPI_FolderId=jamesod.Cases_Folder_Id__c;
        }
        if(sobjName.equals('Campaign')){
            LHGlobalAPI_FolderId=jamesod.Campaigns_Folder_Id__c;
        }
        
        
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
        String endpoint='https://graph.microsoft.com/v1.0/me/drives/'+jamesdriveId+'/items/'+LHGlobalAPI_FolderId+'/children';
        // String endpoint='https://graph.microsoft.com/v1.0/me/drive/items/'+LHGlobalAPI_FolderId+'/children';
        req1.setEndpoint(endpoint);
        String name=getFolderName(p_recordId);
        try{
            string namestr=name+'%';
            integer autonum=0;
            for(onedrivefolder__c odf:[select Id,Name from Onedrivefolder__c where name like :namestr]){
                if(odf.name.startsWith(name+'_')){
                    autonum++;
                }
            }
            if(autonum!=0){
                name=name+'_'+autonum;
            }
        }catch(Exception ex){
            System.debug('Exception:'+ex+'\n'+ex.getStackTraceString());
        }
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
                   removeAllPermissions(odf);
                   /*
String p_itemId=odf.onedrive_Id__c;
String p_email=od.onedrive_username__c;
String p_folderName=odf.Name;
String p_driveId=odf.onedrive_driveId__c;
shareFolderByEmail(p_itemId, p_email, p_folderName, p_driveId); */
               }catch(Exception ex){
                   System.debug('exception:'+ex+'\n'+ex.getStackTraceString());
               }              
           }else{
               odf=null;
           }
        
        return odf;
    } 
    
    @AuraEnabled
    public static OnedriveFolder__c getOneDriveFolder(String p_recordId){        
        //  String name=getFolderName(p_recordId);
        //  System.debug('getOnedriveFolder > name:'+name);
        OneDriveFolder__c odf=null;
        if(!p_recordId.equals('') && 
           p_recordId!=null){
               try{
                   odf=[select Id,Name,onedrive_driveId__c, onedrive_id__c,shared_with__c,share__c,createdbyId,createdby.Name,Createdby.Email,Owner_Name__c 
                        from OneDriveFolder__c 
                        where onedrive_id__c!=null
                        and record_id__c=:p_recordId
                        ORDER BY createddate
                        LIMIT 1];   
               }catch(Exception ex){
                   System.debug('Exception: '+ex);
                   //create folder, skip here
                   // odf=addOnedriveFolder(p_recordId);
               }
           }
        return odf;
    }
    @AuraEnabled
    public static List<OnedriveItem> listFiles(OneDriveFolder__c odf){
        String result='';
        String id=odf.onedrive_id__c;
        String driveId=odf.onedrive_driveId__c;
        String userId=Userinfo.getUserId();
        //odf.createdbyId;            
        OneDrive__c od=OneDrive__c.getValues(userId);        
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
        //LHGlobalAPI = 530BAD846FC1648C!115, top level folder
        String endpoint='https://graph.microsoft.com/v1.0/me/drives/'+driveId+'/items/'+id+'/children';
        // https://{site_url}/_api/web/GetFolderByServerRelativeUrl('/Folder Name')/Files
        String foldername=odf.Name;
        system.debug('foldername: '+foldername);
        //  String endpoint='https://globalenterprisesgroup.sharepoint.com/_api/web/GetFolderByServerRelativeUrl('+
        //    '\'/Shared Documents/'+foldername+'\')/Files';
        System.debug('endpoint: '+endpoint);
        req1.setEndpoint(endpoint);            
        //  String parameters = '{\"name\":\"'+p_recordId+'\",\"folder\":{}}';
        //  System.debug('parameters: '+parameters);;
        req1.setHeader('Authorization', 'Bearer ' + access_token);
        // req1.setHeader('data', parameters);
        req1.setMethod('GET');
        req1.setTimeout(60000);
        //  req1.setBody(parameters);
        req1.setHeader('Content-type', 'application/json');
        req1.setHeader('Accept', 'application/json');
        Http h = new Http();
        HttpResponse res1 = h.send(req1);
        string resp1 = res1.getBody();
        System.debug(' response :: ' + resp1);
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
                        Long fsize=(Long)mp.get('size');
                        Long d=fsize/1000000;
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
            /*  if(itemlist.size()==0){
for(OnedriveFile__c fl:[select Id,Name,size__c,createdby.Name,createddate,lastmodifieddate
from onedrivefile__c
where onedrivefolder__c=:odf.Id]){
OneDriveItem odi=new OneDriveItem();
odi.name=fl.name;
odi.size=fl.size__c;
odi.webUrl='#';
odi.downloadUrl='#';
odi.createdDateTime=String.valueOf(fl.createddate);
odi.createdBy=fl.createdby.name;
odi.lastModifiedDateTime=String.valueOf(fl.lastmodifieddate);
itemlist.add(odi);
}
}*/
            // result=JSON.serialize(itemlist);
        }
        /*else{
result='Not Available';
}*/
        return itemlist;
    }
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
    @future(Callout=true)
    public static void saveToOneDrive(String fileName,Blob p_data, String p_recordId, String cdocId) {
        OnedriveFolder__c odf=getOneDriveFolder(p_recordId); 
        
        // remoe - and space from filename
        if(fileName!=null && fileName.contains('-')){
            fileName=fileName.replace('-','');
        } 
        if(fileName!=null && fileName.contains(' ')){
            fileName=fileName.replace(' ','');
        } 
        // base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Blob data= p_data;
        //EncodingUtil.base64Decode(base64Data);
        System.debug('data size: '+data.size());  
        // System.debug('createFolder > foldername:'+p_recordId);
        String userId='';
        /* if(odf!=null)
userId=odf.CreatedById;
else */
        userId=Userinfo.getUserId();
        //UserInfo.getUserId();
        OneDrive__c od=OneDrive__c.getValues(userId);        
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
        
        
        String id='';
        String driveId='';
        if(odf!=null){
            id=odf.onedrive_Id__c;
            driveId=odf.onedrive_driveId__c;
        }        
        String foldername=getFolderName(p_recordId);
        //create Folder 
        HttpRequest req1 = new HttpRequest();
        //LHGlobalAPI = 530BAD846FC1648C!115, top level folder
        // String endpoint='https://graph.microsoft.com/v1.0/drive/root:/LHGlobalAPI/'+foldername+'/'+fileName+':/createUploadSession';  
        // POST /drives/{driveId}/items/{itemId}/createUploadSession
        String endpoint='https://graph.microsoft.com/v1.0/me/drives/'+driveId+'/items/'+id+':/'+fileName+':/createUploadSession';   
        // String endpoint='https://graph.microsoft.com/v1.0/me/drive/items/'+id+':/'+fileName+':/createUploadSession';   
        System.debug('endpoint:'+endpoint);
        req1.setEndpoint(endpoint);            
        String parameters = '{'+
            // '\"item\": {'+
            //  '\"@odata.type\": \"microsoft.graph.driveItemUploadableProperties\",'+
            '\"@microsoft.graph.conflictBehavior\": \"rename | fail | replace\"'+
            // '\"description\": \"description\",'+          
            // '\"fileSystemInfo\": { \"@odata.type\": \"microsoft.graph.fileSystemInfo\" },'+
            // '\"name\": \"'+fileName+'\"'+
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
                System.debug(' response :: ' + resp2);
                Map<String,Object> rspmp=(Map<String,Object>)JSON.deserializeUntyped(resp2);
                // String id='';
                // Account acc=getAccount(p_recordId);
                if(odf==null){
                    odf=new OneDriveFolder__c();
                    odf.name=foldername;
                    odf.Record_Id__c=p_recordId;
                    odf.Owner_Name__c=Userinfo.getName();
                    /* if(rspmp!=null &&
rspmp.containsKey('id')){
odf.onedrive_id__c=(String)rspmp.get('id');
}*/
                    if(rspmp!=null && rspmp.containsKey('parentReference')){            
                        Map<String,Object> prmap=(Map<String,Object>)rspmp.get('parentReference');
                        if(prmap!=null && 
                           prmap.containsKey('id')){
                               odf.onedrive_Id__c=(String)prmap.get('id');
                           }
                        if(prmap!=null && 
                           prmap.containsKey('driveId')){
                               odf.onedrive_driveId__c=(String)prmap.get('driveId');
                           }
                    }
                    //save one drive info on account   
                    try{     
                        insert odf;    
                    }catch(Exception ex){
                        System.debug('Exception: '+ex+'\n'+ex.getStackTraceString());
                    }
                }
            }
        }
        if(cdocId!=null){
            try{
                //now delete files in temporary storage
                delete [select Id from contentdocument where Id=:cdocId];
            }catch(Exception ex){
                System.debug('Exception: '+ex);
            }
        }
    }
    @AuraEnabled
    public static void saveUploads(String recordId,String uploadedFiles){
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
        OnedriveFolder__c odf=getOneDriveFolder(recordId);  
        //save file references
        List<OnedriveFile__c> odfilelist=new List<OnedriveFile__c>();
        
        List<ContentVersion> cvlist=new List<ContentVersion>();
        for(ContentVersion cv:[SELECT Id, VersionData, ContentDocumentId, Title, FileExtension,ContentSize 
                               FROM ContentVersion
                               WHERE ContentDocumentId IN:fileIdset]){
                                   cvlist.add(cv);
                                   /*    odfilelist.add(new onedrivefile__c(Name=cv.Title+'.'+cv.FileExtension,
size__c=String.valueOf(cv.ContentSize),
OnedriveFolder__c=odf.Id)
);*/
                               }   
        //save onedrivefile details
        /* try{
insert odfilelist;
}catch(Exception ex){
System.debug('Exception: '+ex);
} */
        //upload to onedrive
        for(ContentVersion cv:cvlist){
            saveToOneDrive(cv.Title+'.'+cv.FileExtension,cv.versiondata,recordId,cv.ContentDocumentId);
        }
    }
    @AuraEnabled
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
                    /* if(rname.contains('Case')){
name=rname;
}
else{
name=sObjName+'#'+rname;  
}*/
                }
        }catch(Exception ex){
            System.debug('Exception:'+ex+'\n'+ex.getStackTraceString());
        }
        return name;
    }
    
    @AuraEnabled
    public static void shareWithAllLHGlobalUsers(String p_recordId){
        String p_selectedUsers='';
        for(User u:getselectOptions()){
            p_selectedUsers+=u.Id+',';
        }
        shareFolderWithUsers(p_recordId,p_selectedUsers);
    }
    
    @AuraEnabled
    public static void shareFolderWithUsers(String p_recordId, String p_selectedUsers){
        //  System.debug('p_shareId:'+p_shareId);
        System.debug('p_recordId:'+p_recordId);
        System.debug('p_selectedUsers:'+p_selectedUsers);
        OneDriveFolder__c odf;
        try{
            odf=getOneDriveFolder(p_recordId);
            String itemId=odf.onedrive_Id__c;
            
            // String userId=Userinfo.getUserId();
            if(odf.Shared_With__c==null){
                odf.Shared_With__c='';
            }     
            
            if(p_selectedUsers!=null){ 
                if(p_selectedUsers.contains(',')){
                    String[] users=p_selectedUsers.split(',');
                    //prevent duplicates
                    for(String uId:users){
                        if(!odf.Shared_With__c.contains(uId)){
                            try{
                                OneDrive__c od=OneDrive__c.getValues(uId); 
                                if(od!=null && 
                                   od.onedrive_username__c!=null){
                                       String email=od.onedrive_username__c;
                                       shareFolderByEmail(itemId,email,odf.name,odf.onedrive_driveId__c);                        
                                       odf.Shared_With__c+=';'+getUserName(uId)+'('+uId+')'; 
                                   }
                            }catch(Exception ex){
                                System.debug('Exception:'+ex+'\n'+ex.getStackTraceString());
                            }
                        }
                    }
                }else{
                    if(!odf.Shared_With__c.contains(p_selectedUsers)){
                        try{
                            OneDrive__c od=OneDrive__c.getValues(p_selectedUsers); 
                            String email=od.onedrive_username__c;
                            shareFolderByEmail(itemId,email,odf.name,odf.onedrive_driveId__c);                        
                            odf.Shared_With__c+=';'+getUserName(p_selectedUsers)+'('+p_selectedUsers+')'; 
                        }catch(Exception ex){
                            System.debug('Exception:'+ex);
                        }
                    } 
                }   
            }
            odf.Shared_With__c=odf.Shared_With__c.trim();
            odf.Shared_With__c=odf.Shared_With__c.removeStart(';');
            update odf;           
        }catch(Exception ex){
            system.debug('Exception:'+ex);
        }
    }
    
    @future(callout=true)
    public static void shareFolderByEmail(String p_itemId,String p_email,String p_folderName,String p_driveId){
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
        /*  if(resp1!=null){
try{
addSharedFolderToUserDrive(p_itemId,p_driveId,p_folderName);
}catch(Exception ex){
System.debug('exception: '+ex+'\n'+ex.getStackTraceString());
}
} */
    }
    
    @AuraEnabled
    public static List <User> getselectOptions() {
        List<User> allusers=new List<User>();
        for(User u:[select Id,Name from User
                    where isactive=true
                    and profile.name!='Chatter Free User' 
                    and profile.name!=null
                    and Id!=:userinfo.getUserId()]){
                        allusers.add(u);
                    }
        System.debug('allusers:'+allusers);
        return allusers;
    }
    
    /*
public static String addSharedFolderToUserDrive(String p_id,String p_driveId,String p_folderName){
System.debug('p_id:'+p_id);
System.debug('p_driveId:'+p_driveId);
String result='';
String userId=Userinfo.getUserId();
OneDrive__c od=OneDrive__c.getValues(userId);        
String client_id=od.client_id__c;
String redirect_uri=od.redirect_uri__c;
String client_secret=od.client_secret__c; 
String LHGlobalAPI_FolderId=od.LHGlobalAPI_Folder_Id__c;
//Access token
String acc_expected_str=(od.access_token_part1__c+od.access_token_part2__c+od.access_token_part3__c+od.access_token_part4__c+od.access_token_part5__c+od.access_token_part6__c+od.access_token_part7__c);
if(acc_expected_str.contains('null')){
acc_expected_str=acc_expected_str.replace('null', '');
}
acc_expected_str=acc_expected_str.trim();
String access_token=acc_expected_str;

//POST /drive/root/children
HttpRequest req1 = new HttpRequest();          
String endpoint='https://graph.microsoft.com/v1.0/me/drive/root/children';
System.debug('endpoint:'+endpoint);
req1.setEndpoint(endpoint);       

req1.setHeader('Authorization', 'Bearer ' + access_token);
// req1.setHeader('data', parameters);
req1.setMethod('POST');
req1.setTimeout(60000);
String parameters='{'+
'\"name\": \"'+p_folderName+'\",'+
'\"remoteItem\": {'+
'\"id\": \"'+p_id+'\",'+
'\"parentReference\": { \"driveId\": \"'+p_driveId+'\" }'+
'}'+
'}';
System.debug('parameters:'+parameters);
req1.setBody(parameters);
req1.setHeader('Content-type', 'application/json');
req1.setHeader('Accept', 'application/json');
Http h = new Http();
HttpResponse res1 = h.send(req1);
string resp1 = res1.getBody();
System.debug(' response :: ' + resp1);
return result;
} */
    
    public static String checkConnection(String p_userId){
        String result='';
        String userId=p_userId;
        OneDrive__c od=OneDrive__c.getValues(userId);        
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
        if(access_token.equals('')){
            result='Not Available';
        }else{
            result='Available';
        }
        return result;
    }
    @AuraEnabled
    public static String loadFolder(String p_driveId,String p_Id){
        String result='';
        String id= p_Id;
        // odf.onedrive_id__c;
        String driveId= p_driveId;
        // odf.onedrive_driveId__c;
        String userId=Userinfo.getUserId();
        OneDrive__c od=OneDrive__c.getValues(userId);        
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
        //LHGlobalAPI = 530BAD846FC1648C!115, top level folder
        String endpoint='https://graph.microsoft.com/v1.0/me/drives/'+driveId+'/items/'+id+'/children';
        // https://{site_url}/_api/web/GetFolderByServerRelativeUrl('/Folder Name')/Files
        // String foldername=odf.Name;
        // system.debug('foldername: '+foldername);
        //  String endpoint='https://globalenterprisesgroup.sharepoint.com/_api/web/GetFolderByServerRelativeUrl('+
        //    '\'/Shared Documents/'+foldername+'\')/Files';
        System.debug('endpoint: '+endpoint);
        req1.setEndpoint(endpoint);            
        //  String parameters = '{\"name\":\"'+p_recordId+'\",\"folder\":{}}';
        //  System.debug('parameters: '+parameters);;
        req1.setHeader('Authorization', 'Bearer ' + access_token);
        // req1.setHeader('data', parameters);
        req1.setMethod('GET');
        req1.setTimeout(60000);
        //  req1.setBody(parameters);
        req1.setHeader('Content-type', 'application/json');
        req1.setHeader('Accept', 'application/json');
        Http h = new Http();
        HttpResponse res1 = h.send(req1);
        string resp1 = res1.getBody();
        System.debug(' response :: ' + resp1);
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
            /*  if(itemlist.size()==0){
for(OnedriveFile__c fl:[select Id,Name,size__c,createdby.Name,createddate,lastmodifieddate
from onedrivefile__c
where onedrivefolder__c=:odf.Id]){
OneDriveItem odi=new OneDriveItem();
odi.name=fl.name;
odi.size=fl.size__c;
odi.webUrl='#';
odi.downloadUrl='#';
odi.createdDateTime=String.valueOf(fl.createddate);
odi.createdBy=fl.createdby.name;
odi.lastModifiedDateTime=String.valueOf(fl.lastmodifieddate);
itemlist.add(odi);
}
}*/
            result=JSON.serialize(itemlist);
        }else{
            result='Not Available';
        }
        
        return result;
    }
    public static String getUserName(String p_userId){
        String result='';
        try{
            if(p_userId!=null){
                result=[SELECT Name 
                        From User 
                        Where Id=:p_userId 
                        And isActive=true 
                        LIMIT 1].Name;
            }
        }catch(Exception ex){
            System.debug('Exception: '+ex+'\n'+ex.getStackTraceString());
        }
        return result;
    }
    @AuraEnabled
    public static String sendRequestForShare(OnedriveFolder__c p_odf,String p_recordId){
        System.debug('p_odf:'+p_odf);
        String resp='';
        try{
            User requesting_user=[SELECT Id,Name from User where Id=:userinfo.getUserId() LIMIT 1];
            Onedrive_Permission__c odp;
            try{
                odp=[select can_view__c,can_edit__c 
                     from onedrive_permission__c 
                     where user__c=:userinfo.getUserId()
                     and onedrivefolder__r.record_id__c=:p_recordId
                    and can_edit__c=true
                    limit 1];
            }catch(Exception ex){               
                System.debug('Exception:'+ex+'\n'+ex.getStackTraceString());
            }
            if(p_odf!=null &&
               odp==null              
              ){
                  String email=p_odf.CreatedBy.Email;
                  Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                  List<String> emaillist=new List<String>();
                  emaillist.add(email);
                  message.toAddresses = emaillist;
                  //message.ccAddresses = new List<String> {label.Off_Boarding_CC_Email_addresses};
                  EmailTemplate et=[SELECT Id, Name, IsActive, Subject, HtmlValue, Body, Markup FROM EmailTemplate Where Name='Onedrive Folder Request For Share Email'];
                  message.subject =et.Subject;
                  String body=et.body;           
                  if(body!=null){
                      //replace ownername
                      if(body.contains('owner name')){
                          body=body.replace('owner name',p_odf.createdby.Name);
                      }
                      //record link
                      if(body.contains('record link')){
                          body=body.replace('record link',URL.getSalesforceBaseUrl().toExternalForm()+'/'+p_recordId);
                      }
                  }
                  message.plainTextBody = body;
                  Messaging.SingleEmailMessage[] messages =
                      new List<Messaging.SingleEmailMessage> {message};
                          Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                  if (results[0].success) {
                      resp='The email was sent successfully.';
                      System.debug('The email was sent successfully.');
                  } else {
                      System.debug('The email failed to send: '
                                   + results[0].errors[0].message);
                      resp='The email failed to send';
                  }
              }else{
                  if(odp!=null &&
                     odp.can_edit__c){
                  	resp='You already have access ';
                  }
              }
        }catch(Exception ex){
            System.debug('Exception: '+ex+'\n'+ex.getStackTraceString());
            resp='Exception: '+ex+'\n'+ex.getStackTraceString();
        }
        return resp;
    }
    @AuraEnabled
    public static List<Onedrive__c> getOnedriveUsers(){
        List<Onedrive__c> odulist=new List<Onedrive__c>();
        for(Onedrive__c od:[Select Id,Name,user_name__c,onedrive_username__c from Onedrive__c
                            where name!=:userinfo.getUserId()
                            and access_token_part1__c!=null]){
                                odulist.add(od);
                            }        
        System.debug('odulist:'+odulist);
        return odulist;
    }
    
    @AuraEnabled
    public static void removeAllPermissions(OnedriveFolder__c p_odf){       
        //#1 list folder permissions
        String userId=System.Label.Onedrive_JamesClarke_UserId;
        //Userinfo.getUserId();
        OneDrive__c od=OneDrive__c.getValues(userId);        
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
        CreateOdf(odfstr);
        deletePermission(permissionIdset,p_odf.onedrive_Id__c,p_odf.onedrive_driveId__c);
      /*  for(String pId:permissionIdset){
            deletePermission(pId,p_odf.onedrive_Id__c,p_odf.onedrive_driveId__c);            
        } */      
    }
    
    @future(Callout=true)
    public static void deletePermission(Set<String> p_pidset,String p_Id,String p_driveId){
        //#2 delete permissions
        String userId=System.Label.Onedrive_JamesClarke_UserId;
        //Userinfo.getUserId();
        OneDrive__c od=OneDrive__c.getValues(userId);        
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
    }
    
    /*
    @future(Callout=true)
    public static void deletePermission(String p_permissionId,String p_Id,String p_driveId){
        //#2 delete permissions
        String userId=System.Label.Onedrive_JamesClarke_UserId;
        //Userinfo.getUserId();
        OneDrive__c od=OneDrive__c.getValues(userId);        
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
        String driveId=p_driveId;
        String Id=p_Id;
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
    */
    
    @future(Callout=true)    
    public static void CreateOdf(String p_odfstr){
        try{
            OnedriveFolder__c odf=(OnedriveFolder__c)JSON.deserialize(p_odfstr, OnedriveFolder__c.class);
            insert odf;
        }catch(Exception ex){
            System.debug('Exception:'+ex+'\n'+ex.getStackTraceString());
        }
    } 
    @AuraEnabled
    public static String removeAccessAction(String p_recordId, String p_selectedUsers){        
        //  System.debug('p_shareId:'+p_shareId);
        String resp='';
        System.debug('p_recordId:'+p_recordId);
        System.debug('p_selectedUsers:'+p_selectedUsers);
        OneDriveFolder__c odf;
        try{
            odf=getOneDriveFolder(p_recordId);
            if(odf.CreatedById==Userinfo.getUserId()){
                String Id=odf.onedrive_Id__c;
                String driveId=odf.onedrive_driveId__c;
                //#1 list folder permissions
                String userId=System.Label.Onedrive_JamesClarke_UserId;
                //Userinfo.getUserId();
                OneDrive__c od=OneDrive__c.getValues(userId);        
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
                //  String driveId=p_driveId;
                // String Id=p_itemId;
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
                
                // String userId=Userinfo.getUserId();
                if(odf.Shared_With__c==null){
                    odf.Shared_With__c='';
                }     
                
                if(p_selectedUsers!=null){ 
                    if(p_selectedUsers.contains(',')){
                        String[] users=p_selectedUsers.split(',');
                        //prevent duplicates
                        for(String uId:users){
                            if(odf.Shared_With__c.contains(uId)){
                                try{
                                    od=OneDrive__c.getValues(uId); 
                                    if(od!=null && 
                                       od.onedrive_username__c!=null){
                                           String email=od.onedrive_username__c;
                                           removeAccessByEmail(resp1,email,Id,driveId);                        
                                           odf.Shared_With__c=odf.Shared_With__c.replace(getUserName(uId)+'('+uId+')',''); 
                                       }
                                }catch(Exception ex){
                                    System.debug('Exception:'+ex+'\n'+ex.getStackTraceString());
                                }
                            }
                        }
                    }else{
                        if(odf.Shared_With__c.contains(p_selectedUsers)){
                            try{
                                od=OneDrive__c.getValues(p_selectedUsers); 
                                String email=od.onedrive_username__c;
                                removeAccessByEmail(resp1,email,Id,driveId);                        
                                odf.Shared_With__c=odf.Shared_With__c.replace(getUserName(p_selectedUsers)+'('+p_selectedUsers+')',''); 
                            }catch(Exception ex){
                                System.debug('Exception:'+ex);
                            }
                        } 
                    }   
                }
                odf.Shared_With__c=odf.Shared_With__c.trim();
                odf.Shared_With__c=odf.Shared_With__c.removeStart(';');
                update odf; 
            }else{
                resp='Owner only revokes the access';
            }
        }catch(Exception ex){
            system.debug('Exception:'+ex);
        }   
        return resp;
    }
    
    public static void removeAccessByEmail(String p_resp,String p_email,String p_itemId,String p_driveId){
        String resp1=p_resp;
        System.debug(' response :: ' + resp1);
        Map<String,Object> respmap=(Map<String,Object>)JSON.deserializeUntyped(resp1);
        Set<String> permissionIdset=new Set<String>();
        if(respmap!=null && respmap.containsKey('value')){ 
            List<Object> valuelist=(List<Object>)respmap.get('value');   
            for(Object ob:valuelist){
                Map<String,Object> mp=(Map<String,Object>)ob; 
                if(mp!=null){
                    OneDriveItem odi=new OneDriveItem(); 
                    String pId='';
                    if(mp.containsKey('id')){
                        pId=(String)mp.get('id');                       
                    }
                    //check rovoke email matches with user email
                    if(mp.containsKey('grantedTo')){
                        String grantedTo=String.valueOf(mp.get('grantedTo'));
                        if(grantedTo!=null && 
                           p_email!=null &&
                           grantedTo.contains(p_email)){
                               permissionIdset.add(pId);
                           }
                    }
                }
            }                     
        }
        system.debug('permissionIdset:'+permissionIdset);      
         deletePermission(permissionIdset,p_itemId,p_driveId);  
        
      /*  for(String pId:permissionIdset){
            deletePermission(pId,p_itemId,p_driveId);            
        } */
    }
    
    @AuraEnabled
    public static OnedriveFolder__c dogetOneDriveFolder(String p_recordId){  
        OnedriveFolder__c odf=null;
        try{
            odf=getOnedriveFolder(p_recordId);             
        }catch(Exception ex){            
            System.debug('Exception:'+ex+'\n'+ex.getStackTraceString());
        }
        if(odf==null){
            odf=new OnedriveFolder__c();
            String name=getFolderName(p_recordId);            
            try{
                string namestr=name+'%';
                integer autonum=0;
                for(onedrivefolder__c f:[select Id,Name from Onedrivefolder__c where name like :namestr]){
                    if(f.name.startsWith(name+'_')){
                        autonum++;
                    }
                }
                if(autonum!=0){
                    name=name+'_'+autonum;
                }
                
            }catch(Exception ex){
                System.debug('Exception:'+ex+'\n'+ex.getStackTraceString());
            }
            odf.Name=name;
            odf.Owner_Name__c=Userinfo.getName();
        }
        System.debug('odf:'+odf);
        return odf;
    }   
    @AuraEnabled
    public static Onedrive_Permission__c getOneDrivePermission(String p_recordId,OnedriveFolder__c p_odf){
        Onedrive_Permission__c odp;        
        String JamesUserId=System.Label.Onedrive_JamesClarke_UserId;
        try{
            odp=[select can_edit__c,can_view__c,user__c,createdbyId,record_Id__c,onedrivefolder__r.record_Id__c 
                 from onedrive_permission__c
                 where (record_Id__c=:p_recordId OR onedrivefolder__r.record_Id__c=:p_recordId)
                 and user__c=:userinfo.getUserId()
                limit 1];
            if(odp.Can_Edit__c==false || odp.Can_View__c==false || odp.record_Id__c==null || odp.OneDriveFolder__c==null){
                boolean allowupdate=false;
                if(odp.record_Id__c==null){
                	odp.record_Id__c=p_recordId;
                    allowupdate=true;
                }
                if(odp.OneDriveFolder__c==null && p_odf!=null && p_odf.Id!=null){
                    odp.OneDriveFolder__c=p_odf.Id;    
                    allowupdate=true;
                }
                if((odp.Can_Edit__c==false || odp.Can_View__c==false) && 
                   (p_odf.CreatedById==userinfo.getUserId() || userinfo.getUserId()==JamesUserId)){
                    odp.Can_Edit__c=true;
                    odp.Can_View__c=true;
                    allowupdate=true;
                }
                if(allowupdate){
                	update odp;
                }
            }
        }catch(exception ex){
            odp=new Onedrive_Permission__c();           
            odp.user__c=userinfo.getUserId();  
            odp.record_Id__c=p_recordId;
            if(p_odf!=null && p_odf.Id!=null){
                odp.OneDriveFolder__c=p_odf.Id;    
            }
            if((p_odf!=null &&
               p_odf.CreatedById==userinfo.getUserId()) || 
               userinfo.getUserId()==JamesUserId){
                odp.Can_Edit__c=true;
                odp.Can_View__c=true;
            }
            insert odp;           
        }
        return odp;
    }
    public class OnedriveWrapper{
        @AuraEnabled
        public OneDriveFolder__c odf;
        @AuraEnabled
        public Onedrive_Permission__c odp;
        @AuraEnabled
        public boolean connected;
        @AuraEnabled
        public List<OneDriveItem> odilist;        
    }
}