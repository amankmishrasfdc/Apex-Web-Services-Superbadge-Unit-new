import { LightningElement,api } from 'lwc';

export default class AccountCSV extends LightningElement 
{
    @api recordId; 

    connectedCallback()
    {
        console.log('accountId'+ this.recordId);
        
    }

}
