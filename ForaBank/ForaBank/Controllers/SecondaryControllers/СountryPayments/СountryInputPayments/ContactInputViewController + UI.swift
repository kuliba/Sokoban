//
//  ContactInputViewController + UI.swift
//  ForaBank
//
//  Created by Mikhail on 17.06.2021.
//

import UIKit

extension ContactInputViewController {
    func setupUI() {
        view.backgroundColor = .white
        let saveAreaView = UIView()
        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        view.addSubview(saveAreaView)
        saveAreaView.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor,
                            bottom: view.bottomAnchor, right: view.rightAnchor)
        view.addSubview(bottomView)
//        view.addSubview(foraSwitchView)
        
        
//        foraSwitchView.heightAnchor.constraint(equalToConstant: heightSwitchView).isActive = true
        
        //TODO: добавить скроллвью что бы избежать проблем на маленьких экранах
        // let scroll
        //  let view1 = UIView()
        //  view1.addSubview(stackView)
        // scroll add view1
        
        stackView = UIStackView(arrangedSubviews: [foraSwitchView, surnameField, nameField, secondNameField, phoneField, bankField, cardField, cardListView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
        
        setupConstraint()
    }
    
    func configure(with: Country?, byPhone: Bool) {
        guard let country = country else { return }
        UIView.animate(withDuration: 0.1) {
            self.needShowSwitchView = country.code == "AM" ? true : false
            self.phoneField.isHidden = byPhone ? false : true
            self.phoneField.textField.maskString = "+000-0000-00-00"
            self.bankField.isHidden = byPhone ? false : true
            self.surnameField.isHidden = byPhone ? true : false
            self.nameField.isHidden = byPhone ? true : false
            self.secondNameField.isHidden = byPhone ? true : false
        }
        
        let navImage = byPhone ? #imageLiteral(resourceName: "MigAvatar") : #imageLiteral(resourceName: "Vector")
        let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
        self.navigationItem.rightBarButtonItem = customViewItem
        
        guard let countryName = country.name else { return }
        
        let subtitle = byPhone
            ? "Денежные переводы МИГ"
            : "Денежные переводы Contact"
        
        self.navigationItem.titleView = self.setTitle(title: countryName, subtitle: subtitle)
        
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
