import UIKit

class PaymentsViewCoordinator: Coordinator {

    let paymentsViewController: PaymentsViewController = PaymentsViewController()

    override init(router: RouterType) {
        super.init(router: router)
        
    }
    
    override func start() {
        paymentsViewController.modalPresentationStyle = .fullScreen
    }
    
    override func toPresentable() -> UIViewController {
        let navVC = UINavigationController(rootViewController: paymentsViewController)
        navVC.modalPresentationStyle = .fullScreen
//        navVC.addCloseButton()
        return navVC
    }
}

extension PaymentsViewCoordinator: ProductViewControllerDelegate{
    func goPaymentsViewController() {
        let productCoordinator = PaymentsViewCoordinator(router: router)
        addChild(productCoordinator)
        productCoordinator.start()
        router.push(productCoordinator, animated: true, completion: nil)
    }
    
    
}
