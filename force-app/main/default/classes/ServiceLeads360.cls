public class ServiceLeads360 {

        public static final String SOAP_NS = 'https://schemas.xmlsoap.org/soap/envelope/';
        public static final String SOAP12_NS = 'https://www.w3.org/2003/05/soap-envelope';
        public static final String XSI = 'https://www.w3.org/2001/XMLSchema-instance';
     public static final String XSD = 'https://www.w3.org/2001/XMLSchema';
     public static final String SERVICE_NS = 'https://service.leads360.com';
    
    public  String userName{get;set;}
    public  String password{get;set;}
    
    public ServiceLeads360(){
        
        Velocify_Settings__c settings = Velocify_Settings__c.getInstance(UserInfo.getUserId());
        
        if(settings !=null){
            
            userName = settings.Username__c; 
            password = settings.Password__c; 
            
        }
    }
   
    public   Dom.Document getLeadByIdRequest(String leadId){
          DOM.Document doc = new DOM.Document();

          dom.XmlNode envelope  = doc.createRootElement('Envelope', SOAP_NS, 'soapenv');
        
          envelope.setNamespace('ser', SERVICE_NS);
        
          //envelope.setAttributeNS('schemaLocation', SOAP_NS, XSI, 'soapenv');
        
          dom.XmlNode header  = envelope.addChildElement('Header', SOAP_NS, 'soapenv');
        
          dom.XmlNode body =  envelope.addChildElement('Body', SOAP_NS, 'soapenv');
              
          
          dom.XmlNode getlead =  body.addChildElement('GetLead', SERVICE_NS, 'ser');
        
          getlead.addChildElement('username', SERVICE_NS, 'ser').addTextNode(userName);
        
          getlead.addChildElement('password', SERVICE_NS, 'ser').addTextNode(password);
        
          getlead.addChildElement('leadId', SERVICE_NS, 'ser').addTextNode(leadId);
        
          System.debug(doc.toXmlString());
        
        return doc; 
    }
    
    public  dom.xmlNode getLeadXML( Dom.XmlNode leadsElement,  nu_dse__Prospect__c lead, Map<String,String> fieldMap){
        
        
        
          Dom.XmlNode leadElement = leadsElement.addChildElement('Lead', null, null);
          leadElement.setAttribute('Id', lead.Upd_External_Id__c); // changes made by Mayur to replace external_Id__c with Upd_External_id__c
        
         // leadElement.addChildElement('Status',null,null).setAttribute('StatusId','');
        
          Dom.XmlNode fields = leadElement.addChildElement('Fields',null,null); 
        
          Map<String, Schema.SObjectField> fMap = Schema.SObjectType.nu_dse__Prospect__c.fields.getMap();
       
         for(String f: fMap.keySet()){
               
             f = f.toUpperCase();
             
             if(fieldMap !=null && fieldMap.containsKey(f) && lead.get(f) !=null){
                 
                  dom.xmlNode f1 = fields.addChildElement('Field',null,null); 
          
                  f1.setAttribute('FieldId', fieldMap.get(f));
          
                  f1.setAttribute('Value', String.valueOf(lead.get(f)));
                                       
             }
             
         }
        
      
        
        return leadsElement; 
    }
   
    public  dom.xmlNode getLeadXML( Dom.XmlNode leadsElement,  nu_dse__Program__c lead, Map<String,String> fieldMap){
        
        
        
          Dom.XmlNode leadElement = leadsElement.addChildElement('Lead', null, null);
          
          leadElement.setAttribute('Id', lead.External_Id__c);
          
         // leadElement.addChildElement('Status',null,null).setAttribute('StatusId','');
        
          Dom.XmlNode fields = leadElement.addChildElement('Fields',null,null); 
        
          Map<String, Schema.SObjectField> fMap = Schema.SObjectType.nu_dse__Program__c.fields.getMap();
       
         for(String f: fMap.keySet()){
               
             f = f.toUpperCase();
             
             if(fieldMap !=null && fieldMap.containsKey(f) && lead.get(f) !=null){
                 
                  dom.xmlNode f1 = fields.addChildElement('Field',null,null); 
          
                  f1.setAttribute('FieldId', fieldMap.get(f));
          
                  f1.setAttribute('Value', String.valueOf(lead.get(f)));
                                       
             }
             
         }
        
      
        
        return leadsElement; 
    }
    
    public  dom.xmlNode getLeadXML( Dom.XmlNode leadsElement,String leadExternalId, List<ServiceLeads360.FieldValues>  fieldvaluesList, Map<String,String> fieldMap){
        
        
        
          Dom.XmlNode leadElement = leadsElement.addChildElement('Lead', null, null);
          
          leadElement.setAttribute('Id', leadExternalId);
        
         // leadElement.addChildElement('Status',null,null).setAttribute('StatusId','');
        
          Dom.XmlNode fields = leadElement.addChildElement('Fields',null,null); 
        
        for(ServiceLeads360.FieldValues fieldvalue: fieldvaluesList){
            
            String f = fieldvalue.field.toUpperCase(); 
            
            if(fieldMap.containsKey(f) && fieldvalue.value !=null ){
                
                dom.xmlNode f1 = fields.addChildElement('Field',null,null); 
          
                  f1.setAttribute('FieldId', fieldMap.get(f));
          
                  f1.setAttribute('Value', String.valueOf(fieldvalue.value));
            }
        }
       
       
      
        
        return leadsElement; 
    }
   
    public  void modifyLeads(List<nu_dse__Prospect__C> leads){
        
         DOM.Document doc = new DOM.Document();

         dom.XmlNode envelope  = doc.createRootElement('Envelope', SOAP12_NS, 'soap12');
        
         envelope.setNamespace('xsi', XSI);
        
         envelope.setNamespace('xsd', XSD);
        
         //envelope.setNamespace('ser',SERVICE_NS);
        
         //dom.XmlNode header  = envelope.addChildElement('Header', SOAP12_NS, 'soapenv');
        
         dom.XmlNode body =  envelope.addChildElement('Body', SOAP12_NS, 'soap12');
              
         dom.XmlNode modifyLeads =  body.addChildElement('ModifyLeads', null, null);
        
         modifyLeads.setNamespace('',SERVICE_NS);
         modifyLeads.addChildElement('username', null, null).addTextNode(userName);
        
         modifyLeads.addChildElement('password', null, null).addTextNode(password);
        
         Dom.XmlNode leadsElement = modifyLeads.addChildElement('leads', null, null);
        
        leadsElement = leadsElement.addChildElement('Leads', null, null);
        
         Map<String,string> fieldMap = new Map<String,string>(); 

        for(nu_dse__Field_mapping__c datamapping : [select id,nu_dse__Data_Mapping__c,nu_dse__Source_Field__c,nu_dse__Target_Field__c from nu_dse__Field_mapping__c where nu_dse__Data_Mapping__r.Name='VelocifyLead']){
            
            fieldMap.put(datamapping.nu_dse__Source_Field__c.toUpperCase(), datamapping.nu_dse__Target_Field__c);
        }
        
        for(nu_dse__Prospect__C l: leads){
            
          leadsElement = getLeadXML(leadsElement,l,fieldMap);
            
        }
        
        System.debug('XML String: '+ doc.toXMLString());
        
        String endpoint='https://service.leads360.com/ClientService.asmx';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('SOAPAction', 'https://service.leads360.com/ModifyLeads');
        req.setHeader('Content-Type','text/xml;charset=UTF-8');
        //req.setbody(doc.toXMLString());
        req.setBodyDocument(doc);
       
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        if (Test.isRunningTest() == False) {
            res = http.send(req);
        } else { //developed below code to set as response in test class context
            res.setHeader('Content-Type', 'application/json');
            res.setStatus('Created');
            res.setStatusCode(200);
        }
        System.debug(res.getStatus());

    }
    
    public void modifyPrograms(List<nu_dse__Program__c> Programs){  
        
         DOM.Document doc = new DOM.Document();

         dom.XmlNode envelope  = doc.createRootElement('Envelope', SOAP12_NS, 'soap12');
        
         envelope.setNamespace('xsi', XSI);
        
         envelope.setNamespace('xsd', XSD);
        
         //envelope.setNamespace('ser',SERVICE_NS);
        
         //dom.XmlNode header  = envelope.addChildElement('Header', SOAP12_NS, 'soapenv');
        
         dom.XmlNode body =  envelope.addChildElement('Body', SOAP12_NS, 'soap12');
              
         dom.XmlNode modifyLeads =  body.addChildElement('ModifyLeads', null, null);
        
         modifyLeads.setNamespace('',SERVICE_NS);
         modifyLeads.addChildElement('username', null, null).addTextNode(userName);
        
         modifyLeads.addChildElement('password', null, null).addTextNode(password);
        
         Dom.XmlNode leadsElement = modifyLeads.addChildElement('leads', null, null);
        
        leadsElement = leadsElement.addChildElement('Leads', null, null);
        
         Map<String,string> fieldMap = new Map<String,string>(); 

        for(nu_dse__Field_mapping__c datamapping : [select id,nu_dse__Data_Mapping__c,nu_dse__Source_Field__c,nu_dse__Target_Field__c from nu_dse__Field_mapping__c where nu_dse__Data_Mapping__r.Name='VelocifyProgram']){
            
            fieldMap.put(datamapping.nu_dse__Source_Field__c.toUpperCase(), datamapping.nu_dse__Target_Field__c);
        }
        
        for(nu_dse__Program__c l: programs){
            
         leadsElement = getLeadXML(leadsElement,l,fieldMap);
            
        }
        
        System.debug('XML String: '+ doc.toXMLString());
        
        String endpoint='https://service.leads360.com/ClientService.asmx';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('SOAPAction', 'https://service.leads360.com/ModifyLeads');
        req.setHeader('Content-Type','text/xml;charset=UTF-8');
        //req.setbody(doc.toXMLString());
        req.setBodyDocument(doc);
       
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        if (Test.isRunningTest() == False) {
            res = http.send(req);
        } else { //developed below code to set as response in test class context
            res.setHeader('Content-Type', 'application/json');
            res.setStatus('Created');
            res.setStatusCode(200);
        }
        System.debug(res.getStatus());

    }
    
    
    //String leadExternalId, List<lead> fieldValueMap
    public String modifyLeadPayments(List<ServiceLeads360.Lead>  leads ){
        
          DOM.Document doc = new DOM.Document();

         dom.XmlNode envelope  = doc.createRootElement('Envelope', SOAP12_NS, 'soap12');
        
         envelope.setNamespace('xsi', XSI);
        
         envelope.setNamespace('xsd', XSD);
        
         //envelope.setNamespace('ser',SERVICE_NS);
        
         //dom.XmlNode header  = envelope.addChildElement('Header', SOAP12_NS, 'soapenv');
        
         dom.XmlNode body =  envelope.addChildElement('Body', SOAP12_NS, 'soap12');
              
         dom.XmlNode modifyLeads =  body.addChildElement('ModifyLeads', null, null);
        
         modifyLeads.setNamespace('',SERVICE_NS);
         modifyLeads.addChildElement('username', null, null).addTextNode(userName);
        
         modifyLeads.addChildElement('password', null, null).addTextNode(password);
        
         Dom.XmlNode leadsElement = modifyLeads.addChildElement('leads', null, null);
        
         leadsElement = leadsElement.addChildElement('Leads', null, null);
        
        
         Map<String,string> fieldMap = new Map<String,string>(); 

        for(nu_dse__Field_mapping__c datamapping : [select id,nu_dse__Data_Mapping__c,nu_dse__Source_Field__c,nu_dse__Target_Field__c from nu_dse__Field_mapping__c where nu_dse__Data_Mapping__r.Name='VelocifyLeadPayments']){
            
            
            fieldMap.put(datamapping.nu_dse__Source_Field__c.toUpperCase(), datamapping.nu_dse__Target_Field__c);
            
        }
        
         for(ServiceLeads360.Lead l: leads){
            
           leadsElement =  getLeadXML(leadsElement,l.Id,  l.field_values , fieldMap);
             
        }
        
        
        System.debug('XML String: '+ doc.toXMLString());
        
        String endpoint='https://service.leads360.com/ClientService.asmx';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('SOAPAction', 'https://service.leads360.com/ModifyLeads');
        req.setHeader('Content-Type','text/xml;charset=UTF-8');
        //req.setbody(doc.toXMLString());
        req.setBodyDocument(doc);
       
        Http http = new Http();
        //HttpResponse res = http.send(req);
        HttpResponse res = new HttpResponse();
        if (Test.isRunningTest() == False) {
            res = http.send(req);
        } else {  //developed below code to set as response in test class context
            res.setHeader('Content-Type', 'application/json');
            res.setStatus('Created');
            res.setStatusCode(200);
        }
        System.debug(res.getStatus());
        
        System.debug('**** response of modifyLeadPayments' + res);
        
        ResponseWrapper responseWrapperInstance = new ResponseWrapper(String.valueOf(res.getStatusCode()), String.valueOf(res.getStatus()));
        
        String wrapperString = JSON.serialize(responseWrapperInstance);
        
        return wrapperString;
    }
    
    public void modifyLeadStatus( Map<string,string> LeadId_statusId ){
        
       
      for(string lId: LeadId_statusId.keySet()){
            
         DOM.Document doc = new DOM.Document();

         dom.XmlNode envelope  = doc.createRootElement('Envelope', SOAP12_NS, 'soap12');
        
         envelope.setNamespace('xsi', XSI);
        
         envelope.setNamespace('xsd', XSD);
        
         //envelope.setNamespace('ser',SERVICE_NS);
        
         //dom.XmlNode header  = envelope.addChildElement('Header', SOAP12_NS, 'soapenv');
        
         dom.XmlNode body =  envelope.addChildElement('Body', SOAP12_NS, 'soap12');
        
         dom.XmlNode modifyLeadsStatus =  body.addChildElement('ModifyLeadStatus', null, null);
        
         modifyLeadsStatus.setNamespace('',SERVICE_NS);
         modifyLeadsStatus.addChildElement('username', null, null).addTextNode(userName);
        
         modifyLeadsStatus.addChildElement('password', null, null).addTextNode(password);
        
         modifyLeadsStatus.addChildElement('leadId', null, null).addTextNode(lId);
        
         modifyLeadsStatus.addChildElement('statusId', null, null).addTextNode(LeadId_StatusId.get(lId));
      
        System.debug('XML String: '+ doc.toXMLString());
        
        String endpoint='https://service.leads360.com/ClientService.asmx';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('SOAPAction', 'https://service.leads360.com/ModifyLeadStatus');
        req.setHeader('Content-Type','text/xml;charset=UTF-8');
        //req.setbody(doc.toXMLString());
        req.setBodyDocument(doc);
       
        Http http = new Http();
        //HttpResponse res = http.send(req);
        HttpResponse res = new HttpResponse();
        if (Test.isRunningTest() == False) {
            res = http.send(req);
        } else {  //developed below code to set as response in test class context
            res.setHeader('Content-Type', 'application/json');
            res.setStatus('Created');
            res.setStatusCode(200);
        }
        System.debug(res.getStatus());
        
        
        System.debug('**** response of modifyLeadStatus ' + res);
        
        }
      
       
    }
     
    public class Lead{
        
        public String id{get;set;}
        public list<ServiceLeads360.FieldValues> field_values{get;set;} 
       
        
        public Lead(String externalId, List<FieldValues> fmap){
            
            this.id = externalId; 
            this.field_values = fmap; 
        }
    }
    
   public class FieldValues{
        
         public string field{get;set;}
         public string value{get;set;}
        
        public FieldValues(String f, string v){
              
            this.field = f; 
            this.value = v; 
        }
    }

    public class ResponseWrapper {
    
        public String statusCode;
        public String statusMessage;
        
        public ResponseWrapper(String statusCode, String message) {
        
            this.statusCode = statusCode;
            this.statusMessage = message;
        }
    }
    
}