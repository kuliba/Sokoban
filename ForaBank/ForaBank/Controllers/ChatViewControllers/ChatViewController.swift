//
//  ChatViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 28.09.2021.
//

import UIKit
import SwiftUI



class ChatViewController: UIViewController {

    var stackView = UIStackView()
    var secondStackView = UIStackView()
    
    var titleLabel = UILabel(text: "Раздел еще в разработке", font: UIFont.boldSystemFont(ofSize: 18), color: UIColor(hexString: "1C1C1C"))
    var subTitleLabel = UILabel(text: "Вы всегда можете обратиться в нашу службу поддержки с вопросами и предложениями", font: UIFont.systemFont(ofSize: 14), color: .black)
    var imageView = UIImageView(image: UIImage(named: "chatImage"))
    
    var phoneButton = UIButton()
    var emailButton = UIButton()
    var whatsUpButton = UIButton()
    var telegramButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    
    func setupUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(stackView)
        view.addSubview(secondStackView)
        
        titleLabel.textAlignment = .center
        subTitleLabel.numberOfLines = 0
        subTitleLabel.textAlignment = .center
        
        imageView.setDimensions(height: 72, width: 72)
        imageView.centerX(inView: view,
                          topAnchor: view.safeAreaLayoutGuide.topAnchor,
                          paddingTop: 22)
        
        titleLabel.anchor(left: view.leftAnchor, right: view.rightAnchor,
                          paddingLeft: 20, paddingRight: 20)
        titleLabel.centerX(inView: view,
                           topAnchor: imageView.bottomAnchor, paddingTop: 20)
        
        subTitleLabel.centerX(inView: view,
                           topAnchor: titleLabel.bottomAnchor, paddingTop: 20)
        subTitleLabel.anchor(left: view.leftAnchor, right: view.rightAnchor,
                             paddingLeft: 20, paddingRight: 20)
        
//
//        buttonPhone.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
//        buttonPhone.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill

        
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.fillEqually
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 16
        phoneButton = createButton(title: "8 (800) 100 9889", image: "", tintColor: "000000") //phone-outgoing
        emailButton = createButton(title: "Отправить e-mail", image: "", tintColor: "000000") //mailForChat
        stackView.addArrangedSubview(phoneButton)
        stackView.addArrangedSubview(emailButton)

      
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.anchor(top: subTitleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 100, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, height: 76)
        
        
        
        secondStackView.axis  = NSLayoutConstraint.Axis.horizontal
        secondStackView.distribution  = UIStackView.Distribution.fillEqually
        secondStackView.alignment = UIStackView.Alignment.center
        secondStackView.spacing = 16
        whatsUpButton = createButton(title: "WhatsApp", image: "", tintColor: "5DD467") //whatsup
        telegramButton = createButton(title: "Telegram", image: "", tintColor: "2AABEE") //telegram
        secondStackView.addArrangedSubview(whatsUpButton)
        secondStackView.addArrangedSubview(telegramButton)

      
        
        secondStackView.translatesAutoresizingMaskIntoConstraints = false
        
        secondStackView.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, height: 76)
        
        
    }
    
    func createButton(title: String, image: String, tintColor: String) -> UIButton{
        
        let button = UIButton(title: title)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.heightAnchor.constraint(equalToConstant: 76).isActive = true
        button.backgroundColor = UIColor(hexString: "EAEBEB")
        button.tintColor = UIColor(hexString: tintColor)
        button.setImage(UIImage(named: image), for: .normal)
        
        return button
    }
}


