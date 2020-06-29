({
    doInit : function(component, event, helper) {
        var dataRow = component.get("v.dataRowMap");
        var dataCell = component.get("v.dataCellList");
        var Value ='';
        var typeMap = {
            'string':'ui:outputText',
            'double':'ui:outputNumber',
            'date':'ui:outputDate',
            'textarea':'ui:outputTextArea',
            'currency':'ui:outputCurrency',
            'picklist':'ui:outputText',
            'email':'ui:outputEmail',
            'reference':'ui:outputText'
        };
        
        var tagName = typeMap[dataCell.fieldType] || 'ui:outputText' ;
        
        if(dataCell.fieldType == 'reference' && dataRow[dataCell.fieldRelationshipName]) {
            
           Value = dataRow[dataCell.fieldRelationshipName]['Name'] || ''; 
        } else {
            
           Value = dataRow[dataCell.fieldAPIName]; 
        }
        
        $A.createComponent(
            tagName,{
                'value' : Value,
                'title' : Value
            },
            function(modalCmp,status){
                var body = component.get("v.body");
                body.push(modalCmp);
                component.set("v.body",body);
            }
        );
        
    }
})