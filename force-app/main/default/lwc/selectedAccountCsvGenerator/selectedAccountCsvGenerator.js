import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContacts from '@salesforce/apex/selectedAccountCsvController.getRelatedContacts';
import uploadFileToAccount from '@salesforce/apex/selectedAccountCsvController.uploadFileToAccount'; // Apex method for file upload
import sendEmailWithCsvAttachment from '@salesforce/apex/selectedAccountCsvController.sendEmailWithCsvAttachment';


export default class SelectedAccountCsvGenerator extends LightningElement {
    @api recordId; // Account Id
    contacts = [];
    selectedContacts = []; // To hold selected contacts
    error;

    columns = [
        { label: 'First Name', fieldName: 'FirstName' },
        { label: 'Last Name', fieldName: 'LastName' },
        { label: 'Email', fieldName: 'Email' },
        { label: 'Phone', fieldName: 'Phone' },
        { label: 'Account Id', fieldName: 'AccountId' },
    ];

    @wire(getContacts, { accountId: '$recordId' })
    wiredContacts({ error, data }) {
        if (data) {
            this.contacts = data;
            this.error = undefined;
        } else if (error) {
            this.contacts = [];
            this.error = error;
        }
    }

    // Enable/disable the button based on the selected contacts count
    get disableButton() {
        return this.selectedContacts.length === 0;
    }

    // Handle row selection event
    handleRowSelection(event) {
        // Capture selected rows from the datatable
        const selectedRows = event.detail.selectedRows;
        this.selectedContacts = selectedRows;
        console.log('Selected contacts:', this.selectedContacts);
    }

    // Handle the click event and generate CSV for selected contacts
    handleClick() {
        console.log('handleClick called');
        this.generateCSV(this.selectedContacts); // Use selected contacts for CSV
    }

    // Generate CSV and trigger download
    generateCSV(contacts) {
        console.log('Generating CSV for selected contacts:', contacts);

        // Ensure that contacts are being passed and are not empty
        if (contacts.length === 0) {
            console.error('No contacts selected for CSV generation.');
            return;
        }

        // Prepare CSV header and rows
        const csvHeader = this.columns.map(col => col.label).join(',');
        const csvRows = contacts.map(contact => 
            this.columns.map(col => contact[col.fieldName] || '').join(',')
        );
        const csvString = [csvHeader, ...csvRows].join('\n');
        
        if (!csvString) {
            console.error('CSV string is empty.');
            return;
        }

        // Create Data URI for download
        const encodedUri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvString);
        const anchor = document.createElement('a');
        anchor.href = encodedUri;
        anchor.download = 'contacts.csv';
        
        document.body.appendChild(anchor);
        anchor.click();
        document.body.removeChild(anchor);

        // Now call the Apex method to upload the file to Account
        uploadFileToAccount({ accountId: this.recordId, csvData: csvString, fileName: 'contacts.csv' })
            .then(() => {
                this.showToast('CSV generated and uploaded successfully');
                return sendEmailWithCsvAttachment({ accountId: this.recordId, csvData: csvString, fileName });
            })
            .then(() => {
                this.showToast('Email sent successfully with the CSV attachment');
            })
            .catch(error => {
                console.error('Error uploading file:', error);
                this.showToast('Error uploading file to Account', 'error');
            });


            
    }

    // Show toast notification
    showToast(message, variant = 'success') {
        const event = new ShowToastEvent({
            title: 'Result',
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}
