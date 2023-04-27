public class OneDrivePageController
{
    //Fetched from URL
    public String code ;
    
    public OneDrivePageController()
    {
       
    }
    
    public PageReference OneDriveAuth()
    {
         code = ApexPages.currentPage().getParameters().get('code') ;
        
        //Get the access token once we have code 
        if(code != '' && code != null)
        {
            AccessToken() ;
            String pageUrl=System.Label.HomePageUrl;
            return new PageReference(pageUrl);
        }        
      
        String userId=Userinfo.getUserId();
        String page_url='';
        try{
        OneDrive__c od=OneDrive__c.getValues(userId);        
        String client_id=od.client_id__c;
        String redirect_uri=od.redirect_uri__c;
        String client_secret=od.client_secret__c;  
       // String resource=od.resource__c;
        
         page_url='https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id='+client_id+
            '&scope=offline_access files.readwrite.all Files.ReadWrite.AppFolder&response_type=code&redirect_uri='+redirect_uri;
        }catch(Exception ex){
            page_url='/apex/OnedriveContactAdmin';
        }
        //Authenticating
        PageReference pg = new PageReference(page_url);            
        return pg ;
    }
    
    public void AccessToken()
    {
        String userId=Userinfo.getUserId();
        OneDrive__c od=OneDrive__c.getValues(userId);        
        String client_id=od.client_id__c;
        String redirect_uri=od.redirect_uri__c;
        String client_secret=od.client_secret__c;    
     //   String resource=od.resource__c;
        
        System.debug('code:'+code);
        //Getting access token from dropbox
        String tokenuri = 'https://login.microsoftonline.com/common/oauth2/v2.0/token';
        String params='grant_type=authorization_code&code='+code+'&redirect_uri='+redirect_uri+'&client_id='+client_id+'&client_secret='+client_secret;
           // '&resource='+resource;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenuri);
        req.setMethod('POST');
        req.setTimeout(60*1000);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');  
        req.setBody(params);
        
        Blob headerValue = Blob.valueOf(client_id + ':' + client_secret);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        
        System.debug(' You can parse the response to get the access token ::: ' + resp);
        String access_token='';
        String refresh_token='';
        //parse the access token
        JSONParser parser = JSON.createParser(resp);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                if(fieldName == 'access_token') {
                    access_token = parser.getText();
                } 
                if(fieldName == 'refresh_token') {
                    refresh_token = parser.getText();
                } 
            }
        }
        System.debug('access_token: '+access_token);
        System.debug('refresh_token: '+refresh_token);
        try{
        	getAccessToken(access_token,refresh_token,code,true,userId);
        }catch(Exception ex){
            System.debug('Exception:'+ex+'\n'+ex.getStackTraceString());
        }
    }
    
    //update accesstoken and code by calling this method
    // OneDrivePageController.getAccessToken(p_accesstoken,p_refreshtoken,p_code,'');
    public static void getAccessToken(String accesstoken,String refreshtoken,String code,Boolean allowupdate,String p_userId){
        String userId=p_userId;
            //UserInfo.getUserId();
        OneDrive__c od=OneDrive__c.getValues(userId);        
        String client_id=od.client_id__c;
        String redirect_uri=od.redirect_uri__c;
        String client_secret=od.client_secret__c;
       // od.code__c=code;
      //  od.access_token_part1__c=accesstoken; 
        //reset tokens first
       // if(accesstoken.equals('')){
            od.access_token_part1__c='';             od.access_token_part2__c='';              od.access_token_part3__c='';             od.access_token_part4__c='';            od.access_token_part5__c='';             od.access_token_part6__c='';              od.access_token_part7__c='';
            od.access_token_part8__c='';             od.access_token_part9__c='';              od.access_token_part10__c='';            od.access_token_part11__c='';           od.access_token_part12__c='';            od.access_token_part13__c='';             od.access_token_part14__c=''; 
       // }
       // if(refreshtoken.equals('')){
            od.refresh_token_part1__c='';            od.refresh_token_part2__c='';            od.refresh_token_part3__c='';            od.refresh_token_part4__c='';
            od.refresh_token_part5__c='';            od.refresh_token_part6__c='';            od.refresh_token_part7__c='';
      //  }
        // if(code.equals('')){
            od.code_part1__c='';            od.code_part2__c='';            od.code_part3__c='';            od.code_part4__c='';            od.code_part5__c='';
            od.code_part6__c='';            od.code_part7__c='';
      //  }
        if(accesstoken.length()>0){
            if(accesstoken.length()>250)
                od.access_token_part1__c=accesstoken.subString(0,250);
            else
                od.access_token_part1__c=accesstoken.subString(0,accesstoken.length());
        }
        if(accesstoken.length()>250){
            if(accesstoken.length()>500)
                od.access_token_part2__c=accesstoken.subString(250,500);
            else
                od.access_token_part2__c=accesstoken.subString(250,accesstoken.length());
        }
        if(accesstoken.length()>500){
            if(accesstoken.length()>750)
                od.access_token_part3__c=accesstoken.subString(500,750);
            else
                od.access_token_part3__c=accesstoken.subString(500,accesstoken.length());
        }
        if(accesstoken.length()>750){
            if(accesstoken.length()>1000)
                od.access_token_part4__c=accesstoken.subString(750,1000);
            else
                od.access_token_part4__c=accesstoken.subString(750,accesstoken.length());
        }	
        if(accesstoken.length()>1000){
            if(accesstoken.length()>1250)
                od.access_token_part5__c=accesstoken.subString(1000,1250);
            else
                od.access_token_part5__c=accesstoken.subString(1000,accesstoken.length());
        }
        if(accesstoken.length()>1250){
            if(accesstoken.length()>1500)
                od.access_token_part6__c=accesstoken.subString(1250,1500);
            else
                od.access_token_part6__c=accesstoken.subString(1250,accesstoken.length());
            
        }
        if(accesstoken.length()>1500){
            if(accesstoken.length()>1750)
                od.access_token_part7__c=accesstoken.subString(1500,1750);
            else
                od.access_token_part7__c=accesstoken.subString(1500,accesstoken.length());
        }
        if(accesstoken.length()>1750){
            if(accesstoken.length()>2000)
                od.access_token_part8__c=accesstoken.subString(1750,2000);
            else
                od.access_token_part8__c=accesstoken.subString(1750,accesstoken.length());
        }
        if(accesstoken.length()>2000){
            if(accesstoken.length()>2250)
                od.access_token_part9__c=accesstoken.subString(2000,2250);
            else
                od.access_token_part9__c=accesstoken.subString(2000,accesstoken.length());
        }
        if(accesstoken.length()>2250){
            if(accesstoken.length()>2500)
                od.access_token_part10__c=accesstoken.subString(2250,2500);
            else
                od.access_token_part10__c=accesstoken.subString(2250,accesstoken.length());
        }
        if(accesstoken.length()>2500){
            if(accesstoken.length()>2750)
                od.access_token_part11__c=accesstoken.subString(2500,2750);
            else
                od.access_token_part11__c=accesstoken.subString(2500,accesstoken.length());
        }
        if(accesstoken.length()>2750){
            if(accesstoken.length()>3000)
                od.access_token_part12__c=accesstoken.subString(2750,3000);
            else
                od.access_token_part12__c=accesstoken.subString(2750,accesstoken.length());
        }
        if(accesstoken.length()>3000){
            if(accesstoken.length()>3250)
                od.access_token_part13__c=accesstoken.subString(3000,3250);
            else
                od.access_token_part13__c=accesstoken.subString(3000,accesstoken.length());
        }
        if(accesstoken.length()>3250){
            if(accesstoken.length()>3500)
                od.access_token_part14__c=accesstoken.subString(3250,3500);
            else
                od.access_token_part14__c=accesstoken.subString(3250,accesstoken.length());
        }
      // od.refresh_token_part1__c=refreshtoken;        
        if(refreshtoken.length()>0){
            if(refreshtoken.length()>250)
                od.refresh_token_part1__c=refreshtoken.subString(0,250);
            else
                od.refresh_token_part1__c=refreshtoken.subString(0,refreshtoken.length());
        }
        if(refreshtoken.length()>250){
            if(refreshtoken.length()>500)
                od.refresh_token_part2__c=refreshtoken.subString(250,500);
            else
                od.refresh_token_part2__c=refreshtoken.subString(250,refreshtoken.length());
        }
        if(refreshtoken.length()>500){
            if(accesstoken.length()>750)
                od.refresh_token_part3__c=refreshtoken.subString(500,750);
            else
                od.refresh_token_part3__c=refreshtoken.subString(500,refreshtoken.length());
        }
        if(refreshtoken.length()>750){
            if(refreshtoken.length()>1000)
                od.refresh_token_part4__c=refreshtoken.subString(750,1000);
            else
                od.refresh_token_part4__c=refreshtoken.subString(750,refreshtoken.length());
        }	
        if(refreshtoken.length()>1000){
            if(refreshtoken.length()>1250)
                od.refresh_token_part5__c=refreshtoken.subString(1000,1250);
            else
                od.refresh_token_part5__c=refreshtoken.subString(1000,refreshtoken.length());
        }
        if(refreshtoken.length()>1250){
            if(refreshtoken.length()>1500)
                od.refresh_token_part6__c=refreshtoken.subString(1250,1500);
            else
                od.refresh_token_part6__c=refreshtoken.subString(1250,refreshtoken.length());
            
        }
        if(refreshtoken.length()>1500){
            if(refreshtoken.length()>1750)
                od.refresh_token_part7__c=refreshtoken.subString(1500,1750);
            else
                od.refresh_token_part7__c=refreshtoken.subString(1500,refreshtoken.length());
        }
        
         if(code.length()>0){
            if(code.length()>250)
                od.code_part1__c=code.subString(0,250);
            else
                od.code_part1__c=code.subString(0,code.length());
        }
        if(code.length()>250){
            if(code.length()>500)
                od.code_part2__c=code.subString(250,500);
            else
                od.code_part2__c=code.subString(250,code.length());
        }
        if(code.length()>500){
            if(code.length()>750)
                od.code_part3__c=code.subString(500,750);
            else
                od.code_part3__c=code.subString(500,code.length());
        }
        if(code.length()>750){
            if(code.length()>1000)
                od.code_part4__c=code.subString(750,1000);
            else
                od.code_part4__c=code.subString(750,code.length());
        }	
        if(code.length()>1000){
            if(code.length()>1250)
                od.code_part5__c=code.subString(1000,1250);
            else
                od.code_part5__c=code.subString(1000,code.length());
        }
        if(code.length()>1250){
            if(code.length()>1500)
                od.code_part6__c=code.subString(1250,1500);
            else
                od.code_part6__c=code.subString(1250,code.length());
            
        }
        if(code.length()>1500){
            if(code.length()>1750)
                od.code_part7__c=code.subString(1500,1750);
            else
                od.code_part7__c=code.subString(1500,code.length());
        }
        
        System.debug('access_token_part1__c:'+od.access_token_part1__c);
        System.debug('access_token_part2__c:'+od.access_token_part2__c);
        System.debug('access_token_part3__c:'+od.access_token_part3__c);
        System.debug('access_token_part4__c:'+od.access_token_part4__c);
        System.debug('access_token_part5__c:'+od.access_token_part5__c);
        System.debug('access_token_part6__c:'+od.access_token_part6__c);
        System.debug('access_token_part7__c:'+od.access_token_part7__c);
        System.debug('access_token_part8__c:'+od.access_token_part8__c);
        System.debug('access_token_part9__c:'+od.access_token_part9__c);
        System.debug('access_token_part10__c:'+od.access_token_part10__c);
        System.debug('access_token_part11__c:'+od.access_token_part11__c);
        System.debug('access_token_part12__c:'+od.access_token_part12__c);
        System.debug('access_token_part13__c:'+od.access_token_part13__c);
        System.debug('access_token_part14__c:'+od.access_token_part14__c);
        
        System.debug('refresh_token_part1__c:'+od.refresh_token_part1__c);
        System.debug('refresh_token_part2__c:'+od.refresh_token_part2__c);
        System.debug('refresh_token_part3__c:'+od.refresh_token_part3__c);
        System.debug('refresh_token_part4__c:'+od.refresh_token_part4__c);
        System.debug('refresh_token_part5__c:'+od.refresh_token_part5__c);
        System.debug('refresh_token_part6__c:'+od.refresh_token_part6__c);
        System.debug('refresh_token_part7__c:'+od.refresh_token_part7__c); 
        
        System.debug('code_part1__c:'+od.code_part1__c);
        System.debug('code_part2__c:'+od.code_part2__c);
        System.debug('code_part3__c:'+od.code_part3__c);
        System.debug('code_part4__c:'+od.code_part4__c);
        System.debug('code_part5__c:'+od.code_part5__c);
        System.debug('code_part6__c:'+od.code_part6__c);
        System.debug('code_part7__c:'+od.code_part7__c);
        
        if(allowupdate){
        	update od;
        }
    } 
    public static String getToken(String str){
        String result='';
        if(str!=null){
            result=str.trim();
        }
        return result;
    }
    
    
    @future(Callout=true)
    public static void doRefreshToken(String p_userId){ 
        String userId=p_userId;
            //Userinfo.getUserId();
        OneDrive__c od=OneDrive__c.getValues(userId);        
        String client_id=od.client_id__c;
        String redirect_uri=od.redirect_uri__c;
        String client_secret=od.client_secret__c; 
      //  String resource=od.resource__c;
        
        //Access token
         String acc_expected_str=(od.access_token_part1__c+od.access_token_part2__c+od.access_token_part3__c+od.access_token_part4__c+od.access_token_part5__c+od.access_token_part6__c+od.access_token_part7__c+
                                 od.access_token_part8__c+od.access_token_part9__c+od.access_token_part10__c+od.access_token_part11__c+od.access_token_part12__c+od.access_token_part13__c+od.access_token_part14__c);
        if(acc_expected_str.contains('null')){
            acc_expected_str=acc_expected_str.replace('null', '');
        }
        acc_expected_str=acc_expected_str.trim();
        String access_token=acc_expected_str;
        
        //refresh token
         String refresh_expected_str=(od.refresh_token_part1__c+od.refresh_token_part2__c+od.refresh_token_part3__c+od.refresh_token_part4__c+od.refresh_token_part5__c+od.refresh_token_part6__c+od.refresh_token_part7__c);
        if(refresh_expected_str.contains('null')){
            refresh_expected_str=refresh_expected_str.replace('null', '');
        }
        refresh_expected_str=refresh_expected_str.trim();       
        String refresh_token=refresh_expected_str;
        
        //code
         String code_expected_str=(od.code_part1__c+od.code_part2__c+od.code_part3__c+od.code_part4__c+od.code_part5__c+od.code_part6__c+od.code_part7__c);
        if(code_expected_str.contains('null')){
            code_expected_str=code_expected_str.replace('null', '');
        }
        code_expected_str=code_expected_str.trim();        
        String code=code_expected_str;
       
        System.debug('code:'+code);
       // System.debug('refresh_token'+refresh_token);
       // System.debug('access_token'+access_token);
        
        //Getting access token from dropbox
         String tokenuri='';
        // endpoints are different for business and personal accounts
        if(od.Is_Business_Account__c){
             tokenuri='https://login.microsoftonline.com/common/oauth2/token';
        }else{
            tokenuri = 'https://login.live.com/oauth20_token.srf';
        }        
        String params='client_id='+client_id+'&redirect_uri='+redirect_uri+'&client_secret='+client_secret+'&refresh_token='+refresh_token+'&grant_type=refresh_token';
           // '&resource='+resource;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenuri);
        req.setMethod('POST');
        req.setTimeout(60*1000);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');   
        req.setBody(params);
        
        Blob headerValue = Blob.valueOf(client_id + ':' + client_secret);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        
        System.debug(' You can parse the response to get the access token ::: ' + resp);        
        access_token='';
        refresh_token='';
        
        //parse the access token
        JSONParser parser = JSON.createParser(resp);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                if(fieldName == 'access_token') {
                    access_token = parser.getText();
                }
                if(fieldName == 'refresh_token') {
                    refresh_token = parser.getText();
                }
            }
        }
        System.debug('refresh_token: '+refresh_token);
        System.debug('access_token: '+access_token);
        getAccessToken(access_token,refresh_token,code,true,userId);
    }
   /* public static void getServiceDetails(String p_userId){
         String userId=p_userId;
            //Userinfo.getUserId();
        OneDrive__c od=OneDrive__c.getValues(userId);        
        String client_id=od.client_id__c;
        String redirect_uri=od.redirect_uri__c;
        String client_secret=od.client_secret__c; 
        String resource=od.resource__c;
        
        //Access token
         String acc_expected_str=(od.access_token_part1__c+od.access_token_part2__c+od.access_token_part3__c+od.access_token_part4__c+od.access_token_part5__c+od.access_token_part6__c+od.access_token_part7__c);
        if(acc_expected_str.contains('null')){
            acc_expected_str=acc_expected_str.replace('null', '');
        }
        acc_expected_str=acc_expected_str.trim();
        String access_token=acc_expected_str;
        
        //refresh token
         String refresh_expected_str=(od.refresh_token_part1__c+od.refresh_token_part2__c+od.refresh_token_part3__c+od.refresh_token_part4__c+od.refresh_token_part5__c+od.refresh_token_part6__c+od.refresh_token_part7__c);
        if(refresh_expected_str.contains('null')){
            refresh_expected_str=refresh_expected_str.replace('null', '');
        }
        refresh_expected_str=refresh_expected_str.trim();       
        String refresh_token=refresh_expected_str;
        
        //code
         String code_expected_str=(od.code_part1__c+od.code_part2__c+od.code_part3__c+od.code_part4__c+od.code_part5__c+od.code_part6__c+od.code_part7__c);
        if(code_expected_str.contains('null')){
            code_expected_str=code_expected_str.replace('null', '');
        }
        code_expected_str=code_expected_str.trim();        
        String code=code_expected_str;
       
        System.debug('code:'+code);
       // System.debug('refresh_token'+refresh_token);
       // System.debug('access_token'+access_token);
        
        //Getting access token from dropbox
      //  String tokenuri = 'https://login.live.com/oauth20_token.srf';
         String tokenuri='https://api.office.com/discovery/v2.0/me/services';
      //  String params='client_id='+client_id+'&redirect_uri='+redirect_uri+'&client_secret='+client_secret+'&refresh_token='+refresh_token+'&grant_type=refresh_token'+
        //    '&resource='+resource;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenuri);
        req.setMethod('POST');
        req.setTimeout(60*1000);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');   
     //   req.setBody(params);
        
       // Blob headerValue = Blob.valueOf(client_id + ':' + client_secret);
       // String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
       // req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Authorization', 'Bearer ' + access_token);
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();        
        System.debug(' You can parse the response to get the access token ::: ' + resp); 
    }
     public static void getOneDriveDetails(String p_userId){
         String userId=p_userId;
            //Userinfo.getUserId();
        OneDrive__c od=OneDrive__c.getValues(userId);        
        String client_id=od.client_id__c;
        String redirect_uri=od.redirect_uri__c;
        String client_secret=od.client_secret__c; 
        String resource=od.resource__c;
        
        //Access token
         String acc_expected_str=(od.access_token_part1__c+od.access_token_part2__c+od.access_token_part3__c+od.access_token_part4__c+od.access_token_part5__c+od.access_token_part6__c+od.access_token_part7__c);
        if(acc_expected_str.contains('null')){
            acc_expected_str=acc_expected_str.replace('null', '');
        }
        acc_expected_str=acc_expected_str.trim();
        String access_token=acc_expected_str;
        
        //refresh token
         String refresh_expected_str=(od.refresh_token_part1__c+od.refresh_token_part2__c+od.refresh_token_part3__c+od.refresh_token_part4__c+od.refresh_token_part5__c+od.refresh_token_part6__c+od.refresh_token_part7__c);
        if(refresh_expected_str.contains('null')){
            refresh_expected_str=refresh_expected_str.replace('null', '');
        }
        refresh_expected_str=refresh_expected_str.trim();       
        String refresh_token=refresh_expected_str;
        
        //code
         String code_expected_str=(od.code_part1__c+od.code_part2__c+od.code_part3__c+od.code_part4__c+od.code_part5__c+od.code_part6__c+od.code_part7__c);
        if(code_expected_str.contains('null')){
            code_expected_str=code_expected_str.replace('null', '');
        }
        code_expected_str=code_expected_str.trim();        
        String code=code_expected_str;
       
        System.debug('code:'+code);
       // System.debug('refresh_token'+refresh_token);
       // System.debug('access_token'+access_token);
        
        //Getting access token from dropbox
      //  String tokenuri = 'https://login.live.com/oauth20_token.srf';
         String tokenuri='https://api.office.com/discovery/v2.0/me/services';
      //  String params='client_id='+client_id+'&redirect_uri='+redirect_uri+'&client_secret='+client_secret+'&refresh_token='+refresh_token+'&grant_type=refresh_token'+
        //    '&resource='+resource;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenuri);
        req.setMethod('POST');
        req.setTimeout(60*1000);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');   
     //   req.setBody(params);
        
       // Blob headerValue = Blob.valueOf(client_id + ':' + client_secret);
       // String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
       // req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Authorization', 'Bearer ' + access_token);
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();        
        System.debug(' You can parse the response to get the access token ::: ' + resp); 
    } */
}