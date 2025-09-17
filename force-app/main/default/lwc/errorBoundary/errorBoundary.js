import { LightningElement, api } from 'lwc';
import { errorService } from 'c/errorService';

export default class ErrorBoundary extends LightningElement {
    hasError = false;

    @api componentName = 'Unknown';

    // Public method to manually catch errors
    @api
    catchError(error) {
        this.handleError(error);
    }

    // Lifecycle hook to catch errors in reactive properties or template
    renderedCallback() {
        try {
            // any risky logic can go here
        } catch (error) {
            this.handleError(error);
        }
    }

    handleError(error) {
        this.hasError = true;

        // Send error to service (toast + Apex logging)
        errorService.handleError(error, this.dispatchEvent.bind(this), this.componentName);
    }
}
