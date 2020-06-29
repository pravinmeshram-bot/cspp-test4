global class MakePaymentComponent {
    
    @RemoteAction
    global static List<Payment> getPayments(Id parentId) {
        List<Payment> paymentList = new List<Payment>();
        List<nu_dse__Payment__c> recordList = [SELECT
                                                    Id,
                                                    Name,
                                                    nu_dse__Transaction_Status__c,
                                                    nu_dse__Payment_Type__c,
                                                    nu_dse__Dont_Consider__c,
                                                    RecordTypeId,
                                                    nu_dse__Program__c,
                                                    nu_dse__Schedule_Date__c
                                                FROM
                                                    nu_dse__Payment__c
                                                WHERE
                                                    (nu_dse__Transaction_Status__c = 'Failed'
                                                    OR
                                                    nu_dse__Transaction_Status__c = 'Cancelled')
                                                    AND
                                                    nu_dse__Payment_Type__c = 'Deposit'
                                                    AND
                                                    nu_dse__Dont_Consider__c = false
                                                    AND
                                                    RecordType.DeveloperName = 'Draft'
                                                    AND
                                                    nu_dse__Program__c = :parentId
                                                ];
            
        for(nu_dse__Payment__c p : recordList) {
            paymentList.add(new Payment(p));
        }
        return paymentList;
    }
    
    @RemoteAction
    global static void makePayment(Id programId, Id paymentId) {
        Date scheduleDate; 
        AggregateResult ar =[SELECT
                                Max(nu_dse__Schedule_Date__c) maxDate 
                            FROM
                                nu_dse__Payment__c 
                            WHERE
                                nu_dse__Program__c = :programId
                                AND
                                nu_dse__Payment_Type__c IN ('Deposit',null)
                                AND
                                nu_dse__Dont_Consider__c = FALSE
                            ];
        System.debug('ar::'+ar);
        scheduleDate = Date.valueOf(ar.get('maxDate'));
        System.debug('::scheduleDate::'+scheduleDate);
        nu_dse__Payment__c makeupPayment = getPaymentRecord(paymentId).clone();
        if(makeupPayment != null) {
            makeupPayment.nu_dse__Transaction_Status__c = 'Pending';
            makeupPayment.nu_dse__Schedule_Date__c = scheduleDate.addMonths(1);
            makeupPayment.nu_dse__External_CFT_Id__c = null;
            makeupPayment.nu_dse__External_RAMS_Id__c = null;
            makeupPayment.nu_dse__CFT_Synced__c = FALSE;
            makeupPayment.nu_dse__RAMS_Synced__c = FALSE;
                
            insert makeupPayment;
            System.debug('::makeupPayment:::'+makeupPayment);
            nu_dse__Payment__c paymentToUpdate = new nu_dse__Payment__c(Id = paymentId, nu_dse__Dont_Consider__c = true);
            update paymentToUpdate;
        }
    }
    
    private static nu_dse__Payment__c getPaymentRecord(Id paymentId) {
        List<nu_dse__Payment__c> recordList = [SELECT
                                                   Id,
                                                   Name,
                                                   nu_dse__Transaction_Status__c,
                                                   nu_dse__Payment_Type__c,
                                                   nu_dse__Dont_Consider__c,
                                                   RecordTypeId,
                                                   nu_dse__Program__c,
                                                   nu_dse__Schedule_Date__c
                                               FROM
                                                   nu_dse__Payment__c
                                               WHERE
                                                   Id = :paymentId
                                               ];
        if(!recordList.isEmpty()) {
            System.debug('::recordList::'+recordList[0]);
            return recordList[0]; 
        }
        return null;
    }
    
    global class Payment {
        public String name;
        public String status;
        public Id recordId;
        public String scheduleDate;
        
        public Payment(nu_dse__Payment__c payment) {
            this.name = payment.name;
            this.status = payment.nu_dse__Transaction_Status__c;
            this.recordId = payment.Id;
            if(payment.nu_dse__Schedule_Date__c != null) {
                this.scheduleDate = toDateString(payment.nu_dse__Schedule_Date__c, 'MM/dd/YYYY');
            }
        }
    }
    
    public static String toDateString(Date activityDate, String dateFormat) {
        if(activityDate != null) {
            DateTime dt = DateTime.newInstance(activityDate.year(), activityDate.month(), activityDate.day());
            return dt.format(dateFormat);
        }
        return '';
    }
}