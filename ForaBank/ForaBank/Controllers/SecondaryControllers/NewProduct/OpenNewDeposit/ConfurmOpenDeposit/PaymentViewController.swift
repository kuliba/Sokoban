//
//  PaymentViewController.swift
//  ForaBank
//
//  Created by Mikhail on 03.12.2021.
//

import UIKit
import IQKeyboardManagerSwift

class PaymentViewController: UIViewController {
    
    var stackView = UIStackView(arrangedSubviews: [])
    var bottomView = BottomInputView()
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
        
        
        saveAreaView.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        view.addSubview(saveAreaView)
        saveAreaView.anchor(
            top: view.safeAreaLayoutGuide.bottomAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor)
        
        view.addSubview(bottomView)
        bottomView.anchor(
            left: view.leftAnchor,
            right: view.rightAnchor)
        
        bottomViewAncor = bottomView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        bottomViewAncor.isActive = true
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addKBNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    private func addKBNotification() {
        IQKeyboardManager.shared.enable = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWasShown(notification: Notification) {
        if bottomView.amountTextField.isEditing {
            let info = notification.userInfo! as NSDictionary
            let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
            bottomViewPosition(with: -kbSize.height + saveAreaView.frame.height)
        }
    }
    
    @objc private func keyboardWillBeHidden(notification: Notification) {
        if bottomView.amountTextField.isEditing {
            bottomViewPosition(with: 0)
        }
    }
    
    func bottomViewPosition(with position: CGFloat) {
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomViewAncor.constant = position
            self.bottomView.setNeedsUpdateConstraints()
            self.bottomView.layoutIfNeeded()
        })
    }
    
    
}
