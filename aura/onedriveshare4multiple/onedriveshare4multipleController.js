({
    
    scriptsLoaded : function(component, event, helper) {
        console.log('load successfully');
        
        // active/call select2 plugin function after load jQuery and select2 plugin successfully    
        $(".select2Class").select2({
            placeholder: "Select Multiple values"
        });
    },
    
    doInit: function(component, event, helper) {
        /*On the component load call the fetchPickListVal helper method
         pass the Picklist[multi-select] API name in parameter  
       */ 
        helper.fetchPickListVal(component, 'skills__c');
        helper.getodulist(component,event);
    },
    
    closeShareModel: function(component,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/'+component.get('v.recordId')
        });
        urlEvent.fire();    
    },
    
    submitShareDetails : function(component,event,helper) { 
        var selectedUsers = $('[id$=picklist]').select2("val");
        selectedUsers=''+selectedUsers;
        console.log('selectedUsers:'+selectedUsers);
        
        var recId=component.get("v.recordId");
        console.log('recordId:'+recId);
        
        var action = component.get("c.shareFolderWithUsers");
        action.setParams({ p_recordId : recId,
                          p_selectedUsers:selectedUsers
                         });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state:'+state);
            if (state === "SUCCESS") {   
                // component.set("v.isShareModalOpen",false);  
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Folder has been shared successfully."
                });
                toastEvent.fire();
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": '/'+recId
                });
                urlEvent.fire();   
            }else if(state === "ERROR"){ 
                console.log('some problem'+JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);        
    }   
})