public class ContactTriggerHandler {
    /**
    * @description this method updates description of Account record whenever contact's description is updated.
    * @param newList
    * @param oldMap
    */
    public static void updateDescriptionOfAccount(List<Contact> newList, Map<Id,Contact> oldMap){
        Map<Id,Contact> accIdVsContact = new Map<Id,Contact>();
        List<Account> accountsToUpdate = new List<Account>();

        for(Contact con : newList){
            if(con.AccountId != null && (oldMap == null || (oldMap != null && con.Description != oldMap.get(con.Id).Description))){
                accIdVsContact.put(con.AccountId,con);
            }
        }

        if(!accIdVsContact.isEmpty()){
            for(Id accId : accIdVsContact.keyset()){
                Account acc = new Account();
                acc.Id = accId;
                acc.Description = accIdVsContact.get(accId).Description;
                accountsToUpdate.add(acc);
            }
        }

        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }
}