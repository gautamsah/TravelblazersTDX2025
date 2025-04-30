public class GetCustomerBooking {
    @InvocableMethod(label='Get Customer Previous Bookings' description='Fetch and return customer previous booking details')
    public static List<String> getPreviousbookings(List<String> customerId){
        Set<Id> assetIds = new Set<Id>();
        if(customerId != null && customerId.size()>0){
            User u = [Select Id,FirstName, LastName, Email, Agency_Id__c From User where Agency_Id__c =: customerId[0]];
            if(u != null){
                List<Account> accList = [Select id,Company_Email__c From Account Where Company_Email__c =: u.Email ];
                if(accList != null){
                    List<AssetDetail> assets = new List<AssetDetail>();
                    for(Order ord : [SELECT (SELECT Id, Product2.TDX_Asset__c, Product2.TDX_Asset__r.Name,Product2.TDX_Asset__r.Amenities__c, Product2.TDX_Asset__r.Overall_Rating__c FROM OrderItems) Id FROM Order WHERE AccountId = :accList[0].Id]){
                        for(OrderItem item : ord.OrderItems){
                            if(!assetIds.contains(item.Product2.TDX_Asset__c)){
                                AssetDetail detail = new AssetDetail();
                                detail.name = item.Product2.TDX_Asset__r.Name;
                                detail.rating = Integer.valueOf(item.Product2.TDX_Asset__r.Overall_Rating__c);
                                detail.amenities = item.Product2.TDX_Asset__r.Amenities__c;
                                assetIds.add(item.Product2.TDX_Asset__c);
                                assets.add(detail);
                            }
                        }
                    }
                    return new List<String>{JSON.serialize(assets)};
                }
           }
        }
        return new List<String>{'No previous bookings'};
    }
    
    
    public class AssetDetail {
        public String name;
        public Integer rating;
        public String amenities;
    }
}