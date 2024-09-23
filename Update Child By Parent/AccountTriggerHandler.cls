public class AccountTriggerHandler {
    /**
    * @description This method updates contacts phone whenever phone is changed in it's parent Account record
    * @param newList
    * @param oldMap
    */
    public static void updateContactsPhone(List<Account> newList, Map<Id,Account> oldMap){
        Set<Id> accIds = new Set<Id>();
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Account acc : newList){
            if((acc.Phone != oldMap.get(acc.Id).Phone)){// add acc.Phone != null if phone cannot be updated to null/blank
                accIds.add(acc.Id);
            }
        }

        Map<Id,Account> accMap = new Map<Id,Account>([select Id,(Select Id from Contacts) from Account where Id IN :accIds]);

        if(!accMap.isEmpty()){
            for(Account acc : newList){
                Account currentAcc = accMap.get(acc.Id);
                List<Contact> childContactsList = (List<Contact>)currentAcc.getSObjects('Contacts');
                for(Contact con : childContactsList){
                    con.Phone = acc.Phone;
                    contactsToUpdate.add(con);
                }
            }
        }

        if(!contactsToUpdate.isEmpty()){
            update contactsToUpdate;
        }
    }
}