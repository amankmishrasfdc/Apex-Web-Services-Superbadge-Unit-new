public with sharing class AccountContactController 
{
    public class contactWarpper
    {
        @AuraEnabled public string contactID;
        @AuraEnabled public string FirstName;
        @AuraEnabled public string LastName;
        @AuraEnabled public string Email;
        @AuraEnabled public string Accountname;
    }
@AuraEnabled(cacheable=true)
    public static List<contactWarpper> getAccountAndContacts()
    {
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, Account.Name FROM Contact Where Account.Name != null Order By Account.Name];
        List<contactWarpper> contactList = new List<contactWarpper>();
        for (Contact con : contacts) 
        {
            contactWarpper wrapper = new contactWarpper();
            wrapper.contactID = con.Id;
            wrapper.FirstName = con.FirstName;
            wrapper.LastName = con.LastName;
            wrapper.Email = con.Email;
            wrapper.Accountname = con.Account.Name;
            contactList.add(wrapper);
        }

        return contactList;
    }
     
}