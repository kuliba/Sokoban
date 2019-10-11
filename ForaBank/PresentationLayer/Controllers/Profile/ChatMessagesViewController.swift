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
    
//    let messages_ = [
//        [
//            ChatMessage(type: .outgoing, time: "23:40", message: "Привет, как дела?", isDelivered: false, amount: ""),
//            ChatMessage(type: .incoming, time: "23:45", message: "Отдыхаю после вчерашнего", isDelivered: true, amount: ""),
//            ChatMessage.init(type: .outgoing, time: "23:57", message: "Переведешь, как обещал?", isDelivered: false, amount: ""),
//            ChatMessage(type: .incoming, time: "23:57", message: "А сколько вышло?", isDelivered: true, amount: "")
//        ],
//        [ChatMessage(type: .transferRequest, time: "00:12", message: "", isDelivered: false, amount: "500 ₽")]
//    ]
    let reversedMessages_ = [
        [ChatMessage(type: .transferRequest, time: "00:12", message: "", isDelivered: false, amount: "500 ₽")],
        [
            ChatMessage(type: .incoming, time: "23:57", message: "А сколько вышло?", isDelivered: true, amount: ""),
            ChatMessage.init(type: .outgoing, time: "23:57", message: "Переведешь, как обещал?", isDelivered: false, amount: ""),
            ChatMessage(type: .incoming, time: "23:45", message: "Отдыхаю после вчерашнего", isDelivered: true, amount: ""),
            ChatMessage(type: .outgoing, time: "23:40", message: "Привет, как дела?", isDelivered: false, amount: "")
        ]
    ]
//    let tableHeaders_ = ["28 ноября", "Сегодня"]
    let reversedHeaders_ = ["Сегодня", "28 ноября"] //footers
    
    var dialogName: String? {
        didSet {
            navigationItem.title = dialogName
        }
    }
    
    // MARK: - Actions
    @IBAction func sendMoneyButtonClicked(_ sender: Any) {
        instantiatePaymentDetailsViewController()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setKeyboardObservers()
        addBackButton()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        
        tableView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.sectionHeaderHeight = 0
        tableView.contentInset.top = -25
        tableView.register(ChatMessagesOutgoingTableViewCell.self, forCellReuseIdentifier: MessageType.outgoing.rawValue)
        tableView.register(ChatMessagesIncomingTableViewCell.self, forCellReuseIdentifier: MessageType.incoming.rawValue)
        tableView.register(ChatMessagesTransferRequestTableViewCell.self, forCellReuseIdentifier: MessageType.transferRequest.rawValue)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

extension ChatMessagesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return reversedHeaders_.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reversedMessages_[section].count
        //return section==0 ? 0 : 4//messages_.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if reversedMessages_[indexPath.section][indexPath.row].type == .transferRequest {
            return 130
        }
        
        let attrS = NSAttributedString(string: reversedMessages_[indexPath.section][indexPath.row].message, attributes: [.font : UIFont(name: "Roboto-Regular", size: 14)!])
        let rect = attrS.boundingRect(with: CGSize(width: tableView.frame.width-100, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, context: nil)
        return rect.height+40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 22
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerLabel = UILabel()
        footerLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        footerLabel.attributedText = NSAttributedString(string: reversedHeaders_[section], attributes: [.font : UIFont(name: "Roboto-Regular", size: 14)!, .foregroundColor : UIColor.gray])
        footerLabel.textAlignment = .center
        return footerLabel
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellType = reversedMessages_[indexPath.section][indexPath.row].type
        let cellId = cellType.rawValue
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        switch cellType {
        case .outgoing:
            guard let c = cell as? ChatMessagesOutgoingTableViewCell else {
                return cell
            }
            c.messageLabel.text = reversedMessages_[indexPath.section][indexPath.row].message
            c.timeLabel.text = reversedMessages_[indexPath.section][indexPath.row].time
            
            let messageSize = c.messageLabel.intrinsicContentSize
            c.frameView.frame = CGRect(x: 0, y: 5, width: messageSize.width+80, height: messageSize.height+30)
            c.messageLabel.frame = CGRect(x: 15, y: 15, width: messageSize.width, height: messageSize.height)
        case .incoming:
            guard let c = cell as? ChatMessagesIncomingTableViewCell else {
                return cell
            }
//            print(c.frameView)
            c.messageLabel.text = reversedMessages_[indexPath.section][indexPath.row].message
            c.timeLabel.text = reversedMessages_[indexPath.section][indexPath.row].time

            let rect = c.messageLabel.attributedText!.boundingRect(with: CGSize(width: tableView.frame.width-100, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, context: nil)

            c.frameView.frame = CGRect(x: tableView.frame.width-(rect.width+95), y: 5, width: rect.width+95, height: rect.height+30)
            c.messageLabel.frame = CGRect(x: 15, y: 15, width: rect.width, height: rect.height)
        case .transferRequest:
            guard let c = cell as? ChatMessagesTransferRequestTableViewCell else {
                return cell
            }
            let name = dialogName?.split(separator: " ")[0]
            c.messageLabel.text = "\(name ?? "")\nПопросил"
            c.sumLabel.text = reversedMessages_[indexPath.section][indexPath.row].amount
            c.timeLabel.text = reversedMessages_[indexPath.section][indexPath.row].time
            c.sendButton.addTarget(self, action: #selector(sendMoneyButtonClicked(_:)), for: .touchUpInside)
        default:
            break
        }
        

        return cell
    }
    
    
}

// MARK: - Private methods
private extension ChatMessagesViewController {
    
    func setKeyboardObservers() {
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            // Move chat container view up
            print("keyboardSize \(keyboardSize)")
            print(self.chatContainerView.frame.origin.y)
            if self.chatContainerView.frame.origin.y == 0 {
                self.chatContainerView.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            print("keyboardSize \(keyboardSize)")
            print(self.chatContainerView.frame.origin.y)
            // Move chat container view down
            if self.chatContainerView.frame.origin.y != 0 {
                self.chatContainerView.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    @objc func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    func addBackButton() {
        let btnLeftMenu = UIButton(frame: CGRect(x: 0, y: 0, width: 33/2, height: 27/2))
        btnLeftMenu.setImage(UIImage(named: "icon_navigation_back"), for: [])
        btnLeftMenu.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        navigationItem.leftBarButtonItem = barButton
    }
    
    func instantiatePaymentDetailsViewController() {
        if let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetailsViewController") as? PaymentDetailsViewController {
            present(vc, animated: true)
        }
    }
}
