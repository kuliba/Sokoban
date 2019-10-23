/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import ReSwift

class PaymentsDetailsSuccessViewController: UIViewController, StoreSubscriber {

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
    @IBAction func createTemplate(_ sender: Any) {
        let alertVC = UIAlertController(title: "Функционал недоступен", message: "Функционал временно недоступен", preferredStyle: .alert)
              let okAction = UIAlertAction(title: "Понятно", style: .cancel, handler: nil)
              alertVC.addAction(okAction)
              show(alertVC, sender: self)
    }
    
    @IBOutlet weak var createTemplate: ButtonRounded!
    
    // MARK: - Actions
    @IBAction func returnButtonClicked(_ sender: Any) {
        dismissToRootViewController()
    }

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
        //        defaultSourcePaymentOption = state.sourceOption
        //        defaultDestinationPaymentOption = state.destinationOption
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

        guard let sourceOption = state.sourceOption, let destinationOption = state.destinationOption, let sum = state.paymentSum else {
            return
        }

        cardNameLabel.text = sourceOption.name
        cardSumLabel.text = String(describing: sourceOption.value)
        cardNumberLabel.text = sourceOption.maskedNumber

        destinationName.text = destinationOption.name
        destinationSum.text = String(describing: destinationOption.value)
        destinationNumber.text = destinationOption.maskedNumber

        sumLabel.text = "\(sum) ₽"
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
