@isTest
public class Test_SLDSDynamicLookupController {
    public static testmethod void slds(){
        
        string objectName = 'Account';
        string displayFieldNames = 'Name';
        string fieldsPattern = 'Pattern';
        string photoValue = 'field';
        string searchText = 'Name';
        
        SLDSDynamicLookupController sld = new SLDSDynamicLookupController();
        SLDSDynamicLookupController.search(objectName, displayFieldNames, fieldsPattern, photoValue, searchText);
    }
    
    public static testmethod void slds1(){
        
        string objectName = 'Account';
        string displayFieldNames = 'Name';
        string fieldsPattern = 'Pattern';
        string photoValue = 'url';
        string searchText = 'Name';
        List<String> photoValueLst = photoValue.split('->');
        
        Account acc = new Account();
        acc.name='TestName';
        insert acc;
        
        Id recordId = acc.Id;
        String displayValue = 'display';
        String photoUrl = 'Photo';
        
        SLDSDynamicLookupController sld = new SLDSDynamicLookupController();
        SLDSDynamicLookupController.search(objectName, displayFieldNames, fieldsPattern, photoValue, searchText);
    	SLDSDynamicLookupController.Wrapper wr = new SLDSDynamicLookupController.Wrapper(recordId, displayValue, photoUrl);
        sld.uniqueComponentId = 'TestId';
        sld.objectLabelPlural = 'testobject';
        sld.label = 'TestLabel';
    //    sld.objectName = 'value';
        
	}
    
    public static testmethod void slds2(){
        
        string objectName = 'Account';
        string displayFieldNames = 'Name';
        string fieldsPattern = '';
        string photoValue = 'field->';
        string searchText = 'Name';
        List<String> photoValueLst = photoValue.split('->');
        
        SLDSDynamicLookupController sld = new SLDSDynamicLookupController();
        SLDSDynamicLookupController.search(objectName, displayFieldNames, fieldsPattern, photoValue, searchText);
    }
    
    public static testmethod void slds3(){
        
        string objectName = 'Account';
        string displayFieldNames = 'Name';
        string fieldsPattern = '';
        string photoValue = 'url->';
        string searchText = 'Text';
        List<String> photoValueLst = photoValue.split('->');
        
        SLDSDynamicLookupController sld = new SLDSDynamicLookupController();
        SLDSDynamicLookupController.search(objectName, displayFieldNames, fieldsPattern, photoValue, searchText);
    }
}