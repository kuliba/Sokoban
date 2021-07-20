//
//  ContactInputViewController + UI.swift
//  ForaBank
//
//  Created by Mikhail on 17.06.2021.
//

import UIKit
import SVGKit

extension ContactInputViewController {
    func setupUI() {
        view.backgroundColor = .white
        let saveAreaView = UIView()
        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        view.addSubview(saveAreaView)
        saveAreaView.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor,
                            bottom: view.bottomAnchor, right: view.rightAnchor)
        view.addSubview(bottomView)
        bottomView.currency = "₽"
        cardFromField.titleLabel.text = "Счет списания"
        cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardFromField.imageView.isHidden = false
        cardFromField.leftTitleAncor.constant = 64
        cardFromField.layoutIfNeeded()
        
        
//        view.addSubview(foraSwitchView)
        
        
//        foraSwitchView.heightAnchor.constraint(equalToConstant: heightSwitchView).isActive = true
        
        //TODO: добавить скроллвью что бы избежать проблем на маленьких экранах
        // let scroll
        //  let view1 = UIView()
        //  view1.addSubview(stackView)
        // scroll add view1
        
        stackView = UIStackView(arrangedSubviews: [foraSwitchView, surnameField, nameField, secondNameField, phoneField, bankField, bankListView, cardFromField, cardListView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
        
        self.view.addSubview(countryListView)
        countryListView.anchor(top: view.topAnchor, left: view.leftAnchor,
                               right: view.rightAnchor, height: 100)
        
        setupConstraint()
    }
    
    func configure(with: CountriesList?, byPhone: Bool) {
        guard let country = country else { return }
        
        var filterPaymentList: [PaymentSystemList] = []
        guard let paymentList = Dict.shared.paymentList else { return }
        paymentList.forEach({ payment in
            country.paymentSystemCodeList?.forEach({ countryPayment in
                if countryPayment == payment.code {
                    filterPaymentList.append(payment)
                }
            })
        })
        if filterPaymentList.count > 1 {
            filterPaymentList.forEach { paymentSystem in
                if paymentSystem.code == "DIRECT" && byPhone {
                    self.paymentSystem = paymentSystem
                } else if paymentSystem.code == "CONTACT" && !byPhone {
                    self.paymentSystem = paymentSystem
                    let puref = paymentSystem.purefList?.first
                    puref?.forEach({ (key, value) in
                        if key == "CONTACT" {
                            value.forEach { purefList in
                                if purefList.type == "addressless" {
                                    self.puref = purefList.puref ?? ""
                                }
                            }
                        }
                    })
                }
            }
        } else if filterPaymentList.count == 1 {
            self.paymentSystem = filterPaymentList.first
            let puref = paymentSystem?.purefList?.first
            puref?.forEach({ (key, value) in
                if key == "CONTACT" {
                    value.forEach { purefList in
                        if purefList.type == "addressless" {
                            self.puref = purefList.puref ?? ""
                        }
                    }
                }
            })
        }
        
        
        UIView.animate(withDuration: 0.1) {
            self.needShowSwitchView = country.code == "AM" ? true : false
            self.phoneField.isHidden = byPhone ? false : true
            self.phoneField.textField.maskString = "+000-0000-00-00"
            self.bankField.isHidden = byPhone ? false : true
            self.surnameField.isHidden = byPhone ? true : false
            self.nameField.isHidden = byPhone ? true : false
            self.secondNameField.isHidden = byPhone ? true : false
            self.stackView.layoutIfNeeded()
        }
        
    }
    
    func setupPaymentsUI(system: PaymentSystemList) {
        guard let countryName = self.country?.name else { return }
        let subtitle = "Денежные переводы \(system.name ?? "")"
        self.navigationItem.titleView = self.setTitle(title: countryName.capitalizingFirstLetter(), subtitle: subtitle)
        
        let navImage: UIImage = system.svgImage?.convertSVGStringToImage() ?? UIImage()
        
        let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
        self.navigationItem.rightBarButtonItem = customViewItem
        
    }
    
    
    func setupConstraint() {
        bottomView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.rightAnchor)
        
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor, right: view.rightAnchor,
                         paddingTop: 20)
        
    }
    
    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))

        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "chevron.down")
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)

        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        let text = NSAttributedString(string: title + " ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)])
        completeText.append(text)
        completeText.append(attachmentString)
        
        titleLabel.attributedText = completeText
        titleLabel.sizeToFit()

        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = .gray
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width

        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.titleDidTaped))
        titleView.addGestureRecognizer(gesture)
        return titleView
    }
}
