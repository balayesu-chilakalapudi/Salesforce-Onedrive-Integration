({
    scriptsLoaded : function(component, event, helper) {
		//console.log('load successfully');       
       // active/call select2 plugin function after load jQuery and select2 plugin successfully    
       $(".select2Class").select2({
           placeholder: "Select Multiple values"
       });
	},
    doInit: function(component, event, helper){       
        helper.checkForChanges(component,event); 
    },
    handleUploadFinished: function (component, event,helper) {         
         component.set("v.isModalOpen",false);  
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        var entrylist=component.get("v.entrylist");
        var totalfiles=uploadedFiles.length+entrylist.length;
        console.log('totalfiles:'+totalfiles);
       // component.set("v.docslist",uploadedFiles);
         console.log("Files uploaded : " + JSON.stringify(uploadedFiles));
      //  component.set("v.showProgress",true);
         var action = component.get("c.saveUploads");
        action.setParams({
            recordId: component.get("v.recordId"),
            uploadedFiles: JSON.stringify(uploadedFiles)
        });
        action.setCallback(this, function(a) {
            helper.checkForChanges(component,event); 
            component.set("v.isuploadfinishedModalOpen",true);
        });            
     	$A.enqueueAction(action);        
    },
    toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },
    addFolder:function(component,event,helper){
        console.log('addFolder success');
        var action = component.get("c.addOnedriveFolder");
        action.setParams({ p_recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state:'+state);
            if (state === "SUCCESS") {   
                component.set("v.showAddFolder",false);
               
            }
        });
        $A.enqueueAction(action);
    },
    addFile:function(component,event,helper){
        console.log('addFile success');
        component.set("v.isModalOpen",true);
    },
    closeModel:function(component,event,helper){
        component.set("v.isModalOpen",false);
        component.set("v.isuploadfinishedModalOpen",false);
        component.set("v.showSharedModalOpen",false);
    },    
    shareFolderWithMultiple:function(component,event,helper){
        component.set("v.isShareModalOpen",true);       
    },
    shareFolderWithAllLHGlobalUsers : function(component,event,helper){
        var action = component.get("c.shareWithAllLHGlobalUsers");
        action.setParams({ p_recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Folder has been shared successfully."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    closeShareModel:function(component,event,helper){
        component.set("v.isShareModalOpen",false);        
    },
    authOneDrive:function(component,event,helper){
        window.open("https://jamesclarke.my.salesforce.com/apex/OneDrivePage","_self");
     //  window.open("https://lightning-sandbox--lightning--c.cs72.visual.force.com/apex/OneDrivePage","_self");
        /*  var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": 'https://lightning-sandbox--lightning--c.cs72.visual.force.com/apex/OneDrivePage?core.apexpages.request.devconsole=1'
            });
            urlEvent.fire(); */
    }   ,
    doSync:function(component,event,helper){
        helper.checkForChanges(component,event); 
    },
     openPath : function(component,event,helper){
        console.log('openPath success');     
         try{
         var action = component.get("c.loadFiles");
            action.setParams({ p_recordId : component.get("v.recordId") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    try{
                    component.set("v.entrylist",JSON.parse(response.getReturnValue()));                    
                    console.log('entrylist: '+JSON.stringify(component.get("v.entrylist")));                  
                    component.set("v.showSpinner",false);                    
                    $A.get('e.force:refreshView').fire();
                    }catch(err){
                        console.log(err.stack);
                    }
                }
            });
            $A.enqueueAction(action);
         }catch(err){
             console.log(err.stack);
         }
    },
    openItem: function(component,event,helper){
        console.log('openItem success');
        try{
        var item=event.target.id;
        var itemob=item.split(';');
        var driveId=itemob[0];
        var id=itemob[1];
       // var path_lower=itemob[2];
        var folderpath=component.get("v.folderpath");       
      //  folderpath.push({name:name, value:path_lower});
      //  component.set("v.folderpath",folderpath);
       // alert('item:'+item);
       //check if it is folder
       
              var action = component.get("c.loadFolder");
            action.setParams({ p_driveId : driveId,
                              p_Id: id});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    try{
                    component.set("v.entrylist",JSON.parse(response.getReturnValue()));                    
                    console.log('entrylist: '+JSON.stringify(component.get("v.entrylist")));                  
                    component.set("v.showSpinner",false);                    
                    $A.get('e.force:refreshView').fire();
                    }catch(err){
                        console.log(err.stack);
                    }
                }
            });
            $A.enqueueAction(action);
        }catch(err){
            console.log(err.stack);
        }
    },
    showShareDetails:function(component,event,helper){
        console.log('showShareDetails success');
        component.set("v.showSharedModalOpen",true);
    },
    doRequestForShare:function(component,event,helper){
        console.log('doRequestForShare success');
          var action = component.get("c.sendRequestForShare");
        action.setParams({ p_odf:component.get("v.OnedriveFolder"),
                          p_recordId : component.get("v.recordId") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state:'+state);
                if (state === "SUCCESS") {
                    var resp=response.getReturnValue();
                      var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": ""+resp
                });
                toastEvent.fire();
                }
            });
        $A.enqueueAction(action);
    },
    doRevoke: function(component,event,helper){        
        component.set("v.isRevokeModalOpen",true);
    },
    closeRevokeModel:function(component,event,helper){
		component.set("v.isRevokeModalOpen",false);
	},
    doGrant: function(component,event,helper){        
        component.set("v.isGrantModalOpen",true);
    },
    closeGrantModel:function(component,event,helper){
		component.set("v.isGrantModalOpen",false);
	},
    closeGrantAccessEvent:function(component,event,helper){
         var closevalue = event.getParam("closeModel");
        component.set("v.isGrantModalOpen",closevalue);
    }
})