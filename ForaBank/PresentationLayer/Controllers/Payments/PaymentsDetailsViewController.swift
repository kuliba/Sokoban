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

    func didChangeAmount(amount: Double?)

    func didPressPrepareButton()
    func didPressPaymentButton()
}

class PaymentsDetailsViewController: UIViewController, StoreSubscriber {

    // MARK: - Properties
    @IBOutlet weak var sourcePagerView: PagerView!
    @IBOutlet weak var destinationPagerView: PagerView!

    @IBOutlet weak var picker: UIView!
    @IBOutlet weak var pickerImageView: UIImageView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var containterView: RoundedEdgeView!
    @IBOutlet weak var pickerLabel: UILabel!
    @IBOutlet weak var pickerButton: UIButton!
    @IBOutlet weak var sendButton: ButtonRounded!

    // MARK: - Actions
    @IBAction func amountTextFieldValueChanged(_ sender: Any) {
        delegate?.didChangeAmount(amount: Double(amountTextField.text!.replacingOccurrences(of: ",", with: ".")))
    }

    @IBAction func sendButtonClicked(_ sender: Any) {
        delegate?.didPressPrepareButton()
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
    var sourceConfig: Any?
    var sourceValue: Any?
    var destinationConfig: Any?
    var destinationValue: Any?

    var remittanceSourceView: RemittanceOptionView!
    var remittanceDestinationView: RemittanceOptionView!
    var selectedViewType: Bool = false //false - source; true - destination
    var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)

// MARK: - Lifecycle

//    private let sourceProvider = PaymentOptionCellProvider()
//     private let destinationProvider = PaymentOptionCellProvider()
//    var sourceConfigurations: [ICellConfigurator]?
//    var destinationConfigurations: [ICellConfigurator]?

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromPaymentToPaymentVerification", let destinationVC = segue.destination as? RegistrationCodeVerificationViewController {
            destinationVC.sourceConfig = destinationConfig
            destinationVC.sourceValue = sourceValue
            destinationVC.destinationConfig = destinationConfig
            destinationVC.destinationValue = destinationValue
            destinationVC.operationSum = amountTextField.text
        }
    }
}

// - MARK: Private methods

private extension PaymentsDetailsViewController {
    private func setUpPicker() {
        picker.layer.cornerRadius = 3
        pickerImageView.image = pickerImageView.image?.withRenderingMode(.alwaysTemplate)
        pickerImageView.tintColor = .white
    }

    private func addGradientView() {
        let containerGradientView = GradientView()
        containerGradientView.frame = containterView.frame
        containerGradientView.color1 = UIColor(red: 243 / 255, green: 58 / 255, blue: 52 / 255, alpha: 1)
        containerGradientView.color2 = UIColor(red: 243 / 255, green: 58 / 255, blue: 52 / 255, alpha: 1)
        containterView.insertSubview(containerGradientView, at: 0)
    }

    private func setUpLayout() {
        sendButton.changeEnabled(isEnabled: false)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        setUpPicker()
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
    func didFinishPreparation(success: Bool) {
        if success {
            performSegue(withIdentifier: "fromPaymentToPaymentVerification", sender: self)
        } else {
            AlertService.shared.show(title: "Ошибка", message: "При выполнении платежа произошла ошибка, попробуйте ещё раз позже", cancelButtonTitle: "Продолжить", okButtonTitle: nil, cancelCompletion: nil, okCompletion: nil)
        }
    }

    func didUpdate(isLoading: Bool, canAskFee: Bool, canMakePayment: Bool) {
        print(isLoading, canAskFee, canMakePayment)
        sendButton.changeEnabled(isEnabled: canAskFee)
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}

extension PaymentsDetailsViewController: ICellConfiguratorDelegate {
    func didReciveNewValue(value: Any, from configurator: ICellConfigurator) {
        if let sourceConfig = sourceConfigurations?.filter({ $0 == configurator }).first {
            switch (sourceConfig, value) {
            case (is PaymentOptionsPagerItem, let destinationOption as PaymentOption):
                delegate?.didChangeSource(paymentOption: .option(destinationOption))
                break
            default:
                break
            }
            self.sourceConfig = sourceConfig
            self.sourceValue = value
        } else if let destinationConfig = destinationConfigurations?.filter({ $0 == configurator }).first {
            switch (destinationConfig, value) {
            case (is PaymentOptionsPagerItem, let destinationOption as PaymentOption):
                delegate?.didChangeDestination(paymentOption: .option(destinationOption))
                break
            case (is CardNumberPagerItem, let destinationOption as String):
                delegate?.didChangeDestination(paymentOption: .cardNumber(destinationOption))
                break
            case (is PhoneNumberPagerItem, let destinationOption as String):
                delegate?.didChangeDestination(paymentOption: .phoneNumber(destinationOption))
                break
            case (is AccountNumberPagerItem, let destinationOption as String):
                delegate?.didChangeDestination(paymentOption: .accountNumber(destinationOption))
                break
            default:
                break
            }
            self.destinationConfig = destinationConfig
            self.destinationValue = value
        }
    }
}
