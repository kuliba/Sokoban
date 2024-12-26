import UIKit

class ProductCoordinator: Coordinator {

    let productViewController: ProductViewController = ProductViewController()

    override init(router: RouterType) {
        super.init(router: router)
        productViewController.delegatePaymentVc = self
        
    }
    
    override func start() {
        productViewController.modalPresentationStyle = .fullScreen
    }
    
    override func toPresentable() -> UIViewController {
        let navVC = UINavigationController(rootViewController: productViewController)
        navVC.modalPresentationStyle = .fullScreen
//        navVC.addCloseButton()
        return navVC
    }
}

extension ProductCoordinator: ProductViewControllerDelegate{
    
    func goPaymentsViewController() {
        let productCoordinator = PaymentsViewCoordinator(router: router)
        addChild(productCoordinator)
        productCoordinator.start()
        router.present(productCoordinator, animated: true)
    } 
}



