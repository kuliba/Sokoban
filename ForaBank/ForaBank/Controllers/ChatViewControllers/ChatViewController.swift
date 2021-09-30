//
//  ChatViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 28.09.2021.
//

import UIKit
import SwiftUI
import MessageUI


class ChatViewController: UIViewController, MFMailComposeViewControllerDelegate {

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
       
        let navigationBar = navigationController?.navigationBar
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBar?.isTranslucent = false
        navigationBarAppearance.shadowColor = .clear
        navigationBar?.scrollEdgeAppearance = navigationBarAppearance
        navigationBar?.barTintColor = .red
        navigationBar?.isTranslucent = false
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        navigationBar?.shadowImage = UIImage()
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
        
        
        //Action buttons
        
        
        
        phoneButton.addTarget(self, action: #selector(callNumber), for: .touchUpInside)
        telegramButton.addTarget(self, action: #selector(openTG), for: .touchUpInside)
        whatsUpButton.addTarget(self, action: #selector(openWhatsUp), for: .touchUpInside)
        emailButton.addTarget(self, action: #selector(sendEmail), for: .touchUpInside)

        
        
    }
    
    
    @objc func sendEmail() {
         let mailVC = MFMailComposeViewController()
         mailVC.mailComposeDelegate = self
         mailVC.setToRecipients(["fora-digital@forabank.ru"])
         mailVC.setSubject("ФОРА-ОНЛАЙН")
         mailVC.setMessageBody("", isHTML: false)

        present(mailVC, animated: true, completion: nil)
     }

     // MARK: - Email Delegate

    private func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
         controller.dismiss(animated: true, completion: nil)
     }
    
    @objc func openWhatsUp(){
        UIApplication.shared.openURL(NSURL(string: "https://api.whatsapp.com/send/?phone=%2B79257756555&text&app_absent=0")! as URL)

    }
    
    @objc func openTG(){
        UIApplication.shared.openURL(NSURL(string: "https://telegram.me/forabank_bot")! as URL)

    }
    
    @objc func callNumber() {

        if let phoneCallURL = URL(string: "telprompt://\("88001009889")") {

            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                     application.openURL(phoneCallURL as URL)

                }
            }
        }
    }
    @objc  func openPhoneNumber(){
        guard let number = URL(string: "tel://" + "8 (800) 100 9889") else { return }
        UIApplication.shared.open(number)
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


