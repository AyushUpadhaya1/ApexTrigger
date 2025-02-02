public class OppLineItemTriggerHelper {
    public static void afterInsertOperation(List<OpportunityLineItem> newList){
        Set<Id> oppIds = new Set<Id>();
        
        for(OpportunityLineItem item : newList){
            if(item.OpportunityId != null && item.UnitPrice > 50000){
                oppIds.add(item.OpportunityId);
            }
        }
        updateAccountTotalProduct(oppIds);
    }

    public static void afterUpdateOperation(List<OpportunityLineItem> newList, Map<Id,OpportunityLineItem> oldMap){
        Set<Id> oppIds = new Set<Id>();
        for(OpportunityLineItem item : newList){
            OpportunityLineItem oldItem = oldMap.get(item.Id);
            if(item.OpportunityId != null && item.UnitPrice != oldItem.UnitPrice){
                oppIds.add(item.OpportunityId);
            }
            if(item.OpportunityId != oldItem.OpportunityId){
                oppIds.add(item.OpportunityId);
                oppIds.add(oldItem.OpportunityId);
            }
        }
        system.debug(oppIds);
        updateAccountTotalProduct(oppIds);
    }

    public static void afterDeleteOperation(List<OpportunityLineItem> oldList){
        Set<Id> oppIds = new Set<Id>();
        for(OpportunityLineItem item : oldList){
            if(item.OpportunityId != null && item.UnitPrice > 50000){
                oppIds.add(item.OpportunityId);
            }
        }
        updateAccountTotalProduct(oppIds);
        
    }
    
    public static void afterUndeleteOperation(List<OpportunityLineItem> newList){
        Set<Id> oppIds = new Set<Id>();
        for(OpportunityLineItem item : newList){
            if(item.OpportunityId != null && item.UnitPrice > 50000){
                oppIds.add(item.OpportunityId);
            }
        }
        updateAccountTotalProduct(oppIds);
    }
    
    public static void updateAccountTotalProduct(Set<Id> oppIds){
        if(!oppIds.isEmpty()){
            Set<Id> accIds = new Set<Id>();
            Map<Id,Integer> accIdVsLineItemCount = new Map<Id,Integer>();
            List<Account> accToUpdate = new List<Account>();

            //Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([select Id, AccountId, (select id from OpportunityLineItems where UnitPrice > 50000) from Opportunity where Id IN :oppIds]);
            List<AggregateResult> lst = [select Opportunity.AccountId accId, COUNT(Id) from OpportunityLineItem 
                                         where (OpportunityId != null AND (OpportunityId IN :oppIds) AND UnitPrice > 50000 AND Opportunity.AccountId != null) 
                                         GROUP BY Opportunity.AccountId];

            for(AggregateResult ar : lst){
                Id accId = (Id)ar.get('accId');
                Integer total_count = (Integer)ar.get('expr0');
                accIds.add(accId);
                accIdVsLineItemCount.put(accId,total_count);
            }

            // if(!oppMap.isEmpty()){
            //     for(Opportunity opp : oppMap.values()){
            //         if(opp.AccountId != null && opp.OpportunityLineItems != null){
            //             accIds.add(opp.AccountId);
            //             system.debug('items-----> '+opp.OpportunityLineItems);
            //             system.debug('size----> '+opp.OpportunityLineItems.size());
            //             accIdVsLineItemCount.put(opp.AccountId,opp.OpportunityLineItems.size());
            //         }
            //     }
            // }
            
            for(Id accId : accIds){
                if(!accIdVsLineItemCount.isEmpty()){
                    Account acc = new Account(Id = accId,Total_Revenue__c = accIdVsLineItemCount.get(accId));
                    accToUpdate.add(acc);
                }
            }
            
            if(!accToUpdate.isEmpty()){
                update accToUpdate;
            }
        }
    }
}