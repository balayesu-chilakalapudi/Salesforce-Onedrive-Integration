({
    checkForChanges:function(component,event){
         try{            
             component.set("v.showProgress",true); 
             var action = component.get("c.loadFiles");
            action.setParams({ p_recordId : component.get("v.recordId") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state:'+state);
                if (state === "SUCCESS") { 
                    var resp=response.getReturnValue();
                    console.log('resp:'+JSON.stringify(resp));
                    component.set("v.OnedriveWrapper",resp);
                    var odw=component.get("v.OnedriveWrapper");
                    component.set("v.connected",odw.connected);
                    component.set("v.entrylist",odw.odilist);                    
                    component.set("v.OnedrivePermission",odw.odp);
                    component.set("v.OnedriveFolder",odw.odf);
                    var folderpath=[];
                    folderpath.push({name:"Home",value:"Home"});
                    component.set("v.folderpath",folderpath);
                }
                component.set("v.showProgress",false);
            });
            $A.enqueueAction(action);             
        }catch(err){
            console.log('Exception: '+err.stack);
        }
    }
})