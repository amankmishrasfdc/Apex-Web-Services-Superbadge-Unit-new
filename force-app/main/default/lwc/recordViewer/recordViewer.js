import { LightningElement, track } from 'lwc';
import getRecords from '@salesforce/apex/RecordController.getRecords';

export default class RecordViewer extends LightningElement {
    @track selectedObject = 'Account';  // Default to Account
    @track records = [];  // Stores records from Apex
    @track error;  // Stores any error message

    objectOptions = [
        { label: 'Account', value: 'Account' },
        { label: 'Contact', value: 'Contact' },
        { label: 'Opportunity', value: 'Opportunity' }
    ];
    connectedCallback() {
        const path = window.location.pathname;
        const objectFromURL = path.split('/')[3];
    
        if (['Account', 'Contact', 'Opportunity'].includes(objectFromURL)) {
            this.selectedObject = objectFromURL;
        }
    }

    // Handle changes in object selection
    handleObjectChange(event) {
        this.selectedObject = event.detail.value;
    }

    // Handle Submit to fetch records
    handleSubmit() {
        this.error = null;
        this.records = [];  // Clear any previous data

        // Call Apex method to fetch records
        getRecords({ objectName: this.selectedObject })
            .then(data => {
                // Map records to include access flag and lock icon logic
                this.records = data.map(rec => {
                    const hasAccess = rec.hasAccess;  // Check if user has access
                    const label = hasAccess ? rec.Name : '🔒 ' + rec.Name;  // Add lock icon to restricted records

                    return {
                        ...rec,
                        cssClass: hasAccess ? '' : 'disabled-row',  // Apply disabled class for locked records
                        label,  // Set record label (name)
                        accessIcon: hasAccess ? null : 'utility:lock'  // Lock icon if access is restricted
                    };
                });
            })
            .catch(err => {
                // Handle error during the fetch
                this.error = 'Error fetching records: ' + (err.body?.message || err.message);
            });
    }
}
