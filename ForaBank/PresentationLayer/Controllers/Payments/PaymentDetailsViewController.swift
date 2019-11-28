/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import ReSwift

typealias AccountNumberPagerItem = PagerViewCellHandler<TextFieldPagerViewCell, AccountNumberCellProvider>
typealias CardNumberPagerItem = PagerViewCellHandler<TextFieldPagerViewCell, CardNumberCellProvider>
typealias PaymentOptionsPagerItem = PagerViewCellHandler<DropDownPagerViewCell, CardNumberCellProvider>
typealias PhoneNumberPagerItem = PagerViewCellHandler<TextFieldPagerViewCell, PhoneNumberCellProvider>

protocol PaymentsDetailsViewControllerDelegate {

    func didChangeSource(paymentOption: PaymentOptionType)
    func didChangeDestination(paymentOption: PaymentOptionType)

    func didChangeSum(sum: Double)

    func didPressFeeButton()
    func didPressPaymentButton()
}

class PaymentsDetailsViewController: UIViewController, StoreSubscriber {

    // MARK: - Properties
    @IBOutlet weak var sourcePagerView: PagerView!
    @IBOutlet weak var destinationPagerView: PagerView!

    @IBOutlet weak var picker: UIView!
    @IBOutlet weak var pickerImageView: UIImageView!
    @IBOutlet weak var sumTextField: UITextField!
    @IBOutlet weak var containterView: RoundedEdgeView!
    @IBOutlet weak var pickerLabel: UILabel!
    @IBOutlet weak var pickerButton: UIButton!

    // MARK: - Actions

    @IBAction func sendButtonClicked(_ sender: Any) {
//        makeC2C()

        guard let sourceConfig = sourceConfigurations?[sourcePagerView.currentIndex], let destinationConfig = destinationConfigurations?[destinationPagerView.currentIndex], let amount = Double(sumTextField.text!), let sourceOption = sourceConfig.item as? PaymentOption else {
            return
        }
        switch sourceConfig {
        case is AccountNumberPagerItem:
            delegate?.didChangeSource(paymentOption: .account(sourceOption))
            break
        case is CardNumberPagerItem:
            delegate?.didChangeSource(paymentOption: .card(sourceOption))
            break
        default:
            break
        }

        switch (destinationConfig, destinationConfig.item) {
        case (is AccountNumberPagerItem, let destinationOption as PaymentOption):
            delegate?.didChangeDestination(paymentOption: .account(destinationOption))
            break
        case (is CardNumberPagerItem, let destinationOption as PaymentOption):
            delegate?.didChangeDestination(paymentOption: .card(destinationOption))
            break
        case (is CardNumberPagerItem, let destinationOption as String):
            delegate?.didChangeDestination(paymentOption: .phoneNumber(destinationOption))
            break
        default:
            break
        }

        let alertVC = UIAlertController(title: "Ошибка", message: "При выполнении платежа произошла ошибка, попробуйте ещё раз позже", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Продолжить", style: .cancel, handler: nil)
        alertVC.addAction(cancelButton)
        self.present(alertVC, animated: true, completion: nil)
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func pickerButtonClicked(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Payment", bundle: nil)
            .instantiateViewController(withIdentifier: "ppvc") as? OptionPickerViewController {
            sender.isEnabled = false
            // Pass picker frame to determine picker popup coordinates
            vc.pickerFrame = picker.convert(pickerLabel.frame, to: view)

            vc.pickerOptions = ["За завтраки", "За тренировку", "За обеды"]
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }

    var presenter: PaymentDetailsPresenter?
    var sourceConfigurations: [ICellConfigurator]?
    var destinationConfigurations: [ICellConfigurator]?
    var delegate: PaymentsDetailsViewControllerDelegate?

    var remittanceSourceView: RemittanceOptionView!
    var remittanceDestinationView: RemittanceOptionView!
    var selectedViewType: Bool = false //false - source; true - destination
    var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)

// MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayout()

        if let source = sourceConfigurations, let dest = destinationConfigurations {
            sourcePagerView.setConfig(config: source)
            destinationPagerView.setConfig(config: dest)
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addGradientView() // TODO: Replace with GradientView view
    }

    internal func newState(state: ProductState) {
        //optionsTable.reloadData()
//        setUpRemittanceViews()
    }

    private func setUpLayout() {
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        setUpPicker()
//        setUpRemittanceViews()
    }


}

// - MARK: Private methods

private extension PaymentsDetailsViewController {
    func setUpPicker() {
        picker.layer.cornerRadius = 3
        pickerImageView.image = pickerImageView.image?.withRenderingMode(.alwaysTemplate)
        pickerImageView.tintColor = .white
    }

    func addGradientView() {
        let containerGradientView = GradientView()
        containerGradientView.frame = containterView.frame
        containerGradientView.color1 = UIColor(red: 243 / 255, green: 58 / 255, blue: 52 / 255, alpha: 1)
        containerGradientView.color2 = UIColor(red: 243 / 255, green: 58 / 255, blue: 52 / 255, alpha: 1)
        containterView.insertSubview(containerGradientView, at: 0)
    }
}

extension PaymentsDetailsViewController: OptionPickerDelegate {
    func setSelectedOption(option: String?) {
        // Set current option to selected one if not just dismissed
        if let option = option {
            pickerLabel.text = option
        }
        pickerButton.isEnabled = true
    }
}

extension PaymentsDetailsViewController: RemittancePickerDelegate {
    func didSelectOptionView(optionView: RemittanceOptionView?, paymentOption: PaymentOption?) {
//        self.selectedDestinationPaymentOption = paymentOption
        if selectedViewType {
            let frame = remittanceDestinationView.frame
            remittanceDestinationView.removeFromSuperview()
            remittanceDestinationView = optionView
            remittanceDestinationView.frame = frame
            remittanceDestinationView.translatesAutoresizingMaskIntoConstraints = true

        } else {
            let frame = remittanceSourceView.frame
            remittanceSourceView.removeFromSuperview()
            remittanceSourceView = optionView
            remittanceSourceView.frame = frame
            remittanceSourceView.translatesAutoresizingMaskIntoConstraints = true
        }
    }
}

extension PaymentsDetailsViewController: PaymentDetailsPresenterDelegate {
    func didUpdate(isLoading: Bool, canAskFee: Bool, canMakePayment: Bool) {

    }
}


extension PaymentsDetailsViewController: ConfigurableCellDelegate {
    func didInputPaymentValue(value: Any) {
        print(value)
//        delegate?.didChangeDestination(paymentOption: <#T##PaymentOptionType#>)
//        if let stringItem = item as? String {
//            return stringItem
//        } else if let paymentOption = item as? PaymentOption {
//            return paymentOption.number
//        }
//        return ""
    }
}
