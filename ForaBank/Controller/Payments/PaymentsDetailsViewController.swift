/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import ReSwift

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
    private var sourceConfigurations: [ICellConfigurator]?
    private var destinationConfigurations: [ICellConfigurator]?

//    var selectedDestinationPaymentOption: PaymentOption?
//    var defaultDestinationPaymentOption: PaymentOption?
//    var selectedSourcePaymentOption: PaymentOption?
//    var defaultSourcePaymentOption: PaymentOption?
//
//    var sourcePaymentOptions: [PaymentOption]? {
//        didSet {
//            guard defaultSourcePaymentOption != nil else {
//                selectedSourcePaymentOption = sourcePaymentOptions?.first
//                return
//            }
//
//            self.destinationPaymentOptions?.removeAll(where: { (option) -> Bool in
//                option.id == defaultSourcePaymentOption?.id
//            })
//        }
//    }
//
//    var destinationPaymentOptions: [PaymentOption]? {
//        didSet {
//            guard defaultDestinationPaymentOption != nil else {
//                selectedDestinationPaymentOption = destinationPaymentOptions?.first
//                return
//            }
//
//            self.sourcePaymentOptions?.removeAll(where: { (option) -> Bool in
//                option.id == defaultDestinationPaymentOption?.id
//            })
//        }
//    }
//
//    var destinationNum: String?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayout()
//        activityIndicator.startAnimating()
//        allPaymentOptions { (success, paymentOptions) in
//            self.destinationPaymentOptions = paymentOptions
//            self.sourcePaymentOptions = paymentOptions
//            DispatchQueue.main.async {
//                //self.optionsTable.reloadData()
//                self.activityIndicator.stopAnimating()
//            }
//        }

        sourceConfigurations = [
            PaymentOptionsPagerItem(provider: sourceProvider)
        ]
        destinationConfigurations = [
            PaymentOptionsPagerItem(provider: destinationProvider)
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
    }

    private func setUpLayout() {
        //optionsTable.register(UINib(nibName: String(describing: DropDownTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: DropDownTableViewCell.self))

        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        setUpPicker()
//        setUpRemittanceViews()
    }

    func makeC2C() {
        activityIndicator.startAnimating()

        guard let sourceOption = sourceProvider.currentValue as? PaymentOption, let distinationOption = destinationProvider.currentValue as? PaymentOption else {
            return
        }
        prepareCard2Card(from: sourceOption.number, to: distinationOption.number, amount: Double(sumTextField.text!) ?? 0) { [weak self] (success, token) in
            store.dispatch(payment(sourceOption: sourceOption, destionationOption: distinationOption, sum: self?.sumTextField.text))
            self?.activityIndicator.stopAnimating()
            if success {
                self?.performSegue(withIdentifier: "fromPaymentToPaymentVerification", sender: self)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromPaymentToPaymentVerification", let vc = segue.destination as? RegistrationCodeVerificationViewController {
            vc.operationSum = sumTextField.text
//            vc.sourceOption = selectedSourcePaymentOption
//            vc.destinationOption = selectedDestinationPaymentOption
//            vc.destinationNum = destinationNum
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

extension PaymentsDetailsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var pickerItem: IPickerItem?

//        switch indexPath.item {
//        case 0:
//            pickerItem = selectedSourcePaymentOption
//            break
//        case 1:
//            pickerItem = selectedDestinationPaymentOption
//            break
//        default:
//            break
//        }

        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DropDownTableViewCell.self), for: indexPath) as? DropDownTableViewCell

        if let nonNilPickerItem = pickerItem {
            cell?.setupLayout(withPickerItem: nonNilPickerItem, isDroppable: true)
        }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PickerViewController(nibName: String(describing: PickerViewController.self), bundle: nil)
        vc.modalPresentationStyle = .overCurrentContext

//        switch indexPath.item {
//        case 0:
//            guard let nonNilOptions = sourcePaymentOptions else {
//                return
//            }
//            vc.pickerItems = nonNilOptions
//            break
//        case 1:
//            guard let nonNilOptions = destinationPaymentOptions else {
//                return
//            }
//            vc.pickerItems = nonNilOptions
//            break
//        default:
//            break
//        }

//        vc.callBack = { (number) in
//            self.makeC2C(toNumber: number)
//        }
        //topMostVC()?.present(vc, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
