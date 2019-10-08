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
        makeC2C()
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true)
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

    var remittanceSourceView: RemittanceOptionView!
    var remittanceDestinationView: RemittanceOptionView!
    var selectedViewType: Bool = false //false - source; true - destination
    var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)

    private let sourceProvider = PaymentOptionCellProvider()
    private let destinationProvider = PaymentOptionCellProvider()
    private let destinationProviderCardNumber = CardNumberCellProvider()
    private let destinationProviderAccountNumber = AccountNumberCellProvider()
    private var sourceConfigurations: [ICellConfigurator]?
    private var destinationConfigurations: [ICellConfigurator]?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayout()

        sourceConfigurations = [
            PaymentOptionsPagerItem(provider: sourceProvider)
        ]
        destinationConfigurations = [
            PaymentOptionsPagerItem(provider: destinationProvider),
            CardNumberPagerItem(provider: destinationProviderCardNumber),
            AccountNumberPagerItem(provider: destinationProviderAccountNumber)
        ]
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

    func makeC2C() {
        activityIndicator.startAnimating()


        guard let sourceNumber = sourceConfigurations?[sourcePagerView.currentIndex].stringFromSelection(), let destinationNumber = destinationConfigurations?[destinationPagerView.currentIndex].stringFromSelection(), let amount = Double(sumTextField.text!) else {
            return
        }
        prepareCard2Card(from: sourceNumber, to: destinationNumber, amount: amount) { [weak self] (success, token) in
            //store.dispatch(payment(sourceOption: sourceOption, destionationOption: distinationOption, sum: self?.sumTextField.text))
            self?.activityIndicator.stopAnimating()
            if success {
                self?.performSegue(withIdentifier: "fromPaymentToPaymentVerification", sender: self)
            }
        }
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
        containerGradientView.color1 = UIColor(red: 239 / 255, green: 65 / 255, blue: 54 / 255, alpha: 1)
        containerGradientView.color2 = UIColor(red: 239 / 255, green: 65 / 255, blue: 54 / 255, alpha: 1)
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
