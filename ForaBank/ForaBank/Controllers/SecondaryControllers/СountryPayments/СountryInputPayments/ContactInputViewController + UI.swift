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
        
        view.addSubview(doneButton)
        view.addSubview(foraSwitchView)
        
        doneButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.rightAnchor, paddingLeft: 20, paddingBottom: 20,
                          paddingRight: 20, height: 44)
                
        foraSwitchView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        foraSwitchView.anchor(height: needShowSwitchView ? 48 : 0)
        
        //TODO: добавить скроллвью что бы избежать проблем на маленьких экранах
        // let scroll
        //  let view1 = UIView()
        //  view1.addSubview(stackView)
        // scroll add view1
        
        //, cardListView
        let stackView = UIStackView(arrangedSubviews: [surnameField, nameField, secondNameField, phoneField, bankField, cardField, summTransctionField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
        stackView.anchor(top: foraSwitchView.bottomAnchor, left: view.leftAnchor,
                         right: view.rightAnchor, paddingTop: 20)
        
    }
    
    func configure(with: Country?) {
        guard let country = country else { return }
        foraSwitchView.isHidden = country.code == "AM" ? false : true
        needShowSwitchView = country.code == "AM" ? true : false
        phoneField.isHidden = country.code == "AM" ? false : true
        phoneField.textField.maskString = "+0000-000-00-00"
        bankField.isHidden = country.code == "AM" ? false : true
        surnameField.isHidden = country.code == "AM" ? true : false
        nameField.isHidden = country.code == "AM" ? true : false
        secondNameField.isHidden = country.code == "AM" ? true : false
        
        let navImage = country.code == "AM" ? #imageLiteral(resourceName: "MigAvatar") : #imageLiteral(resourceName: "Vector")
        let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
        self.navigationItem.rightBarButtonItem = customViewItem
        
        guard let countryName = country.name else { return }
        
        let subtitle = country.code == "AM"
            ? "Денежные переводы МИГ"
            : "Денежные переводы Contact"
        
        self.navigationItem.titleView = setTitle(title: countryName, subtitle: subtitle)
        setupUI()
        self.view.layoutIfNeeded()
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
