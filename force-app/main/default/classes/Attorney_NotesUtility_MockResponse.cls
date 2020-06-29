@isTest
global with sharing class Attorney_NotesUtility_MockResponse implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{	"Lit_Def_File_Number": "F-0023308576",	"Fusion_File_Number_lead": "A0014281085",		"Client_Name": "Miguel Rodriguez",		"Debt_Id": "11988999",		"Created": "6/25/2019 8:45:01 AM",		"Category": "Transfer",		"Message_pix500": "File transferred."	},	{		"Lit_Def_File_Number": "F-0023308576",		"Fusion_File_Number_lead": "A0014281085",		"Client_Name": "Miguel Rodriguez",		"Debt_Id": "11988999",		"Created": "6/25/2019 8:45:01 AM",		"Category": "Transfer",		"Message_pix500": "Debt File transferred - File #F-0023308576 [Creditor: Bank of America, Acct#: 5720]"	},	{		"Lit_Def_File_Number": "F-0023308576",		"Fusion_File_Number_lead": "A0014281085",		"Client_Name": "Miguel Rodriguez",		"Debt_Id": "11988999",		"Created": "6/25/2019 8:45:01 AM",		"Category": "File",		"Message_pix500": "Upload Transferred Documents: Anchor Letters of Representation.pdf"	},	{		"Lit_Def_File_Number": "F-0023308576",		"Fusion_File_Number_lead": "A0014281085",		"Client_Name": "Miguel Rodriguez",		"Debt_Id": "11988999",		"Created": "6/25/2019 8:45:01 AM",		"Category": "File",		"Message_pix500": "Upload Transferred Documents: A0014281085_MiguelRodriguez_Collection+Notice.pdf"	},	{		"Lit_Def_File_Number": "F-0023308576",		"Fusion_File_Number_lead": "A0014281085",		"Client_Name": "Miguel Rodriguez",		"Debt_Id": "11988999",		"Created": "6/25/2019 8:45:01 AM",		"Category": "File",		"Message_pix500": "Upload Transferred Documents: A0014281085_MiguelRodriguez_Collection Notice.pdf"	},	{		"Lit_Def_File_Number": "F-0023308576",		"Fusion_File_Number_lead": "A0014281085",		"Client_Name": "Miguel Rodriguez",		"Debt_Id": "11988999",		"Created": "6/25/2019 8:45:01 AM",		"Category": "File",		"Message_pix500": "Upload Transferred Documents: SRFax Transmission Successful to 1 330-963-0210  Re MiguelRodriguez_A0014281085_LOR POA  on Dec 27 17 01 19 PM.msg"	},	{		"Lit_Def_File_Number": "F-0023145949",		"Fusion_File_Number_lead": "SM0014304325",		"Client_Name": "Nagamallika Guggilapu",		"Debt_Id": "14220124",		"Created": "6/25/2019 8:46:00 AM",		"Category": "Status",		"Message_pix500": "Action: Client Contacted - Request to file response"	},	{		"Lit_Def_File_Number": "F-0023145949",		"Fusion_File_Number_lead": "SM0014304325",		"Client_Name": "Nagamallika Guggilapu",		"Debt_Id": "14220124",		"Created": "6/25/2019 8:46:00 AM",		"Category": "Status",		"Message_pix500": "Workflow changed to Local Counsel Requests to File Response"	}]');
        res.setStatusCode(200);
        return res;
    }
}