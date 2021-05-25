

import Foundation

protocol PaymentOptionsState: class {
    func state(_ : Bool?)
}

class PaymentOptionCellProvider: ICellProvider, PaymentOptionsState {
   
    weak var delegate: PaymentOptionsState?
    
    func state(_: Bool?) {
        currentBlock = true
    }
    
    var segueId: String?
    
    var currentBlock: Bool?
    var currentValue:  [PaymentOption]? {
        didSet{
//            self.currentValue = currentValue?.filter({$0.currencyCode == "RUB"})
        }
    }
    var currentBlockValue:  [PaymentOption]? {
        didSet{
//            self.currentValue = currentValue?.filter({$0.currencyCode == "RUB"})
        }
    }
    var isLoading: Bool = false {
        didSet {
            loadingCallback?(isLoading)
        }
    }
    var loadingCallback: ((_ isLoaing: Bool) -> ())?

    func getData(completion: @escaping ([IPresentationModel]) -> ()) {
        isLoading = true
        NetworkManager.shared().allPaymentOptions { [weak self] (success, paymentOptions) in
            
            guard success, let options = paymentOptions else {
                return
            }
            if self?.currentBlock ?? false{
                self?.currentValue = options
            } else {
                self?.currentBlockValue = options.filter({$0.currencyCode != "RUB"})
            }
            
            self?.isLoading = false
            completion(options)
        }
    }
}
