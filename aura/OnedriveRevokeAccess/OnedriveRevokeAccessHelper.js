({
    fetchPickListVal: function(component, fieldName) {
      /* call the apex getselectOptions method which is returns picklist values
         set the picklist values on "picklistOptsList" attribute [String list].
         which attribute used for iterate the select options in component.
       */  
        var action = component.get("c.getselectOptions");
        action.setParams({
             "objObject": {sobjectType : 'Account'},
             "fld": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }
                component.set("v.picklistOptsList", opts);
            }
        });
        $A.enqueueAction(action);
    },
    getodulist:function(component,event){
         var action = component.get("c.getOnedriveUsers");
           // action.setParams({ p_recordId : component.get("v.recordId") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state:'+state);
                if (state === "SUCCESS") {
                    var resp=response.getReturnValue();
                    component.set("v.odulist",resp);
                    console.log('odulist:'+JSON.stringify(component.get("v.odulist")));
                    //component.set("v.showProgress",false);  
                }
            });
        $A.enqueueAction(action);
    }
})