/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit

class PaymentsDetailsSuccessViewController: UIViewController {

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

    // MARK: - Actions
    @IBAction func returnButtonClicked(_ sender: Any) {
        dismissToRootViewController()
    }

    var operationSum: String?
    var sourceOption: PaymentOption?
    var destinationOption: PaymentOption?
    var destinationNum: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        arrowImageView.image = arrowImageView.image?.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = .white

        returnButton.backgroundColor = .clear
        returnButton.layer.borderWidth = 1
        returnButton.layer.borderColor = UIColor.white.cgColor

        cardNameLabel.text = sourceOption?.name
        if let value = destinationOption?.value {
            cardSumLabel.text = String(describing: value)
        }
        cardNumberLabel.text = sourceOption?.maskedNumber

        destinationName.text = destinationOption?.name
        if let value = destinationOption?.value {
            destinationSum.text = String(describing: value)
        }

        if destinationOption == nil {
            destinationNumber.text = destinationNum
        } else {
            destinationNumber.text = destinationOption?.maskedNumber
        }

        sumLabel.text = "\(operationSum!) ₽"
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
