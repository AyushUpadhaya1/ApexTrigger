public without sharing class EmployeeTriggerHandler {
    public static void maxMinSalaryOnTechFirm(List<Contact> newList,Map<Id,Contact> oldMap, List<Contact> oldList, Map<Id,Contact> newMap){
        Set<Id> empIds = new Set<Id>();
        List<Account> accToUpdate = new List<Account>();
        Map<Id,List<Decimal>> techFirmIdVsMaxMinSalary = new Map<Id,List<Decimal>>();

        for(Contact em : newList){
            empIds.add(em.AccountId);
        }

        List<AggregateResult> maxMinResult = [select AccountId,MAX(Salary__c),MIN(Salary__c) FROM Contact WHERE AccountId IN :empIds
                                            GROUP BY AccountId];

        for(AggregateResult ar : maxMinResult){
            List<Decimal> maxMinPair = new List<Decimal>{(Decimal)ar.get('expr0'),(Decimal)ar.get('expr1')};
            techFirmIdVsMaxMinSalary.put((Id)ar.get('AccountId'),maxMinPair);
        }

        //Update Parent Account
        if(!techFirmIdVsMaxMinSalary.isEmpty()){
            for(Id accId : techFirmIdVsMaxMinSalary.keyset()){
                List<Decimal> maxMinPair = techFirmIdVsMaxMinSalary.get(accId);
                Account acc = new Account();
                acc.Id = accId;
                acc.Max_Salary__c = maxMinPair != null ? maxMinPair[0] : acc.Max_Salary__c;
                acc.Min_Salary__c = maxMinPair != null ? maxMinPair[1] : acc.Min_Salary__c;
                accToUpdate.add(acc);
            }            
        }

        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
    }
}