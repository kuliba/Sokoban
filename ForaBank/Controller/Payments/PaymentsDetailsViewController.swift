/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit

class PaymentsDetailsViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var picker: UIView!
    @IBOutlet weak var pickerImageView: UIImageView!
    @IBOutlet weak var comissionTextField: UITextField!
    @IBOutlet weak var containterView: RoundedEdgeView!
    @IBOutlet weak var pickerLabel: UILabel!
    @IBOutlet weak var sourceButton: UIButton!
    @IBOutlet weak var destinationButton: UIButton!
    @IBOutlet weak var pickerButton: UIButton!

    // MARK: - Actions
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
        if let vc = UIStoryboard(name: "Payment", bundle: nil)
            .instantiateViewController(withIdentifier: "opvc") as? RemittancePickerViewController, let nonNilPaymentOptions = destinationPaymentOptions {
            sender.isEnabled = false
            // Pass picker frame to determine picker popup coordinates
            var r = self.destinationButton.convert(self.destinationButton.bounds, to: self.view)
            r.origin.x += 15
            r.size.width -= 15
            vc.pickerFrame = r
            vc.pickerOptions = nonNilPaymentOptions
            vc.delegate = self
            self.selectedViewType = true
            self.present(vc, animated: true, completion: nil)
        }

    }

    var remittanceSourceView: RemittanceOptionView!
    var remittanceDestinationView: RemittanceOptionView!
    var selectedViewType: Bool = false //false - source; true - destination
    var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    var destinationPaymentOptions: [PaymentOption]? {
        didSet{
            self.destinationPaymentOptions?.removeAll(where: { (option) -> Bool in
                option.id == sourcePaymentOption?.id
            })
        }
    }
    var sourcePaymentOption: PaymentOption?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayout()

        activityIndicator.startAnimating()
        allPaymentOptions { (success, paymentOptions) in
            self.destinationPaymentOptions = paymentOptions
            DispatchQueue.main.async {
                self.setUpRemittanceViews()
                self.activityIndicator.stopAnimating()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addGradientView() // TODO: Replace with GradientView view
    }

    private func setUpLayout() {
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        setUpPicker()
        setUpRemittanceViews()
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

    func setUpRemittanceViews() {
        guard let sourceOption = sourcePaymentOption, let destinationOption = destinationPaymentOptions?.first else {
            return
        }
        remittanceSourceView = RemittanceOptionView(withOption: sourceOption)
        remittanceSourceView.isUserInteractionEnabled = false

        sourceButton.addSubview(remittanceSourceView)

        let arrowsImageView = UIImageView(image: UIImage(named: "vertical_arrows"))
        arrowsImageView.translatesAutoresizingMaskIntoConstraints = false
        sourceButton.addSubview(arrowsImageView)
        sourceButton.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[i(5)]-5-[v]-0-|", options: [], metrics: nil, views: ["i": arrowsImageView, "v": remittanceSourceView]))
        sourceButton.addConstraint(NSLayoutConstraint(item: arrowsImageView,
                                                      attribute: .height,
                                                      relatedBy: .equal,
                                                      toItem: nil,
                                                      attribute: .notAnAttribute,
                                                      multiplier: 1,
                                                      constant: 10))
        sourceButton.addConstraint(NSLayoutConstraint(item: arrowsImageView,
                                                      attribute: .centerY,
                                                      relatedBy: .equal,
                                                      toItem: sourceButton,
                                                      attribute: .centerY,
                                                      multiplier: 1,
                                                      constant: 0))
        sourceButton.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v]|", options: [], metrics: nil, views: ["v": remittanceSourceView]))

        remittanceDestinationView = RemittanceOptionView(withOption: destinationOption)
        remittanceDestinationView.isUserInteractionEnabled = false

        remittanceDestinationView.titleImage = UIImage(named: "payments_template_sberbank")
        remittanceDestinationView.subtitleImage = UIImage(named: "visalogo")
        remittanceDestinationView.translatesAutoresizingMaskIntoConstraints = false
        destinationButton.addSubview(remittanceDestinationView)

        let arrowsImageView2 = UIImageView(image: UIImage(named: "vertical_arrows"))
        arrowsImageView2.translatesAutoresizingMaskIntoConstraints = false
        destinationButton.addSubview(arrowsImageView2)
        destinationButton.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[i(5)]-5-[v]-0-|", options: [], metrics: nil, views: ["i": arrowsImageView2, "v": remittanceDestinationView]))
        destinationButton.addConstraint(NSLayoutConstraint(item: arrowsImageView2,
                                                           attribute: .height,
                                                           relatedBy: .equal,
                                                           toItem: nil,
                                                           attribute: .notAnAttribute,
                                                           multiplier: 1,
                                                           constant: 10))
        destinationButton.addConstraint(NSLayoutConstraint(item: arrowsImageView2,
                                                           attribute: .centerY,
                                                           relatedBy: .equal,
                                                           toItem: destinationButton,
                                                           attribute: .centerY,
                                                           multiplier: 1,
                                                           constant: 0))
        destinationButton.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v]|", options: [], metrics: nil, views: ["v": remittanceDestinationView]))
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
    func didSelectOptionView(option: RemittanceOptionView?) {
        if selectedViewType {
            let frame = remittanceDestinationView.frame
            remittanceDestinationView.removeFromSuperview()
            remittanceDestinationView = option
            remittanceDestinationView.frame = frame
            remittanceDestinationView.translatesAutoresizingMaskIntoConstraints = true
            destinationButton.addSubview(remittanceDestinationView)
            destinationButton.isEnabled = true
        } else {
            let frame = remittanceSourceView.frame
            remittanceSourceView.removeFromSuperview()
            remittanceSourceView = option
            remittanceSourceView.frame = frame
            remittanceSourceView.translatesAutoresizingMaskIntoConstraints = true
            sourceButton.addSubview(remittanceSourceView)
            sourceButton.isEnabled = true
        }
    }
}
