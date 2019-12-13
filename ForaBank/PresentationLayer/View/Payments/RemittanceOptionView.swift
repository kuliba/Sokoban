//
//  CardActionRoundedButton.swift
//  ForaBank
//
//  Created by Sergey on 14/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

enum RemittanceOptionViewType {
    case safeDeposit
    case card
    case friend
    case custom
}

class RemittanceOptionView: UIView {

    public private(set) var paymentOption: PaymentOption?

    var friendName: String? {
        didSet {
            titleLabel.text = friendName
        }
    }
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    var subtitle: String? {
        didSet {
            subtitleLabel.text = subtitle
            subtitleWidthConstraint?.constant = subtitleLabel.attributedText?.size().width ?? 50
        }
    }
    var cash: String? {
        didSet {
            cashLabel.text = cash
        }
    }
    var friendImage: UIImage? {
        didSet {
            titleImageView.image = friendImage
        }
    }
    var titleImage: UIImage? {
        didSet {
            titleImageView.image = titleImage
        }
    }
    var subtitleImage: UIImage? {
        didSet {
            subtitleImageView.image = subtitleImage
        }
    }

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.textColor = .black
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.textColor = .black
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let cashLabel: UILabel = {
        let l = UILabel()
        l.textColor = .black
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let titleImageView: UIImageView = {
        let i = UIImageView()
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    private let subtitleImageView: UIImageView = {
        let i = UIImageView()
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()

    private var subtitleWidthConstraint: NSLayoutConstraint?

    init(withOption option: PaymentOption) {
        super.init(frame: CGRect.zero)
        self.paymentOption = option

        setUpLayout()
        switch paymentOption?.type {
        case .friend?:
            titleImageView.layer.masksToBounds = false
            titleImageView.layer.cornerRadius = 15
            titleImageView.clipsToBounds = true
            addSubview(titleImageView)
            addSubview(titleLabel)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[i(30)]-5-[t]-5-|", options: [], metrics: nil, views: ["i": titleImageView, "t": titleLabel]))
            addConstraint(NSLayoutConstraint(item: titleImageView,
                                             attribute: .height,
                                             relatedBy: .equal,
                                             toItem: nil,
                                             attribute: .notAnAttribute,
                                             multiplier: 1,
                                             constant: 30))
            addConstraint(NSLayoutConstraint(item: titleImageView,
                                             attribute: .centerY,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .centerY,
                                             multiplier: 1,
                                             constant: 0))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[t]-5-|", options: [], metrics: nil, views: ["t": titleLabel]))
            break
        case .safeDeposit?:
            subtitleLabel.textColor = .lightGray
            subtitleLabel.font = UIFont.systemFont(ofSize: 12)
            cashLabel.textAlignment = .right
            addSubview(subtitleLabel)
            addSubview(titleLabel)
            addSubview(cashLabel)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[t]", options: [], metrics: nil, views: ["t": titleLabel]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[st]", options: [], metrics: nil, views: ["st": subtitleLabel]))
            addConstraint(NSLayoutConstraint(item: titleLabel,
                                             attribute: .right,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .centerX,
                                             multiplier: 1,
                                             constant: 0))
            addConstraint(NSLayoutConstraint(item: subtitleLabel,
                                             attribute: .right,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .centerX,
                                             multiplier: 1,
                                             constant: 0))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[t]-0-[st]-0-|", options: [], metrics: nil, views: ["t": titleLabel, "st": subtitleLabel]))

            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[c]-5-|", options: [], metrics: nil, views: ["c": cashLabel]))
            addConstraint(NSLayoutConstraint(item: cashLabel,
                                             attribute: .left,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .centerX,
                                             multiplier: 1,
                                             constant: 0))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[c]-5-|", options: [], metrics: nil, views: ["c": cashLabel]))
            break
        case .card?:
            subtitleLabel.textColor = .lightGray
            subtitleLabel.font = UIFont.systemFont(ofSize: 12)
            cashLabel.textAlignment = .right
            addSubview(subtitleLabel)
            addSubview(titleLabel)
            addSubview(cashLabel)
            addSubview(titleImageView)
            addSubview(subtitleImageView)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[i(12)]-5-[t]", options: [], metrics: nil, views: ["t": titleLabel, "i": titleImageView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[st]-5-[i(35)]", options: [], metrics: nil, views: ["st": subtitleLabel, "i": subtitleImageView]))
            addConstraint(NSLayoutConstraint(item: titleLabel,
                                             attribute: .right,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .centerX,
                                             multiplier: 1,
                                             constant: 0))
            subtitleWidthConstraint = NSLayoutConstraint(item: subtitleLabel,
                                                         attribute: .width,
                                                         relatedBy: .equal,
                                                         toItem: nil,
                                                         attribute: .notAnAttribute,
                                                         multiplier: 1,
                                                         constant: 50)
            addConstraint(subtitleWidthConstraint!)
            addConstraint(NSLayoutConstraint(item: titleImageView,
                                             attribute: .height,
                                             relatedBy: .equal,
                                             toItem: nil,
                                             attribute: .notAnAttribute,
                                             multiplier: 1,
                                             constant: 12))
            addConstraint(NSLayoutConstraint(item: titleImageView,
                                             attribute: .centerY,
                                             relatedBy: .equal,
                                             toItem: titleLabel,
                                             attribute: .centerY,
                                             multiplier: 1,
                                             constant: 0))
            addConstraint(NSLayoutConstraint(item: subtitleImageView,
                                             attribute: .height,
                                             relatedBy: .equal,
                                             toItem: nil,
                                             attribute: .notAnAttribute,
                                             multiplier: 1,
                                             constant: 15))
            addConstraint(NSLayoutConstraint(item: subtitleImageView,
                                             attribute: .centerY,
                                             relatedBy: .equal,
                                             toItem: subtitleLabel,
                                             attribute: .centerY,
                                             multiplier: 1,
                                             constant: 0))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[t]-0-[st]-0-|", options: [], metrics: nil, views: ["t": titleLabel, "st": subtitleLabel]))

            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[c]-5-|", options: [], metrics: nil, views: ["c": cashLabel]))
            addConstraint(NSLayoutConstraint(item: cashLabel,
                                             attribute: .left,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .centerX,
                                             multiplier: 1,
                                             constant: 0))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[c]-5-|", options: [], metrics: nil, views: ["c": cashLabel]))
            break
        default:
            break
        }
    }

    override init(frame: CGRect) {
        self.paymentOption = PaymentOption(id: 0, name: "", type: .paymentOption, sum: 0, number: "", maskedNumber: "", provider: "", productType: .card)
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        self.paymentOption = PaymentOption(id: 0, name: "", type: .paymentOption, sum: 0, number: "", maskedNumber: "", provider: "", productType: .card)
        super.init(coder: aDecoder)
    }

    func setUpLayout() {
        guard let option = paymentOption else {
            return
        }
        title = option.name
        subtitle = option.number
        cash = "\(maskSum(sum: option.sum)) ₽"
        titleImage = UIImage(named: "payments_template_sberbank")
        subtitleImage = UIImage(named: "visalogo")
        translatesAutoresizingMaskIntoConstraints = false
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
