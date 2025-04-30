public class GetAssetsFromNames {
    
    @InvocableMethod(label='Get Assets From String' description='Returns the list of assets from names')
    public static List<String> getAssetsFromCommaSeparatedString(List<String> fullString){
        List<AssetDetail> assetDetails = new List<AssetDetail>();
        List<String> stringList = new List<String>();
        if(fullString != null && fullString.size()>0){
            stringList = fullString[0].split(',');
        }
        for(TDX_Asset__c asset :[SELECT Id, Name, Amenities__c, Overall_Rating__c FROM TDX_Asset__c WHERE Name IN : stringList]){
            AssetDetail detail = new AssetDetail();
            detail.name = asset.Name;
            detail.rating = Integer.valueOf(asset.Overall_Rating__c);
            detail.amenities = asset.Amenities__c;
            assetDetails.add(detail);
        }
        
        return new List<String>{JSON.serialize(assetDetails)};
    }
    
    public class AssetDetail {
        public String name;
        public Integer rating;
        public String amenities;
    }

}