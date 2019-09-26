/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import ReSwift

class PaymentsDetailsViewController: UIViewController, StoreSubscriber {

    // MARK: - Properties

    @IBOutlet weak var picker: UIView!
    @IBOutlet weak var pickerImageView: UIImageView!
    @IBOutlet weak var sumTextField: UITextField!
    @IBOutlet weak var containterView: RoundedEdgeView!
    @IBOutlet weak var pickerLabel: UILabel!
    @IBOutlet weak var sourceButton: UIButton!
    @IBOutlet weak var destinationButton: UIButton!
    @IBOutlet weak var pickerButton: UIButton!

    // MARK: - Actions

    @IBAction func sendButtonClicked(_ sender: Any) {
        activityIndicator.startAnimating()
//        prepareCard2Card(from: sourcePaymentOption?.number ?? "", to: selectedDestinationPaymentOption?.number ?? "", amount: Double(sumTextField.text!) as? Double ?? 0) { (success, token) in
//            self.activityIndicator.stopAnimating()
//            self.performSegue(withIdentifier: "fromPaymentToPaymentVerification", sender: self)
//        }

//        prepareCard2Card(from: sourcePaymentOption?.number ?? "", to: "4256901080001025", amount: Double(sumTextField.text!) as? Double ?? 0) { (success, token) in
//        }
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

    @IBAction func pickerDestinationButtonClicked(_ sender: UIButton) {
        showPickerViewOverView(view: sender)
    }

    var remittanceSourceView: RemittanceOptionView!
    var remittanceDestinationView: RemittanceOptionView!
    var selectedViewType: Bool = false //false - source; true - destination
    var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)

    var destinationPaymentOptions: [PaymentOption]? {
        didSet {
            guard selectedDestinationPaymentOption == nil else {
                self.sourcePaymentOptions?.removeAll(where: { (option) -> Bool in
                    option.id == selectedDestinationPaymentOption?.id
                })
                pickedDestinationPaymentOption = selectedDestinationPaymentOption
                destinationButton.isUserInteractionEnabled = false
                return
            }
            pickedDestinationPaymentOption = destinationPaymentOptions?.first
        }
    }
    var selectedDestinationPaymentOption: PaymentOption?
    var pickedDestinationPaymentOption: PaymentOption?

    var sourcePaymentOptions: [PaymentOption]? {
        didSet {
            guard selectedSourcePaymentOption == nil else {
                self.destinationPaymentOptions?.removeAll(where: { (option) -> Bool in
                    option.id == selectedSourcePaymentOption?.id
                })
                pickedSourcePaymentOption = selectedSourcePaymentOption
                sourceButton.isUserInteractionEnabled = false
                return
            }
            pickedSourcePaymentOption = sourcePaymentOptions?.first
        }
    }
    var selectedSourcePaymentOption: PaymentOption?
    var pickedSourcePaymentOption: PaymentOption?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayout()
        activityIndicator.startAnimating()
        allPaymentOptions { (success, paymentOptions) in
            self.destinationPaymentOptions = paymentOptions
            self.sourcePaymentOptions = paymentOptions
            DispatchQueue.main.async {
                //self.setUpRemittanceViews()
                self.activityIndicator.stopAnimating()
            }
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
        selectedSourcePaymentOption = state.sourceOption
        selectedDestinationPaymentOption = state.destinationOption
//        setUpRemittanceViews()
    }

    private func setUpLayout() {
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        setUpPicker()
//        setUpRemittanceViews()
    }

    private func showPickerViewOverView(view: UIView) {
        guard let pickerVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "opvc") as? RemittancePickerViewController, let nonNilPaymentOptions = destinationPaymentOptions else {
            return
        }

        var frame = view.convert(view.bounds, to: self.view)
        frame.origin.x += 15
        frame.size.width -= 15
        pickerVC.pickerFrame = frame
        pickerVC.pickerOptions = nonNilPaymentOptions
        pickerVC.delegate = self
        self.selectedViewType = true
        self.present(pickerVC, animated: true, completion: nil)
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
        containerGradientView.color1 = UIColor(red: 242 / 255, green: 173 / 255, blue: 114 / 255, alpha: 1)
        containerGradientView.color2 = UIColor(red: 236 / 255, green: 69 / 255, blue: 68 / 255, alpha: 1)
        containterView.insertSubview(containerGradientView, at: 0)
    }

//    func setUpRemittanceViews() {
//        guard let sourceOption = pickedSourcePaymentOption else {
//            return
//        }
//        remittanceSourceView = RemittanceOptionView(withOption: sourceOption)
//        remittanceSourceView.isUserInteractionEnabled = false
//
//        sourceButton.addSubview(remittanceSourceView)
//
//        let arrowsImageView = UIImageView(image: UIImage(named: "vertical_arrows"))
//        arrowsImageView.translatesAutoresizingMaskIntoConstraints = false
//        sourceButton.addSubview(arrowsImageView)
//        sourceButton.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[i(5)]-5-[v]-0-|", options: [], metrics: nil, views: ["i": arrowsImageView, "v": remittanceSourceView]))
//        sourceButton.addConstraint(NSLayoutConstraint(item: arrowsImageView,
//                                                      attribute: .height,
//                                                      relatedBy: .equal,
//                                                      toItem: nil,
//                                                      attribute: .notAnAttribute,
//                                                      multiplier: 1,
//                                                      constant: 10))
//        sourceButton.addConstraint(NSLayoutConstraint(item: arrowsImageView,
//                                                      attribute: .centerY,
//                                                      relatedBy: .equal,
//                                                      toItem: sourceButton,
//                                                      attribute: .centerY,
//                                                      multiplier: 1,
//                                                      constant: 0))
//        sourceButton.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v]|", options: [], metrics: nil, views: ["v": remittanceSourceView]))
//        sourceButton.backgroundColor = UIColor(named: "blue")
//
//        guard let destinationOption = pickedDestinationPaymentOption else {
//            return
//        }
//        remittanceDestinationView = RemittanceOptionView(withOption: destinationOption)
//        remittanceDestinationView.isUserInteractionEnabled = false
//
//        remittanceDestinationView.titleImage = UIImage(named: "payments_template_sberbank")
//        remittanceDestinationView.subtitleImage = UIImage(named: "visalogo")
//        remittanceDestinationView.translatesAutoresizingMaskIntoConstraints = false
//        destinationButton.addSubview(remittanceDestinationView)
//
//        let arrowsImageView2 = UIImageView(image: UIImage(named: "vertical_arrows"))
//        arrowsImageView2.translatesAutoresizingMaskIntoConstraints = false
//        destinationButton.addSubview(arrowsImageView2)
//        destinationButton.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[i(5)]-5-[v]-0-|", options: [], metrics: nil, views: ["i": arrowsImageView2, "v": remittanceDestinationView]))
//        destinationButton.addConstraint(NSLayoutConstraint(item: arrowsImageView2,
//                                                           attribute: .height,
//                                                           relatedBy: .equal,
//                                                           toItem: nil,
//                                                           attribute: .notAnAttribute,
//                                                           multiplier: 1,
//                                                           constant: 10))
//        destinationButton.addConstraint(NSLayoutConstraint(item: arrowsImageView2,
//                                                           attribute: .centerY,
//                                                           relatedBy: .equal,
//                                                           toItem: destinationButton,
//                                                           attribute: .centerY,
//                                                           multiplier: 1,
//                                                           constant: 0))
//        destinationButton.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v]|", options: [], metrics: nil, views: ["v": remittanceDestinationView]))
//    }
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
        self.selectedDestinationPaymentOption = paymentOption
        if selectedViewType {
            let frame = remittanceDestinationView.frame
            remittanceDestinationView.removeFromSuperview()
            remittanceDestinationView = optionView
            remittanceDestinationView.frame = frame
            remittanceDestinationView.translatesAutoresizingMaskIntoConstraints = true
            destinationButton.addSubview(remittanceDestinationView)
            destinationButton.isEnabled = true
        } else {
            let frame = remittanceSourceView.frame
            remittanceSourceView.removeFromSuperview()
            remittanceSourceView = optionView
            remittanceSourceView.frame = frame
            remittanceSourceView.translatesAutoresizingMaskIntoConstraints = true
            sourceButton.addSubview(remittanceSourceView)
            sourceButton.isEnabled = true
        }
    }
}
