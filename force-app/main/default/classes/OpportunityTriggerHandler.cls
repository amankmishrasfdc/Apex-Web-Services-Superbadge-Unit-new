public with sharing class OpportunityTriggerHandler {
    

    public static void preventMultipleOppForAcc(List<Opportunity> newOppList)
    {
        if(newOppList.isEmpty())
        {
            return;
        }

        Map<Id,List<Opportunity>> accWithOpps = new Map<Id,List<Opportunity>>();
        for (Opportunity opp : newOppList) {
            if(opp.AccountId !=null)
            {
                if (!accWithOpps.containsKey(opp.AccountId)) 
                {
                    accWithOpps.put(opp.AccountId, new List<Opportunity>());
                }
                accWithOpps.get(opp.AccountId).add(opp);

                }
                
            }

            List<Opportunity> existingOpportunity = [SELECT Id, AccountId, CreatedDate 
            FROM Opportunity 
            WHERE AccountId IN :accWithOpps.keySet()
            AND CreatedDate >= TODAY
            AND CreatedDate < :Date.today().addDays(1)];



}
