import { LightningElement } from 'lwc';
import { errorService } from 'c/errorService';
import throwErrorApex from '@salesforce/apex/TestErrorController.throwError';

export default class TestError extends LightningElement {

    // Simulate a JS runtime error
    throwJsError() {
        try {
            // Intentionally undefined variable error
            let x = undefinedVariable + 1;
        } catch (error) {
            //console.log('JS error caught:', this.dispatchEvent.bind(this));
            errorService.handleError(error, this.dispatchEvent.bind(this), 'TestError');
        }
    }

    // Simulate an Apex error
    async throwApexError() {
        try {
            await throwErrorApex();
        } catch (error) {
            //console.log('Apex error caught:', this.dispatchEvent.bind(this));
            errorService.handleError(error, this.dispatchEvent.bind(this), 'TestError');
        }
    }
}
