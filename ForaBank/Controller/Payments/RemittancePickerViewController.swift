/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit

protocol RemittancePickerDelegate: class {
    func didSelectOptionView(option: RemittanceOptionView?)
}

class RemittancePickerViewController: UIViewController {

    // MARK: - Properties
    var pickerFrame: CGRect!
    var pickerOptions: [PaymentOption]?
    var optionViews: [RemittanceOptionView]!

    weak var delegate: RemittancePickerDelegate!

    private lazy var pickerPopupView: UIView = {
        let popupView = UIView()

        guard let nonNilpickerOptions = pickerOptions else {
            return popupView
        }

        // frame
        popupView.frame = pickerFrame
        popupView.frame.size.height = (pickerFrame.height + 11) * CGFloat(nonNilpickerOptions.count) - 1
        popupView.frame.origin.x = pickerFrame.minX //- 6
        popupView.frame.origin.y = pickerFrame.minY - 5 //- 6
        popupView.frame.size.width = pickerFrame.width //+ 6

        // appearance
        popupView.backgroundColor = UIColor(red: 228 / 255, green: 228 / 255, blue: 228 / 255, alpha: 1)

        // shadow
        popupView.layer.shadowColor = UIColor.black.cgColor
        popupView.layer.shadowOpacity = 0.5
        popupView.layer.shadowOffset = CGSize(width: 0, height: 10)
        popupView.layer.shadowRadius = 10
        popupView.layer.shadowPath = UIBezierPath(rect: popupView.bounds).cgPath


        return popupView
    }()

    private lazy var dismissLayerButton: UIButton = {
        let b = UIButton()
        b.frame = view.frame
        b.tag = -1
        b.addTarget(self, action: #selector(dismissLayerClicked), for: .touchUpInside)
        return b
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(dismissLayerButton)
        view.addSubview(pickerPopupView)
        optionViews = [RemittanceOptionView]()
        addPickerOptions()
    }
}

private extension RemittancePickerViewController {
    func addPickerOptions() {

        guard let nonNilPickerOptions = pickerOptions else {
            return
        }
        for (i, option) in nonNilPickerOptions.enumerated() {
            let b = UIButton(type: .custom)
            b.backgroundColor = .white
            b.frame = pickerFrame
            b.frame.origin.x = 0//6
            b.frame.size.height = pickerFrame.height + 10
            b.frame.origin.y = (pickerFrame.height + 11) * CGFloat(i)

//            b.setTitleColor(.black, for: [])
//            b.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 16)
//            b.contentHorizontalAlignment = .left
////            b.setTitle(o, for: [])
            b.tag = i

            b.addTarget(self, action: #selector(dismissLayerClicked), for: .touchUpInside)

            let v = RemittanceOptionView(withOption: option)
            setUpOption(withView: v, atIndex: i)
            v.translatesAutoresizingMaskIntoConstraints = false
            v.tag = i
            v.isUserInteractionEnabled = false
            optionViews.append(v)
            b.addSubview(v)
            b.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[v]-5-|", options: [], metrics: nil, views: ["v": v]))
            b.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v]|", options: [], metrics: nil, views: ["v": v]))

            pickerPopupView.addSubview(b)
        }
    }

    private func setUpOption(withView view: RemittanceOptionView, atIndex index: Int) {
        guard let option = pickerOptions?[index] else {
            return
        }
        switch option.type {
        case .friend:
            view.friendName = "Иван Петров"
            view.friendImage = UIImage(named: "image_friend_4")
            break
        case .safeDeposit:
            view.title = option.name
            view.subtitle = option.number
            view.cash = "\(maskSum(sum: option.sum)) ₽"
            break
        case .card:
            view.title = option.name
            view.subtitle = option.number
            view.cash = "\(maskSum(sum: option.sum)) ₽"
            view.titleImage = UIImage(named: "payments_template_sberbank")
            view.subtitleImage = UIImage(named: "visalogo")
            break
        default:
            break
        }
    }

    @objc func dismissLayerClicked(sender: UIButton) {
        // If tag == -1 then it's dismissed withoud any option selected
        if sender.tag != -1 {
            delegate?.didSelectOptionView(option: optionViews[sender.tag])
        }
        dismiss(animated: true, completion: nil)
    }

}
