//
//  OperationDetailViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 01.11.2021.
//

import Foundation
import UIKit


class OperationDetailViewController: UIViewController{
    
    var stackView = UIStackView()
    
    var contactButtonStackView = UIStackView()
    
    var buttonStackView = UIStackView()

    let changeButton = UIButton()
    let returnButton = UIButton()

    
    
    var transferImage = UIImageView()
    
    var errorLabel: UILabel  = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 16, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    var nameOperationLabel: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 16, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    var companyImage = UIImageView()
    
    var recipient: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 16, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    var amount: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 24, weight: .bold), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    var commissionLabel: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 16, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    var commentView: UIView = {
        let view = UIView()
        view.setDimensions(height: 40, width: 276)
        view.backgroundColor = .lightGray
        view.add_CornerRadius(10)
        return view
    }()
    
    var commentLabel: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 16, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 12, weight: .regular), color: #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1))
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI(){
        
        view.backgroundColor = .white
        
        errorLabel.textColor = .red
        
        errorLabel.text = "Возврат!"
        transferImage.image = UIImage(named: "deposit_cards_list_onhold_block_button_highlighted")
        nameOperationLabel.text = "Юрий Андреевич К. \n 4081781057173665439"
        companyImage.image = UIImage(named: "IdBank")
        amount.text = "- 10 000,00 ₽"
        commissionLabel.text = "Комиссия: \n 10.00 ₽"
        commentLabel.text = "Оплата по договору №285"
        dateLabel.text = "5 сентября 2021, 19:54"
        
        transferImage.setDimensions(height: 64, width: 64)
        
        
        companyImage.setDimensions(height: 32, width: 32)
        
        commentView.addSubview(commentLabel)

        commentLabel.center(inView: commentView)
        
        stackView = UIStackView(arrangedSubviews: [transferImage, errorLabel, companyImage, nameOperationLabel, recipient, amount, commissionLabel, commentView, dateLabel, contactButtonStackView])



        
        view.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.anchor(top: view.topAnchor, left: view.leftAnchor,
                                bottom: view.bottomAnchor, right: view.rightAnchor)
        
        contactButtonStackView.anchor(left: view.leftAnchor, right: view.rightAnchor)

        contactButtonStackView = UIStackView(arrangedSubviews: [changeButton, returnButton])

        
        contactButtonStackView.axis = .horizontal
        contactButtonStackView.alignment = .center
        contactButtonStackView.distribution = .fill
        contactButtonStackView.spacing = 10
        contactButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        

//        stackView.backgroundColor = .systemYellow
        
        //Add buttons
        changeButton.setDimensions(height: 40, width: 160)
        changeButton.setTitleColor(.black, for: UIControl.State.normal)
        changeButton.layer.cornerRadius = 10
        changeButton.setTitle("Изменить", for: .normal)
        changeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        changeButton.tintColor = .black
        changeButton.backgroundColor = UIColor(hexString: "F6F6F7")
        changeButton.translatesAutoresizingMaskIntoConstraints = false
        changeButton.sizeToFit()
        
        
        returnButton.setDimensions(height: 40, width: 160)
        returnButton.setTitleColor(.black, for: UIControl.State.normal)
        returnButton.layer.cornerRadius = 10
        returnButton.setTitle("Вернуть", for: .normal)
        returnButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        returnButton.tintColor = .black
        returnButton.backgroundColor = UIColor(hexString: "F6F6F7")
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        returnButton.sizeToFit()
        
    }
}
