/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import ReSwift

protocol IPaymetsApiC {
    func getPaymentsList(completionHandler: @escaping (_ success: Bool, _ payments: [Operations]?) -> Void)
    func allPaymentOptions(completionHandler: @escaping (Bool, [PaymentOption]?) -> Void)
    func prepareCard2Card(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?) -> Void)
    func prepareCard2Phone(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?) -> Void)
    func makeCard2Card(code: String, completionHandler: @escaping (Bool) -> Void)
}



class PaymentsDetailsSuccessViewController: UIViewController, StoreSubscriber, IPaymentDetailsPresenter,PaymentDetailsPresenterDelegate, PaymentsDetailsViewControllerDelegate {
    func didUpdate(isLoading: Bool, canAskFee: Bool, canMakePayment: Bool) {
        
    }
    
    func didFinishPreparation(success: Bool) {
        
    }
    
    weak var delegate: PaymentDetailsPresenterDelegate?

    private var sourcePaymentOption: PaymentOptionType? {
        didSet {
            onSomeValueUpdated()
        }
    }
    private var destinaionPaymentOption: PaymentOptionType? {
        didSet {
            onSomeValueUpdated()
        }
    }
    private var amount: Double? {
        didSet {
            onSomeValueUpdated()
        }
    }
    private func onSomeValueUpdated() {
        guard let destination = destinaionPaymentOption, let source = sourcePaymentOption else {
            return
        }

       

        let canStartWithOptions = amount != nil
        canAskFee = canStartWithOptions

        delegate?.didUpdate(isLoading: isLoading, canAskFee: canAskFee, canMakePayment: canMakePayment)
    }
    func preparePayment() {

        guard let amount = self.amount else {
            return
        }
        delegate?.didUpdate(isLoading: true, canAskFee: canAskFee, canMakePayment: canMakePayment)

        let completion: (Bool, String?) -> Void = { [weak self] (success, token) in
            guard let canAskFee = self?.canAskFee, let canMakePayment = self?.canMakePayment else {
                return
            }
            self?.delegate?.didUpdate(isLoading: false, canAskFee: canAskFee, canMakePayment: canMakePayment)
            self?.delegate?.didFinishPreparation(success: success)
        }

        switch (sourcePaymentOption, destinaionPaymentOption) {
        case (.option(let sourceOption), .option(let destinationOption)):
            NetworkManager.shared().prepareCard2Card(from: sourceOption.number, to: destinationOption.number, amount: amount, completionHandler: completion)
            break
        case (.option(let sourceOption), .phoneNumber(let phoneNumber)):
            NetworkManager.shared().prepareCard2Phone(from: sourceOption.number, to: phoneNumber, amount: amount, completionHandler: completion)
            break
        case (.option(let sourceOption), .cardNumber(let stringNumber)), (.option(let sourceOption), .accountNumber(let stringNumber)):
            NetworkManager.shared().prepareCard2Card(from: sourceOption.number, to: stringNumber, amount: amount, completionHandler: completion)
            break
        default:
            break
        }
        
    }

    private var isLoading = false
    private var canAskFee = false
    private var canMakePayment = false

  
    
  
  
    
    func didChangeSource(paymentOption: PaymentOptionType) {
          print(paymentOption)
          sourcePaymentOption = paymentOption
      }

      func didChangeDestination(paymentOption: PaymentOptionType) {
          print(paymentOption)
          destinaionPaymentOption = paymentOption
      }

      func didChangeAmount(amount: Double?) {
          self.amount = amount
      }

      func didPressPrepareButton() {
          preparePayment()
      }

      func didPressPaymentButton() {

      }
    
    
    
    
    
    func prepareCard2Phone(from sourceNumber: String, to destinationNumber: String, amount: Double, completionHandler: @escaping (Bool, String?) -> Void){
        return
    }
    
    
    var delegatePresent: PaymentDetailsPresenterDelegate?
    

    // MARK: - Properties
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var returnButton: ButtonRounded!

    @IBOutlet weak var sumLabel: UILabel!

    @IBOutlet weak var cardNameLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var cardSumLabel: UILabel!

    @IBOutlet weak var destinationName: UILabel!
    @IBOutlet weak var destinationNumber: UILabel!
    @IBOutlet weak var destinationSum: UILabel!
    var sourceOption: String = ""
    var phoneNumber: String = ""

    var sourceConfigurations: [ICellConfigurator]?
       var destinationConfigurations: [ICellConfigurator]?
    // MARK: - Actions
    @IBAction func returnButtonClicked(_ sender: Any) {
        dismissToRootViewController()
    }
    private let sourceProvider = PaymentOptionCellProvider()
       private let destinationProvider = PaymentOptionCellProvider()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        arrowImageView.image = arrowImageView.image?.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = .white

        returnButton.backgroundColor = .clear
        returnButton.layer.borderWidth = 1
        returnButton.layer.borderColor = UIColor.white.cgColor
        
        
        
            }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        store.subscribe(self) { state in
            state.select { $0.productsState }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }

    internal func newState(state: ProductState) {
         //      defaultSourcePaymentOption = state.sourceOption
        //       defaultDestinationPaymentOption = state.destinationOption
        //
        //        if (defaultSourcePaymentOption != nil) {
        //            selectedSourcePaymentOption = defaultSourcePaymentOption
        //        }
        //
        //        if (defaultDestinationPaymentOption != nil) {
        //            selectedDestinationPaymentOption = defaultDestinationPaymentOption
        //        }

        //optionsTable.reloadData()
        //        setUpRemittanceViews()

    

        cardNameLabel.text = state.products![0].name
        cardSumLabel.text = String(state.products![0].balance)
        cardNumberLabel.text = state.products![0].numberMasked
        sumLabel.text = "Nothing"
        destinationName.text = "Nothing"
        destinationNumber.text = "Nothing"
        destinationSum.text = "Nothing"


    }

    // MARK: - Methods

    func dismissToRootViewController() {
        if let first = presentingViewController,
            let second = first.presentingViewController,
            let third = second.presentingViewController {

            first.view.isHidden = true
            second.view.isHidden = true
            third.dismiss(animated: false)
        }
    }
}

