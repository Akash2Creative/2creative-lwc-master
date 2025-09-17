/**
 * @description                : This Lightning Web Component displays a paginated, searchable list of Salesforce Account records 
 *                               in a lightning-datatable. It fetches data from an Apex controller using an abstracted API service 
 *                               call that handles server communication and error routing. The component supports sorting, pagination 
 *                               with next/previous page controls, and search filtering. It optimizes server calls by limiting record 
 *                               counts per page and handling UI loading states. This design follows best practices including separation 
 *                               of concerns by delegating API calls to Apex and error handling to a centralized service, and uses track 
 *                               properties to ensure reactive updates in the UI.
 * @author                     : Akash Das
 * @group                      : 
 * @last modified on           : 09-17-2025
 * @last modified by           : Akash Das
 * @last modification details  :  
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   09-16-2025   Akash Das   Initial Version
**/
import { LightningElement, track } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';
import { callApex } from 'c/apiService'; // apiService routes errors to errorService
// columns for lightning-datatable
const COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'Industry', fieldName: 'Industry', type: 'text' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    { label: 'Website', fieldName: 'Website', type: 'url', typeAttributes: { label: { fieldName: 'Website' }, target: '_blank' } }
];

export default class AccountList extends LightningElement {
    @track accounts = [];
    @track loading = false;

    // pagination & search
    pageSize = 10;
    @track pageNumber = 1;
    @track totalPages = 1;
    @track searchKey = '';

    columns = COLUMNS;

    connectedCallback() {
        this.loadAccounts();
    }

    get hasData() {
        return Array.isArray(this.accounts) && this.accounts.length > 0;
    }

    get isFirstPage() {
        return this.pageNumber <= 1;
    }

    get isLastPage() {
        return this.pageNumber >= this.totalPages;
    }

    async loadAccounts() {
        this.loading = true;
        console.log('Loading accounts for page ', this.loading);
        try {
            // callApex will pass errors to errorService.handleError(this)
            const params = { searchKey: this.searchKey, pageSize: this.pageSize, pageNumber: this.pageNumber };
            const result = await callApex(getAccounts, params, this);
            console.log('The Result ', result);

            // If your Apex returns a ResponseWrapper, callApex should already unwrap .data
            // so `result` here is expected to be a list of Account records
            this.accounts = result || [];

            // Simple totalPages calc if backend returns count via another method.
            // For demo: compute totalPages from record count returned in header/data if available.
            // You should call a separate getAccountCount Apex method for accurate pagination.
            this.totalPages = this.accounts.length < this.pageSize ? 1 : Math.ceil(100 / this.pageSize); // placeholder
        } catch (err) {
            // Error already handled and logged by apiService/errorService.
            // Optionally you can perform extra local UI logic here.
            console.warn('Load accounts failed:', err);
        } finally {
            this.loading = false;
        }
    }

    onSearchChange(event) {
        this.searchKey = event.target.value;
        // reset to first page for new search
        this.pageNumber = 1;
        // debounce would be ideal — keep simple here
        this.loadAccounts();
    }

    onPrevPage() {
        if (this.pageNumber > 1) {
            this.pageNumber -= 1;
            this.loadAccounts();
        }
    }

    onNextPage() {
        if (this.pageNumber < this.totalPages) {
            this.pageNumber += 1;
            this.loadAccounts();
        }
    }
}
