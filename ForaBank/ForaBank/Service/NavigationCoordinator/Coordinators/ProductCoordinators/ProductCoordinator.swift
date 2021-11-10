import UIKit

class ProductCoordinator: Coordinator {

    let productViewController = UINavigationController(rootViewController: ProductViewController())

    override init(router: RouterType) {
        super.init(router: router)
    }
    
    override func start() {
        productViewController.modalPresentationStyle = .fullScreen
    }
    
    override func toPresentable() -> UIViewController {
        return productViewController
    }
}
