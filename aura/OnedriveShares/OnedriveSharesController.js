({
    init: function(component, event, helper) {
         var action = component.get("c.getFolders");
            action.setParams({ p_recordId : component.get("v.recordId") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.items",response.getReturnValue());
                    console.log('items: '+JSON.stringify(component.get("v.items"))); 
                }
            });
            $A.enqueueAction(action);
    },
    toggle: function(component, event, helper) {
        var items = component.get("v.items"), index = event.getSource().get("v.value");
        items[index].expanded = !items[index].expanded;
        console.log('item name:'+items[index].odfolder.Name);
        var itemname=items[index].odfolder.Name;
        var itemId=items[index].odfolder.Id;
        var folderrecordId='';
        var folderId=itemId;
        if(itemname!=null && itemname.includes('_')){
            var itm=itemname.split('_');
            folderrecordId=itm[1];
        } 
        component.set("v.items", items);
        var action = component.get("c.loadFiles");
        action.setParams({p_recordId:folderrecordId,
                          p_folderId:folderId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state:'+state);
                if (state === "SUCCESS") {
                    var resp=response.getReturnValue();
                    console.log('resp:'+resp);
                        //show files
                    if(resp!=''){
                        items[index].oditemlist=JSON.parse(resp);
                        	component.set('v.items',items);; 
                    }
                   
                }
            });
            $A.enqueueAction(action);
    },
     handleUploadFinished: function (component, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
       // component.set("v.docslist",uploadedFiles);
         console.log("Files uploaded : " + JSON.stringify(uploadedFiles));
        component.set("v.showProgress",true);
         var action = component.get("c.saveUploads");
        action.setParams({
            recordId: component.get("v.recordId"),
            uploadedFiles: JSON.stringify(uploadedFiles)
        });
        action.setCallback(this, function(a) {            
            $A.get('e.force:refreshView').fire(); 
            component.set("v.showProgress",false);
            component.set("v.isModalOpen",false);
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/'+component.get('v.recordId')
            });
            urlEvent.fire();        
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
    },
     submitDetails : function(component,event,helper) { 
      //  var MAX_FILE_SIZE=1750000;
        var fileInput = component.find("file").getElement();
    	var file = fileInput.files[0];   
      /*  if (file.size > MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + MAX_FILE_SIZE + ' bytes.\n' +
    	          'Selected file size: ' + file.size);
    	    return;
        } */   
        var fr = new FileReader();  
       	fr.onload = function() {            
       component.set("v.showSpinner",true); 
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);        
    	    helper.upload(component, file, fileContents);             
        };

        fr.readAsDataURL(file);
    },
    shareFolder:function(component,event,helper){
        component.set("v.isShareModalOpen",true);
    },
    closeShareModel:function(component,event,helper){
        component.set("v.isShareModalOpen",false);
    },
     submitShareDetails : function(component,event,helper) { 
         var share=component.get("v.share");
         console.log('share:'+share);
          var action = component.get("c.shareFolderWithUser");
        action.setParams({ p_recordId : component.get("v.recordId"),
                          p_shareId:share});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state:'+state);
            if (state === "SUCCESS") {   
                 component.set("v.isShareModalOpen",false);  
                var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Success!",
        "message": "Folder has been shared successfully."
    });
    toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
     }
})