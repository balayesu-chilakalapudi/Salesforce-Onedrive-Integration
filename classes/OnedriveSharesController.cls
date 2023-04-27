public class OnedriveSharesController {
    @AuraEnabled
    public static List<ODFWrapper> getFolders(String p_recordId){
        String userId=Userinfo.getUserId();
        String shares='%'+userId+'%';
        String recname='%'+p_recordId+'%';
        List<ODFWrapper> odfwraplist=new List<ODFWrapper>();
        Boolean isfoldercreated=false;
       // List<OneDriveFolder__c> odflist=new List<OneDriveFolder__c>();
        for(OneDriveFolder__c odf:[select Id,Name,Shared_with__c,createddate,createdbyId,createdby.name
                                   From OnedriveFolder__c
                                   Where Name like :recname]){
                                       if(odf.createdbyId==userId ||
                                          (odf.shared_with__c!=null && odf.Shared_With__c.contains(userId))
                                         ){
                                             ODFWrapper odw=new ODFWrapper();
                                             odw.odfolder=odf;
                                             odfwraplist.add(odw);
                                             if(odf.createdbyId==userId){
                                                 isfoldercreated=true;
                                             }
                                         }
                                   }
        if(!isfoldercreated){
            ODFWrapper odw=new ODFWrapper();
            OneDriveFolder__c odf=addOnedriveFolder(p_recordId);
            String odfId=odf.Id;
            //query odf
            try{
            	odf=[select Id,Name,Shared_with__c,createddate,createdbyId,createdby.name
                                   From OnedriveFolder__c
                                   Where Id=:odfId];
            }catch(Exception ex){
                system.debug('Exception:'+ex);
            }
            odw.odfolder=odf;
            odfwraplist.add(odw);
        }
        return odfwraplist;
    }
    @AuraEnabled
    public static String loadFiles(String p_recordId,String p_folderId){
        //System.debug('odfwlist:'+odfwlist);
        String result='';        
        OnedriveFolder__c odf=getOneDriveFolderByFolderId(p_recordId,p_folderId); 
        System.debug('loadFiles > odf:'+odf);
        if(odf!=null &&
           odf.onedrive_id__c!=null){
               // list all files and folders  			  
               result=JSON.serialize(listFiles(odf));        
           }    
        else{
            // result='ERROR:Folder not created yet';
          //  addOnedriveFolder(p_recordId);
        }
        return result;
    }    
    public static OnedriveFolder__c getOneDriveFolderByFolderId(String p_recordId,String p_folderId){ 
        String createdbyId=getCreatedById(p_folderId);
        String name=getFolderName(p_recordId);       
        OneDriveFolder__c odf=null;
        if(!createdbyId.equals('') && !name.equals('')){
            try{
                odf=[select onedrive_driveId__c, onedrive_id__c,Shared_With__c,createdbyId
                     from OneDriveFolder__c 
                     where createdbyId=:createdbyId
                    and name=:name];   
            }catch(Exception ex){
                System.debug('Exception: '+ex);
                //create folder, skip here
                // odf=addOnedriveFolder(p_recordId);
            }
        }
        return odf;
    }
    public static OnedriveFolder__c getOneDriveFolderByRecordId(String p_recordId){        
        String name=getFolderName(p_recordId);       
        System.debug('getOnedriveFolder > name:'+name);
        OneDriveFolder__c odf=null;
        if(!name.equals('')){
            try{
                odf=[select onedrive_driveId__c, onedrive_id__c,Shared_With__c,createdbyId
                     from OneDriveFolder__c 
                     where Name=:name
                     and createdbyId=:userinfo.getuserId()];   
            }catch(Exception ex){
                System.debug('Exception: '+ex);
                //create folder, skip here
                // odf=addOnedriveFolder(p_recordId);
            }
        }
        return odf;
    }
    @AuraEnabled
    public static List<OneDriveItem> listFiles(OneDriveFolder__c odf){
        String id=odf.onedrive_id__c;
        String driveId=odf.onedrive_driveId__c;
        String userId=odf.CreatedById;
            //Userinfo.getUserId();
        OneDrive__c od=OneDrive__c.getValues(userId);        
        String client_id=od.client_id__c;
        String redirect_uri=od.redirect_uri__c;
        String client_secret=od.client_secret__c; 
        //Access token
        String acc_expected_str=(od.access_token_part1__c+od.access_token_part2__c+od.access_token_part3__c+od.access_token_part4__c+od.access_token_part5__c+od.access_token_part6__c+od.access_token_part7__c);
        if(acc_expected_str.contains('null')){
            acc_expected_str=acc_expected_str.replace('null', '');
        }
        acc_expected_str=acc_expected_str.trim();
        String access_token=acc_expected_str;
        
        //create Folder 
        HttpRequest req1 = new HttpRequest();
        //LHGlobalAPI = 530BAD846FC1648C!115, top level folder
        String endpoint='https://graph.microsoft.com/v1.0/me/drives/'+driveId+'/items/'+id+'/children';
        req1.setEndpoint(endpoint);            
        //  String parameters = '{\"name\":\"'+p_recordId+'\",\"folder\":{}}';
        //  System.debug('parameters: '+parameters);
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
                        odi.size=(Integer)mp.get('size');
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
                    itemlist.add(odi);
                }
            }
        } 
        system.debug('itemlist:'+itemlist);
        return itemlist;
    }
    public class OneDriveItem{
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Integer size;
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
        public String parId;        
    }
    public static String getFolderName(String p_recordId){
        String name='';
        try{
            Id myId=Id.valueOF(p_recordId);
            //get sobjectname
            String sObjName = myId.getSObjectType().getDescribe().getName();
            System.debug('sobjectname:'+sObjName);
            name=sObjName+'_'+p_recordId;
        }catch(Exception ex){
            System.debug('Exception:'+ex);
        }
        return name;
    } 
    public static String getcreatedById(String p_folderId){
        String result='';
         Id myId=Id.valueOF(p_folderId);
            //get sobjectname
         String sObjName = myId.getSObjectType().getDescribe().getName();
        try{
            String query='select Id,createdbyId from onedrivefolder__c where Id=\''+p_folderId+'\' limit 1';
            System.debug('query:'+query);
         	onedrivefolder__c odf=(onedrivefolder__c)Database.query(query)[0];
            result=odf.CreatedById;
        }catch(Exception ex){
            System.debug('Exception:'+ex);
        }
        return result;
    }
    public class ODFWrapper{
        @AuraEnabled
        public OneDriveFolder__c odfolder;
        @AuraEnabled
        public List<OneDriveItem> oditemlist;
    }
    @AuraEnabled
    public static OneDriveFolder__c addOnedriveFolder(String p_recordId){
        System.debug('createFolder > foldername:'+p_recordId);
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
        
        //create Folder 
        HttpRequest req1 = new HttpRequest();
        //LHGlobalAPI = 530BAD846FC1648C!115, top level folder
        String endpoint='https://graph.microsoft.com/v1.0/me/drive/items/'+LHGlobalAPI_FolderId+'/children';
        req1.setEndpoint(endpoint);
        String name=getFolderName(p_recordId);
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
        odf.name=name;
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
        insert odf;
        return odf;
    }
    @future(Callout=true)
    public static void saveToOneDrive(String fileName,Blob p_data, String p_recordId, String cdocId) {
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
        String userId=UserInfo.getUserId();
        OneDrive__c od=OneDrive__c.getValues(userId);        
        String client_id=od.client_id__c;
        String redirect_uri=od.redirect_uri__c;
        String client_secret=od.client_secret__c; 
        //Access token
        String acc_expected_str=(od.access_token_part1__c+od.access_token_part2__c+od.access_token_part3__c+od.access_token_part4__c+od.access_token_part5__c+od.access_token_part6__c+od.access_token_part7__c);
        if(acc_expected_str.contains('null')){
            acc_expected_str=acc_expected_str.replace('null', '');
        }
        acc_expected_str=acc_expected_str.trim();
        String access_token=acc_expected_str;
        
        OnedriveFolder__c odf=getOneDriveFolderByRecordId(p_recordId);       
        String id=odf.onedrive_Id__c;
        String driveId=odf.onedrive_driveId__c;
        String foldername=getFolderName(p_recordId);
        //create Folder 
        HttpRequest req1 = new HttpRequest();
        //LHGlobalAPI = 530BAD846FC1648C!115, top level folder
        String endpoint='https://graph.microsoft.com/v1.0/drive/root:/LHGlobalAPI/'+foldername+'/'+fileName+':/createUploadSession';            
        System.debug('endpoint:'+endpoint);
        req1.setEndpoint(endpoint);            
        String parameters = '{'+
            '\"item\": {'+
            '\"@odata.type\": \"microsoft.graph.driveItemUploadableProperties\",'+
            '\"@microsoft.graph.conflictBehavior\": \"rename\",'+
            '\"name\": \"'+fileName+'\"'+
            '}'+
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
                Integer chunksize=fileSize/10;
                req2.setHeader('Content-Length',String.valueOf(fileSize));
                String contentrange='bytes 0-'+fileSize;
                System.debug('content range:'+contentrange);
                System.debug('chunksize:'+chunksize);
                // req2.setHeader('Content-Range', contentrange);
                req2.setHeader('Accept', 'application/json');
                ///Blob cblob = data;
                req2.setBodyAsBlob(data);
                
                Http h2 = new Http();
                HttpResponse res2 = h2.send(req2);
                string resp2 = res2.getBody();
                System.debug(' response :: ' + resp2);
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
        List<ContentVersion> cvlist=new List<ContentVersion>();
        for(ContentVersion cv:[SELECT Id, VersionData, ContentDocumentId, Title, FileExtension 
                               FROM ContentVersion
                               WHERE ContentDocumentId IN:fileIdset]){
                                   //  cvlist.add(cv);
                                   saveToOneDrive(cv.Title+'.'+cv.FileExtension,cv.versiondata,recordId,cv.ContentDocumentId);
                               }       
    }
       
    @AuraEnabled
    public static void shareFolderWithUser(String p_shareId,String p_recordId){
        System.debug('p_shareId:'+p_shareId);
        System.debug('p_recordId:'+p_recordId);
        OneDriveFolder__c odf;
        try{
            odf=getOneDriveFolderByRecordId(p_recordId);
            odf.Shared_With__c+=';'+p_shareId;
            update odf;
        }catch(Exception ex){
            system.debug('Exception:'+ex);
        }
    }
}