public class BookFlight {
	@InvocableMethod(label='Book flight' description='Book the flight seats' category='Order')
    public static List<userBookResponse> bookHotelRoom(List<userBookRequest> requests){
        Date JourneyDate = requests[0].JourneyDate;
        String flightName = requests[0].flightName;
        List<String> userNames = requests[0].userNames;
        List<String> govId = requests[0].govId;
        String agencyId =requests[0].agencyId;
        //String Email = requests[0].Email;
        userBookResponse result = new userBookResponse();
        
        
        User u = [Select Id,FirstName, LastName, Email, Agency_Id__c From User where Agency_Id__c =: agencyId];
        if(u == null){
            result.isbook = 'Agency Id is wrong';
            return new List<userBookResponse>{result};
        }
        Account acc = [Select id,Company_Email__c From Account Where Company_Email__c =: u.Email ];
        if(acc == Null){
            Account newacc = new Account(Name = u.FirstName+u.LastName, Company_Email__c = u.Email);
        	insert newacc;
        }
        Pricebook2 pricebookId = [SELECT Id, Name FROM Pricebook2 Where Name = 'Standard Price Book' LIMIT 1];
        Order ord = new Order();
        ord.AccountId = acc.Id;
        ord.EffectiveDate = JourneyDate;
        ord.Status = 'Draft';
        ord.Pricebook2Id = pricebookId.Id;
        insert ord;
        
        List<Product2> productlist = [Select Id, Name,Quantity__c,Product_Final_Unit_Price__c From Product2 Where Name =:flightName];
        Set<Id> proId = new Set<Id>();
        for(Product2 pro: productlist){
            proId.add(pro.Id);
        }
        List<PricebookEntry> priceBookEntryList = [SELECT Id,Name,Product2Id FROM PricebookEntry Where Product2Id IN: (proId)];
        Map<Id, Id> priceBookEntryIdWithProductId = new Map<Id, String>();
        Map<String, String> flightUserDetails = new Map<String, String>();
        for(Integer i = 0; i< userNames.size(); i++ ){
            flightUserDetails.put(userNames[i], govId[i]);
        }
        for(PricebookEntry pbe : priceBookEntryList){
            priceBookEntryIdWithProductId.put(pbe.Product2Id,pbe.Id);
        }
        
        List<OrderItem> orderList = new List<OrderItem>();
        for(String userName : flightUserDetails.keySet()){
            OrderItem oi = new OrderItem();
            oi.Product2Id = productlist[0].Id;
            oi.OrderId = ord.Id;
            oi.Passenger_Name__c = userName;
            oi.Passenger_ID__c = flightUserDetails.get(userName);
            oi.Quantity = 1;
            oi.UnitPrice = productlist[0].Product_Final_Unit_Price__c;
            oi.PriceBookEntryId = priceBookEntryList[0].Id;
            orderList.add(oi);
        }
        
        if(!orderList.isEmpty()){
            try{
                insert orderList;
                Order currOrder = [Select Id, OrderNumber From Order Where Id =: ord.Id];
                result.isbook = 'Your order is succesfully created and your order number is ' + currOrder.OrderNumber;
            }
            catch(Exception ex){
                system.debug(ex.getMessage());
                result.isbook = 'Sorry error while making your book please try agian';
            }
            
        }
        return new List<userBookResponse>{result};
        
    }
    
    public class userBookRequest {
       @InvocableVariable(
            required=true
            description='Date of journey on which user will travel. The variable needs to be an Apex Date type with format yyyy-MM-dd.'
        )
        public Date journeyDate;
        @InvocableVariable(
            required=true
            description='Name of hotel for which user want to book'
        )
        public String flightName;
        @InvocableVariable(
            required=true
            description='Name of Rooms for which user want to book'
        )
        public List<String> userNames;
        @InvocableVariable(
            required=true
            description='Number of rooms for which user want to book'
        )
        public List<String> govId;
        @InvocableVariable(
            required=true
            description='Id of Agency which is map with the user record'
        )
        public String agencyId;
        /*@InvocableVariable(
            required=true
            description='Email address of user for which user is going to book'
        )
        public String Email;*/
    }
    public class userBookResponse {
        @InvocableVariable(
            description='this variable is used to send message with order number'
        )
        public String isbook;
    }
}