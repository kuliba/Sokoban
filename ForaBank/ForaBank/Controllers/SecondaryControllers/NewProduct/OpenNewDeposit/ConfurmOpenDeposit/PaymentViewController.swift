//
//  PaymentViewController.swift
//  ForaBank
//
//  Created by Mikhail on 03.12.2021.
//

import UIKit
import AnyFormatKit
import IQKeyboardManagerSwift

class PaymentViewController: UIViewController {
    
    var stackView = UIStackView(arrangedSubviews: [])
    var bottomView: BottomInputView = {
        let inputView = BottomInputView(formater: SumTextInputFormatter(textPattern: "# ###,## ₽"))
        inputView.buttomLabel.isHidden = true
        inputView.doneButton.setTitle("Продолжить", for: .normal)
        return inputView
    }()
    private weak var bottomViewAncor: NSLayoutConstraint!
    private let saveAreaView = UIView()
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        stackView.isUserInteractionEnabled = true
        view.addSubview(stackView)
        
        stackView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 20)
        
        view.addSubview(bottomView)
        bottomView.anchor(
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor)
    }
}
