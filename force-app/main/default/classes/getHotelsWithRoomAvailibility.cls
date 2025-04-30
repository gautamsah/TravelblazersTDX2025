public without sharing class getHotelsWithRoomAvailibility {
    @InvocableMethod(label='Get Available Hotels' description='Returns the list of available hotels in user input dates and city.' category='Asset')
	public static List<List<HotelResponse>> getAvailableHotels(List<HotelRequest> requests) {
		Date startDate = requests[0].startDate;
        Date endDate =requests[0].endDate;
        String city = requests[0].city;
        Set<Id> hotelIds = new Set<Id>();

        List<HotelResponse> hotelList = new List<HotelResponse>();
        List<TDX_Asset__c> hotelDetailsResult = new List<TDX_Asset__c>();
        Boolean isRoomFull = false;
        List<Product2> roomDetails = [SELECT Id, Name, ProductCode, TDX_Asset__c , TDX_Asset__r.Name, TDX_Asset__r.City__c, Room_Type__c, Hotel_Product_Type__c, Product_Final_Unit_Price__c, Max_No_Of_Guest__c, Description , (SELECT Id,Available_Slots__c FROM Booked_Dates__r  WHERE Start_Date__c >= :startDate AND End_Date__c <= :endDate) FROM Product2 WHERE  TDX_Asset__r.City__c =:city];
system.debug('roomDetails' + roomDetails )    ;    
if(!roomDetails.isEmpty()){
            For(Product2 room : roomDetails){
                System.debug('roomDetails' + roomDetails);
                
                if(room.Booked_Dates__r.isEmpty()){
                    hotelIds.add(room.TDX_Asset__c);
                }
                else{
                    isRoomFull = false;
                    For(Booked_Date__c bookedDate : room.Booked_Dates__r){
                        System.debug('inside second For');
                        if(bookedDate.Available_Slots__c == 0){
                            System.debug('inside 2nd if');
                            isRoomFull = true;
                            break;
                        }
                        else{
                            System.debug('inside second else');
                            continue;
                        }
                    }
                    if(!isRoomFull){
                        System.debug('inside last if');
                        hotelIds.add(room.TDX_Asset__c);
                    }
                }
            }
            if(!hotelIds.isEmpty()) {
                hotelDetailsResult = [SELECT Id,Name,City__c FROM TDX_Asset__c  Where Id IN: hotelIds];
                for(TDX_Asset__c  hotel : hotelDetailsResult){
                    HotelResponse hr = new HotelResponse();
                    hr.Name = hotel.Name;
                    //hr.rating = hotel.Overall_Rating__c;
                    hotelList.add(hr);
                }
            }
        }
        return new List<List<HotelResponse>>{ hotelList };
    }
    public class HotelRequest {
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
            description='City in which we want to search the hotel'
        )
        public String city;
    }

    public class HotelResponse {
        @InvocableVariable(
            description='Name of hotel'
        )
        public String name;
        //@InvocableVariable(
          //  description='Rating of the available hotel'
        //)
        //public Decimal rating;
    }
}