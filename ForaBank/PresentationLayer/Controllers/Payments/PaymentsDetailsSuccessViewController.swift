/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import ReSwift


class PaymentsDetailsSuccessViewController: UIViewController, StoreSubscriber{
    
    weak var delegate: PaymentDetailsPresenterDelegate?




    private var isLoading = false
    private var canAskFee = false
    private var canMakePayment = false
    
    
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

    // MARK: - Properties

    var sourceConfig: Any?
    var sourceValue: Any?
    var destinationConfig: Any?
    var destinationValue: Any?
    var operationSum: String?

    // MARK: - Lifecycle

    func setSource(config: Any?, value: Any?) {
        switch value {
        case let sourceOption as PaymentOption:
            cardNameLabel.text = sourceOption.name
            cardSumLabel.text = "\(String(sourceOption.value)) ₽"
            cardNumberLabel.text = sourceOption.maskedNumber
        default:
            break
        }
    }

    func setDestination(config: Any?, value: Any?) {
        destinationSum.text = ""
        destinationNumber.text = ""
        switch (config, value) {
        case (is PaymentOptionsPagerItem, let destinationOption as PaymentOption):
            destinationName.text = (destinationOption.name)
            destinationSum.text = "\(String(destinationOption.value)) ₽"
            destinationNumber.text = destinationOption.maskedNumber
        case (is CardNumberPagerItem, let destinationOption as String):
            destinationName.text = destinationOption
        case (is PhoneNumberPagerItem, let destinationOption as String):
            destinationName.text = destinationOption
        case (is AccountNumberPagerItem, let destinationOption as String):
            destinationName.text = destinationOption
        default:
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        arrowImageView.image = arrowImageView.image?.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = .white

        returnButton.backgroundColor = .clear
        returnButton.layer.borderWidth = 1
        returnButton.layer.borderColor = UIColor.white.cgColor


        setSource(config: sourceConfig, value: sourceValue)
        setDestination(config: destinationConfig, value: destinationValue)
        sumLabel.text = "\(String(describing: operationSum!)) ₽"
    }
        
        
        
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


//        sumLabel.text = "\(sum) ₽"

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

