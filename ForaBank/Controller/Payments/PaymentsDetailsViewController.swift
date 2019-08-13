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
    
    var remittanceSourceView: RemittanceOptionView!
    var remittanceDestinationView: RemittanceOptionView!
    var selectedViewType: Bool = false //false - source; true - destination
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
            
            vc.pickerOptions = ["За завтраки", "За тренировку","За обеды"]
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    @IBAction func pickerSourceButtonClicked(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Payment", bundle: nil)
            .instantiateViewController(withIdentifier: "opvc") as? RemittancePickerViewController {
            sender.isEnabled = false
            // Pass picker frame to determine picker popup coordinates
            var r = sourceButton.convert(sourceButton.frame, to: view)
            r.origin.x += 15
            r.size.width -= 15
            vc.pickerFrame = r
            
            vc.pickerOptions = [.card, .safeDeposit]
            vc.delegate = self
            selectedViewType = false
            present(vc, animated: true, completion: nil)
        }
    }
    @IBAction func pickerDestinationButtonClicked(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Payment", bundle: nil)
            .instantiateViewController(withIdentifier: "opvc") as? RemittancePickerViewController {
            sender.isEnabled = false
            // Pass picker frame to determine picker popup coordinates
            var r = destinationButton.convert(destinationButton.bounds, to: view)
            r.origin.x += 15
            r.size.width -= 15
            vc.pickerFrame = r
            
            vc.pickerOptions = [.safeDeposit, .card, .friend]
            vc.delegate = self
            selectedViewType = true
            present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPicker()
        setUpRemittanceViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addGradientView() // TODO: Replace with GradientView view
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
        containerGradientView.color1 = UIColor(red: 242/255, green: 173/255, blue: 114/255, alpha: 1)
        containerGradientView.color2 = UIColor(red: 236/255, green: 69/255, blue: 68/255, alpha: 1)
        containterView.insertSubview(containerGradientView, at: 0)
    }
    
    func setUpRemittanceViews() {
        remittanceSourceView = RemittanceOptionView(withType: .card)
        remittanceSourceView.isUserInteractionEnabled = false
        //        transactionSourceView.friendName = "Иван Петров"
        //        transactionSourceView.friendImage = UIImage(named: "image_friend_4")
        
        //        transactionSourceView.title = "Сейф"
        //        transactionSourceView.subtitle = "3447"
        //        transactionSourceView.cash = "23 534 ₽"
        
        remittanceSourceView.title = "Моя сберочка"
        remittanceSourceView.subtitle = "1110"
        remittanceSourceView.cash = "55 560 ₽"
        remittanceSourceView.titleImage = UIImage(named: "payments_template_sberbank")
        remittanceSourceView.subtitleImage = UIImage(named: "visalogo")
        remittanceSourceView.translatesAutoresizingMaskIntoConstraints = false
        sourceButton.addSubview(remittanceSourceView)
        
        let arrowsImageView = UIImageView(image: UIImage(named: "vertical_arrows"))
        arrowsImageView.translatesAutoresizingMaskIntoConstraints = false
        sourceButton.addSubview(arrowsImageView)
        sourceButton.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[i(5)]-5-[v]-0-|", options: [], metrics: nil, views: ["i":arrowsImageView, "v":remittanceSourceView]))
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
        sourceButton.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v]|", options: [], metrics: nil, views: ["v":remittanceSourceView]))
        
        remittanceDestinationView = RemittanceOptionView(withType: .safeDeposit)
        remittanceDestinationView.isUserInteractionEnabled = false
        remittanceDestinationView.title = "Сейф"
        remittanceDestinationView.subtitle = "3447"
        remittanceDestinationView.cash = "23 534 ₽"

        remittanceDestinationView.titleImage = UIImage(named: "payments_template_sberbank")
        remittanceDestinationView.subtitleImage = UIImage(named: "visalogo")
        remittanceDestinationView.translatesAutoresizingMaskIntoConstraints = false
        destinationButton.addSubview(remittanceDestinationView)
        
        let arrowsImageView2 = UIImageView(image: UIImage(named: "vertical_arrows"))
        arrowsImageView2.translatesAutoresizingMaskIntoConstraints = false
        destinationButton.addSubview(arrowsImageView2)
        destinationButton.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[i(5)]-5-[v]-0-|", options: [], metrics: nil, views: ["i":arrowsImageView2, "v":remittanceDestinationView]))
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
        destinationButton.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v]|", options: [], metrics: nil, views: ["v":remittanceDestinationView]))
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
    func setUpOption(withView view: RemittanceOptionView, atIndex index: Int) {
        switch view.type {
        case .friend:
            view.friendName = "Иван Петров"
            view.friendImage = UIImage(named: "image_friend_4")
        case .safeDeposit:
            view.title = "Сейф"
            view.subtitle = "3447"
            view.cash = "23 534 ₽"
        case .card:
            view.title = "Моя сберочка"
            view.subtitle = "1110"
            view.cash = "55 560 ₽"
            view.titleImage = UIImage(named: "payments_template_sberbank")
            view.subtitleImage = UIImage(named: "visalogo")
        default:
            break
        }
    }
    
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
