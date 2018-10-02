//
//  ChatMessagesViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 28/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class ChatMessagesViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatContainerView: UIView!
    
    var dialogName: String? {
        didSet {
            navigationItem.title = dialogName
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setKeyboardObservers()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        
        // Add back button
        let btnLeftMenu = UIButton(frame: CGRect(x: 0, y: 0, width: 33 / 2, height: 27 / 2))
        btnLeftMenu.setImage(UIImage(named: "icon_navigation_back"), for: [])
        btnLeftMenu.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        navigationItem.leftBarButtonItem = barButton
    }
}

// MARK: - Private methods
private extension ChatMessagesViewController {
    
    func setKeyboardObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            // Move chat container view up
            if self.chatContainerView.frame.origin.y == 0 {
                self.chatContainerView.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            // Move chat container view down
            if self.chatContainerView.frame.origin.y != 0 {
                self.chatContainerView.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    @objc func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
}
