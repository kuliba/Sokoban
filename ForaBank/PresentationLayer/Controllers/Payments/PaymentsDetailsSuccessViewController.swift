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

