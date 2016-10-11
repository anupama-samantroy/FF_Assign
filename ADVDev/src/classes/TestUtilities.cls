/* Class Name  : TestUtilities
* Description  : This is the Test Utility Class to be used in the actual Test Classes
* Created By   : Developer 1     
* Created Date : 08-10-2015
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer 1              08-10-2015           1000                   Initial Version
*/
@isTest
Public class TestUtilities{
    
    /*
    @description   : Method to create Florist user
    @parameters    : None
    @return        : User        
    */
    public static User createFloristUser(){
        // creating a user of profile Florist 
        Id profileId = [SELECT ID FROM Profile WHERE Name = 'Florist' LIMIT 1].id;
        
        
        User floristUser = new User (Alias = 'testUser', Email = 'test@bb.com.test', EmailEncodingKey='UTF-8', 
                               LastName= 'lastName', LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', 
                               // make sure user are created with unique username
                               UserName='test@bb' + string.valueOf(system.now().getTime())+ '.com.test');
        return floristUser;
    }
    
    /*
    @description   : Method to create Customers 
    @parameters    : None
    @return        : List of Lead
    */
    public static List<Lead> createCustomers(){
        //Create the Customer Records
        List<Lead> lstCustomers = new List<Lead>();
        for(Integer i = 0 ; i < 5 ; i ++){
        
            Lead testLead1 = new Lead(FirstName = 'John'+i, LastName = 'Cena'+i, Company = 'WWE');
           
            lstCustomers.add(testLead1);
        }      
        return lstCustomers;        
    }
    /*
    @description   : Method to create Flowers record
    @parameters    : None
    @return        : List of product2        
    */
    public static List<Product2> createFlowers(){
        //create Flower records
        List<Product2> lstFlowers = new List<Product2>();
        
        Product2 flower1 = new Product2(Name = 'Flower1', Family = 'Family1', Color__c = 'Blue', Initial_Inventory__c = 100);
        Product2 flower2 = new Product2(Name = 'Flower2', Family = 'Family2', Color__c = 'Green', Initial_Inventory__c = 100); 
        Product2 flower3 = new Product2(Name = 'Flower3', Family = 'Family3', Color__c = 'Orange', Initial_Inventory__c = 100);         
        Product2 flower4 = new Product2(Name = 'Flower4', Family = 'Family4', Color__c = 'Red', Initial_Inventory__c = 100); 
        Product2 flower5 = new Product2(Name = 'Flower5', Family = 'Family5', Color__c = 'Yellow', Initial_Inventory__c = 100); 
        Product2 flower6 = new Product2(Name = 'Flower6', Family = 'Family6', Color__c = 'Blue', Initial_Inventory__c = 100);
        Product2 flower7 = new Product2(Name = 'Flower7', Family = 'Family7', Color__c = 'Green', Initial_Inventory__c = 100); 
        Product2 flower8 = new Product2(Name = 'Flower8', Family = 'Family8', Color__c = 'Orange', Initial_Inventory__c = 100);         
        Product2 flower9 = new Product2(Name = 'Flower9', Family = 'Family9', Color__c = 'Red', Initial_Inventory__c = 100); 
        Product2 flower10 = new Product2(Name = 'Flower10', Family = 'Family10', Color__c = 'Yellow', Initial_Inventory__c = 100);
        lstFlowers.add(flower1);
        lstFlowers.add(flower2); 
        lstFlowers.add(flower3); 
        lstFlowers.add(flower4);    
        lstFlowers.add(flower5);    
        lstFlowers.add(flower6);
        lstFlowers.add(flower7); 
        lstFlowers.add(flower8); 
        lstFlowers.add(flower9);    
        lstFlowers.add(flower10); 
        return lstFlowers;    
    }
    
    /*
    @description   : Method to create the Bloom
    @parameters    : Bouquet Id, Flower Id and Quantity
    @return        : Bloom__c record        
    */
    public static Bloom__c createBloom(Id BouquetId, Id flowerId, Integer Quantity){
        Bloom__c blm = new Bloom__c(Bouquet__c = BouquetId, Flower__c = flowerId, Quantity__c =  Quantity);
        return blm;
    }
    
    /*
    @description   : Method to create Flowers records
    @parameters    : None
    @return        : List of product2        
    */
    public static List<Product2> createFlowersForPage(){
        //create Flower records
        List<Product2> lstFlowers = new List<Product2>();
        
        Product2 flower1 = new Product2(Name = 'Flower1', Family = 'Family1', Color__c = 'Blue', Initial_Inventory__c = 100, Cost__c = 1);
        Product2 flower2 = new Product2(Name = 'Flower2', Family = 'Family1', Color__c = 'Green', Initial_Inventory__c = 100, Cost__c = 1); 
        Product2 flower3 = new Product2(Name = 'Flower3', Family = 'Family1', Color__c = 'Orange', Initial_Inventory__c = 100, Cost__c = 1);         
        Product2 flower4 = new Product2(Name = 'Flower4', Family = 'Family1', Color__c = 'Red', Initial_Inventory__c = 100, Cost__c = 1); 
        Product2 flower5 = new Product2(Name = 'Flower5', Family = 'Family1', Color__c = 'Yellow', Initial_Inventory__c = 100, Cost__c = 1); 
        Product2 flower6 = new Product2(Name = 'Flower6', Family = 'Family2', Color__c = 'Blue', Initial_Inventory__c = 100, Cost__c = 2);
        Product2 flower7 = new Product2(Name = 'Flower7', Family = 'Family2', Color__c = 'Green', Initial_Inventory__c = 100, Cost__c = 2); 
        Product2 flower8 = new Product2(Name = 'Flower8', Family = 'Family2', Color__c = 'Orange', Initial_Inventory__c = 100, Cost__c = 2);         
        Product2 flower9 = new Product2(Name = 'Flower9', Family = 'Family2', Color__c = 'Red', Initial_Inventory__c = 100, Cost__c = 2); 
        Product2 flower10 = new Product2(Name = 'Flower10', Family ='Family2', Color__c = 'Yellow', Initial_Inventory__c = 100, Cost__c = 2);
        Product2 flower11 = new Product2(Name = 'Flower11', Family ='Family3', Color__c = 'Blue', Initial_Inventory__c = 100, Cost__c = 3);
        Product2 flower12 = new Product2(Name = 'Flower12', Family ='Family3', Color__c = 'Green', Initial_Inventory__c = 100, Cost__c = 3);
        Product2 flower13 = new Product2(Name = 'Flower13', Family ='Family3', Color__c = 'Orange', Initial_Inventory__c = 100, Cost__c = 3);
        Product2 flower14 = new Product2(Name = 'Flower14', Family ='Family3', Color__c = 'Red', Initial_Inventory__c = 100, Cost__c = 3);
        Product2 flower15 = new Product2(Name = 'Flower15', Family ='Family3', Color__c = 'Yellow', Initial_Inventory__c = 100, Cost__c = 3);
        Product2 flower16 = new Product2(Name = 'Flower16', Family ='Family3', Color__c = 'Green', Initial_Inventory__c = 100, Cost__c = 3);
        lstFlowers.add(flower1);
        lstFlowers.add(flower2); 
        lstFlowers.add(flower3); 
        lstFlowers.add(flower4);    
        lstFlowers.add(flower5);    
        lstFlowers.add(flower6);
        lstFlowers.add(flower7); 
        lstFlowers.add(flower8); 
        lstFlowers.add(flower9);    
        lstFlowers.add(flower10);
        lstFlowers.add(flower11);
        lstFlowers.add(flower12);
        lstFlowers.add(flower13);
        lstFlowers.add(flower14);
        lstFlowers.add(flower15); 
        lstFlowers.add(flower16); 
        return lstFlowers;    
    }
}