import { LightningElement, wire } from 'lwc';
import getAccountsAndContacts from '@salesforce/apex/AccountContactController.getAccountAndContacts';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    { label: 'Account Name', fieldName: 'Accountname', type: 'text' },
    { label: 'First Name', fieldName: 'FirstName', type: 'text' },
    { label: 'Last Name', fieldName: 'LastName', type: 'text' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'Contact Id', fieldName: 'contactID', type: 'text' },
    { label: 'Action',
        type: 'button',
        typeAttributes: {
            label: 'View Contact',
            name: 'view_contact',
            variant: 'base',
            iconName: 'utility:preview'
        }
    }
];

export default class AccountContactDataTable extends NavigationMixin(LightningElement) {
    data = [];
    columns = columns;

    @wire(getAccountsAndContacts)
    wireAccountsAndContacts({ error, data }) {
        if (data) {
            this.data = data;
            console.log('Data:', JSON.stringify(data));
        } else if (error) {
            console.error('Error fetching accounts and contacts: ', error);
        }
    }

    // Event handler for datatable row action
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('Action:', actionName);

        if (actionName === 'view_contact') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.contactID,
                    objectApiName: 'Contact',
                    actionName: 'view'
                }
            });
        }
    }
}
