({	
    doInit: function(component, event, helper){        
        console.log('GrantAccess Success'); 
        try{ 
             var action = component.get("c.getOnedriveUserslist");
            action.setParams({ p_recordId : component.get("v.recordId") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state:'+state);
                if (state === "SUCCESS") { 
                    var resp=response.getReturnValue();
                    console.log('resp:'+JSON.stringify(resp));
                    component.set("v.sfulist",resp);
                }               
            });
            $A.enqueueAction(action); 
        }catch(err){
            console.log('Exception: '+err.stack);
        }
    },
    closeGrantAccess:function(component,event,helper){
        var appEvent = $A.get("e.c:CloseGrantAccess");            
                    appEvent.setParams({
                        "closeModel" : false });
                    appEvent.fire();
    },
    submitGrantAccess:function(component,event,helper){
        var sfulist=component.get("v.sfulist");
        console.log('sfulist:'+JSON.stringify(sfulist));
        var action = component.get("c.savePermissionlist");
            action.setParams({ p_sfulist : JSON.stringify(sfulist),
                              p_recordId: component.get("v.recordId")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state:'+state);
                if (state === "SUCCESS") { 
                    var appEvent = $A.get("e.c:CloseGrantAccess");            
                    appEvent.setParams({
                        "closeModel" : false });
                    appEvent.fire();
                }               
            });
            $A.enqueueAction(action);  
    },
    doSelectAll:function(component,event,helper){
        var sall=component.find("sall").get("v.value");
        console.log('sall:'+sall);
        var sfulist=component.get("v.sfulist");
        for(var x=0;x<sfulist.length;x++){
            sfulist[x].Selected=sall;
        }
        component.set("v.sfulist",sfulist);
    },
    doViewAll:function(component,event,helper){
        var vall=component.find("vall").get("v.value");
        console.log('vall:'+vall);
        var sfulist=component.get("v.sfulist");
        for(var x=0;x<sfulist.length;x++){
            sfulist[x].CanView=vall;
        }
        component.set("v.sfulist",sfulist);
    }
    ,
    doEditAll:function(component,event,helper){
        var eall=component.find("eall").get("v.value");
        console.log('eall:'+eall);
        var sfulist=component.get("v.sfulist");
        for(var x=0;x<sfulist.length;x++){
            sfulist[x].CanEdit=eall;
        }
        component.set("v.sfulist",sfulist); 
    },
    doSelectRow:function(component,event,helper){
        console.log('doSelectRow success');
        var id=event.currentTarget.dataset.myid;
        console.log('id:'+id);
        var sfulist=component.get("v.sfulist");
        for(var x=0;x<sfulist.length;x++){
            if(sfulist[x].UserId==id){                
            	sfulist[x].Selected=true;
            }
        }
        component.set("v.sfulist",sfulist);
    }
})