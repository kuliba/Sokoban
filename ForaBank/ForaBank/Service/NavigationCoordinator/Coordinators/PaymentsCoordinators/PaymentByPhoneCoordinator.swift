import UIKit

class PaymentByPhoneCoordiantor: Coordinator {

    let contactsViewController = UINavigationController(rootViewController: ContactsViewController())

    override init(router: RouterType) {
        super.init(router: router)
    }
    
    override func start() {
        contactsViewController.modalPresentationStyle = .formSheet
    }
    
    override func toPresentable() -> UIViewController {
        return contactsViewController
    }
}
