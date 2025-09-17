import { LightningElement, api } from 'lwc';

export default class HeaderStandard extends LightningElement {
    @api userName = 'User';

    get userInitials() {
        return this.userName.split(' ').map(n => n[0]).join('').toUpperCase();
    }

    navigateHome() {
        console.log('Navigate Home');
    }

    navigateAccounts() {
        console.log('Navigate Accounts');
    }

    navigateDashboard() {
        console.log('Navigate Dashboard');
    }
}
