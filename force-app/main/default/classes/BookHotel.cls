public class BookHotel {
	@InvocableMethod(label='Book Hotel' description='Book the Hotel Room' category='Order')
    public static List<userBookResponse> bookHotelRoom(List<userBookRequest> requests){
        Date startDate = requests[0].startDate;
        Date endDate =requests[0].endDate;
        String hotelName = requests[0].hotelName;
        List<String> roomNames = requests[0].roomNames;
        List<Integer> bookRoomCount = requests[0].bookRoomCount;
        String agencyId =requests[0].agencyId;
        //String Email = requests[0].Email;
        userBookResponse result = new userBookResponse();
        
        
        User u = [Select Id,FirstName, LastName, Email, Agency_Id__c From User where Agency_Id__c =: agencyId];
        if(u == null){
            result.isbook = 'Agency Id is wrong';
            return new List<userBookResponse>{result};
        }
        List<Account> accList = [Select id,Company_Email__c From Account Where Company_Email__c =: u.Email ];
        Account newacc;
        if(accList.isEmpty()){
            newacc = new Account(Name = u.FirstName+u.LastName, Company_Email__c = u.Email);
        	insert newacc;
            
            Contact con = new Contact();
            con.LastName = u.LastName;
            con.Email = u.Email;
            insert con;
        }
        
        Map<String, Integer> roomWithQuantity = new Map<String, Integer>();
        for(Integer i = 0; i < roomNames.size(); i++){
            roomWithQuantity.put(roomNames[i], bookRoomCount[i]);
        }
        Pricebook2 pricebookId = [SELECT Id, Name FROM Pricebook2 Where Name = 'Standard Price Book' LIMIT 1];
        Order ord = new Order();
        ord.AccountId = accList.isEmpty() ? newacc.Id : accList[0].Id;
        ord.EffectiveDate = startDate;
        ord.EndDate = endDate;
        ord.Status = 'Draft';
        ord.Pricebook2Id = pricebookId.Id;
        insert ord;
        
        
        
        List<Product2> productlist = [Select Id, Name,Quantity__c,Product_Final_Unit_Price__c From Product2 Where Name IN: (roomNames) AND TDX_Asset__r.Name =: hotelName];
        Set<Id> proId = new Set<Id>();
        for(Product2 pro: productlist){
            proId.add(pro.Id);
        }
        List<PricebookEntry> priceBookEntryList = [SELECT Id,Name,Product2Id FROM PricebookEntry Where Product2Id IN: (proId)];
        Map<Id, Id> priceBookEntryIdWithProductId = new Map<Id, String>();
        for(PricebookEntry pbe : priceBookEntryList){
            priceBookEntryIdWithProductId.put(pbe.Product2Id,pbe.Id);
        }
        
        List<OrderItem> orderList = new List<OrderItem>();
        for(Product2 pro : productlist){
            system.debug(pro.id);
            OrderItem oi = new OrderItem();
            oi.Product2Id = pro.Id;
            oi.OrderId = ord.Id;
            oi.Quantity = roomWithQuantity.get(pro.Name);
            oi.UnitPrice = pro.Product_Final_Unit_Price__c;
            oi.PriceBookEntryId = priceBookEntryIdWithProductId.get(pro.Id);
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
            description='Check In Date for which we want to check the hotel. The variable needs to be an Apex Date type with format yyyy-MM-dd.'
        )
        public Date startDate;
        @InvocableVariable(
            required=true
            description='Check out Date for which we want to check the hotel. The variable needs to be an Apex Date type with format yyyy-MM-dd.'
        )
        public Date endDate;
        @InvocableVariable(
            required=true
            description='Name of hotel for which user want to book'
        )
        public String hotelName;
        @InvocableVariable(
            required=true
            description='Name of Rooms for which user want to book'
        )
        public List<String> roomNames;
        @InvocableVariable(
            required=true
            description='Number of rooms for which user want to book'
        )
        public List<Integer> bookRoomCount;
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