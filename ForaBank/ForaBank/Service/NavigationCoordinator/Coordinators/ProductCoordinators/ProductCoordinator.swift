import UIKit

class ProductCoordinator: Coordinator {

    let productViewController: ProductViewController = ProductViewController()

    override init(router: RouterType) {
        super.init(router: router)
        
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


