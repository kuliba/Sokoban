
import Foundation

class ProductsModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet private weak var carouselViewController: CarouselViewController!

    override func awakeFromNib() {

        let configurator = ProductsModuleConfigurator()
        configurator.configureModuleForView(view: carouselViewController)
    }

}
