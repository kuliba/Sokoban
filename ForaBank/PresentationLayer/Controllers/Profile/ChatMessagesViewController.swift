//
//  ChatMessagesViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 28/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import LivetexCore


class ChatMessagesViewController: UIViewController, UITextFieldDelegate, LCCoreServiceDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatContainerView: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageSendButton: UIButton!
    @IBOutlet weak var iconStack: UIStackView!
    
    private let manager = MessageManager()
//    private let imageService = ImagePickerService()
//    private let locationService = LocationService()
    private var messagesU2U = [ObjectMessage]()
    var conversation = ObjectConversation()
    
    
    //    let messages_ = [
//        [
//            ChatMessage(type: .outgoing, time: "23:40", message: "Привет, как дела?", isDelivered: false, amount: ""),
//            ChatMessage(type: .incoming, time: "23:45", message: "Отдыхаю после вчерашнего", isDelivered: true, amount: ""),
//            ChatMessage.init(type: .outgoing, time: "23:57", message: "Переведешь, как обещал?", isDelivered: false, amount: ""),
//            ChatMessage(type: .incoming, time: "23:57", message: "А сколько вышло?", isDelivered: true, amount: "")
//        ],
//        [ChatMessage(type: .transferRequest, time: "00:12", message: "", isDelivered: false, amount: "500 ₽")]
//    ]
//    let reversedMessages_ = [
//        [ChatMessage(type: .transferRequest, time: "00:12", message: "", isDelivered: false, amount: "500 ₽")],
//        [
//            ChatMessage(type: .incoming, time: "23:57", message: "А сколько вышло?", isDelivered: true, amount: ""),
//            ChatMessage.init(type: .outgoing, time: "23:57", message: "Переведешь, как обещал?", isDelivered: false, amount: ""),
//            ChatMessage(type: .incoming, time: "23:45", message: "Отдыхаю после вчерашнего", isDelivered: true, amount: ""),
//            ChatMessage(type: .outgoing, time: "23:40", message: "Привет, как дела?", isDelivered: false, amount: "")
//        ]
//    ]
//    let tableHeaders_ = ["28 ноября", "Сегодня"]
    let reversedHeaders_ = ["Сегодня", "28 ноября"] //footers
    var senderId = ""
    var senderDisplayName = "Bob"
    var profile: Profile?
    var messages = [JSQMessage]()
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var destination: LCDestination?
    var delegateSenderId = JSQMessagesViewController()
    var dialogName: String? {
        didSet {
            navigationItem.title = dialogName
        }
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /* Получаем список назначений */
        if dialogName == "Техническая поддержка"{
             LivetexCoreManager.defaultManager.coreService.destinations { (destinations: [LCDestination]?, error: Error?) in
                 if let error = error as NSError? {
                     print(error)
                     return
                 }
                 
                 /* Из списка выбираем необходимый нам */
                 var result = destinations!.filter({$0.department.departmentId == "42"})
                 if result.count <= 0 {
                     result = destinations!
                 }
                 
                 /* Указываем пользовательские атрибуты обращения, которые отобразятся оператору */
                 let attributes = LCDialogAttributes()
                 attributes.visible = ["Field": "Test"]
                 
                 /* Указываем адресата обращения и дополнительно к пользовательским атрибутам укажем, чтобы передавались тип устройства и тип соединения */
                 LivetexCoreManager.defaultManager.coreService.setDestination(result.first!, attributes: attributes, options: [.deviceModel, .connectionType], completionHandler: { (success: Bool, error: Error?) in
                     if let error = error as NSError? {
                         print(error)
                     }
                 })
             }
        }
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    
    
    private func send(_ message: ObjectMessage) {
      manager.create(message, conversation: conversation) {[weak self] response in
        guard let weakSelf = self else { return }
        if response == .failure {
          return
        }
        weakSelf.conversation.timestamp = Int(Date().timeIntervalSince1970)
        switch message.contentType {
        case .none: weakSelf.conversation.lastMessage = message.message
        case .photo: weakSelf.conversation.lastMessage = "Attachment"
        default: break
        }
        if let currentUserID = UserManager().currentUserID() {
          weakSelf.conversation.isRead[currentUserID] = true
        }
        ConversationManager().create(weakSelf.conversation)
      }
    }
    
    @IBAction func sendMessageButton(_ sender: Any) {
        if messageTextField.text != "", dialogName == "Техническая поддержка"{
            LivetexCoreManager.defaultManager.coreService.sendTextMessage(messageTextField.text!) { (response: LCSendMessageResponse?, error: Error?) in
                    if let error = error as NSError? {
                        print(error)
                    } else {
                        /* Переназначаем адресат обращения в случае необходимости */
                        self.reloadDestinationIfNeeded(response!)
                        let message = LCMessage(messageId: response!.messageId, attributes: response!.attributes, confirm: false)
                        self.messages.append(self.convertMessage(message))
                        self.fetchMessageWithSupport()
                        self.tableView.reloadData()
                            self.messageTextField.text = ""
                    }
                }
        } else {
              guard let text = messageTextField.text, !text.isEmpty else { return }
              let message = ObjectMessage()
              message.message = text
              message.ownerID = UserManager().currentUserID()
              messageTextField.text = nil
              send(message)
        }
    }
  
    @IBAction func changeTextMessage(_ sender: Any) {
        if dialogName == "Техническая поддержка"{
        LivetexCoreManager.defaultManager.coreService.setTyping(messageTextField.text ?? "") { (success, error) in
            if success{
                print("it's success Bitch")
            } else {
                print(error ?? "1")
            }
        }
        } else {
            
        }
}
    @IBAction func showSendButton(_ sender: Any) {
        messageSendButton.isHidden = false
             iconStack.isHidden = true
    }
    
    @IBAction func hideSendButton(_ sender: Any) {
        messageSendButton.isHidden = true
              iconStack.isHidden = false
    }
    
    // MARK: - Actions
    @IBAction func sendMoneyButtonClicked(_ sender: Any) {
        instantiatePaymentDetailsViewController()
        
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        messageSendButton.isHidden = true
        self.messageTextField.delegate = self
//        tabBarController.isNone = true
        setKeyboardObservers()
        addBackButton()
//        addHideKeyBoardButton()
        tableView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
//
//        NetworkManager.shared().getProfile { (success, profile, errorMessage) in
//            if success{
//                self.profile = profile
//                currentUser?.name = String("\(profile?.firstName) \(profile?.patronymic) \(profile?.lastName)")
//                userManager?.update(user: ObjectUser.init(), completion: {_ in })
//                let currentUser: ObjectUser?
//                let userManager: UserManager?
//
//            } else {
//                let alert = UIAlertController(title: "Ошибка", message: errorMessage, preferredStyle: .alert)
//                self.present(alert, animated: true, completion:nil)
//
//            }
//        }
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.sectionHeaderHeight = 0
        tableView.contentInset.top = -25
        tableView.register(ChatMessagesOutgoingTableViewCell.self, forCellReuseIdentifier: MessageType.outgoing.rawValue)
        tableView.register(ChatMessagesIncomingTableViewCell.self, forCellReuseIdentifier: MessageType.incoming.rawValue)
        tableView.register(ChatMessagesTransferRequestTableViewCell.self, forCellReuseIdentifier: MessageType.transferRequest.rawValue)
        

        if dialogName == "Техническая поддержка"{
            startService()
            prepare()
            LivetexCoreManager.defaultManager.coreService.delegate = self
            receiveData()
            
        } else {
            fetchMessages()
            fetchUserName()
                  
        }
    }
    
    public func fullName() -> String {
        var fullName: String
        fullName = "\(profile?.firstName ?? "") \(profile?.patronymic ?? "") \(profile?.lastName ?? "")"
        return fullName
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension ChatMessagesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dialogName == "Техническая поддержка"{
            return messages.count
        } else {
        return messagesU2U.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if reversedMessages_[indexPath.section][indexPath.row].type == .transferRequest {
//            return 130
//        }
        if dialogName == "Техническая поддержка"{
            let attrS = NSAttributedString(string: messages[indexPath.row].text ?? "nil", attributes: [.font : UIFont(name: "Roboto-Regular", size: 14)!])

                   let rect = attrS.boundingRect(with: CGSize(width: tableView.frame.width-100, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, context: nil)
                   
                   return rect.height+40
        } else {
            let attrS = NSAttributedString(string: messagesU2U[indexPath.row].message ?? "nil", attributes: [.font : UIFont(name: "Roboto-Regular", size: 14)!])

                   let rect = attrS.boundingRect(with: CGSize(width: tableView.frame.width-100, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, context: nil)
                   
                   return rect.height+40
            
        }
   
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 22
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerLabel = UILabel()
//        footerLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
//
//        footerLabel.attributedText = NSAttributedString(string: reversedHeaders_[section], attributes: [.font : UIFont(name: "Roboto-Regular", size: 14)!, .foregroundColor : UIColor.gray])
//        footerLabel.textAlignment = .center
//        return footerLabel
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        func cellType() -> String?{
            if dialogName == "Техническая поддержка" {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId{
            let cellId = "incoming"
            return cellId
        } else {
            let cellId = "outgoing"
            return cellId

        }
            } else {
                if  messagesU2U[indexPath.item].ownerID == UserManager().currentUserID() {
                          let cellId = "incoming"
                          return cellId
                      } else {
                          let cellId = "outgoing"
                          return cellId

                      }
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType()!, for: indexPath)
        cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        
//        if message.senderId == self.senderId {
//            guard let c = cell as? ChatMessagesOutgoingTableViewCell else {
//                        return cell
//                    }
//            c.messageLabel.text = messages[indexPath.item].text
//            c.timeLabel.text =  "11"
//                    let messageSize = c.messageLabel.intrinsicContentSize
//                    c.frameView.frame = CGRect(x: 0, y: 5, width: messageSize.width+80, height: messageSize.height+30)
//                    c.messageLabel.frame = CGRect(x: 15, y: 15, width: messageSize.width, height: messageSize.height)
//        } else {
//                   guard let c = cell as? ChatMessagesIncomingTableViewCell else {
//                            return cell
//                        }
//            //            print(c.frameView)
//                        c.messageLabel.text = messages[indexPath.row].text
//                        c.timeLabel.text = "11"
//
//                        let rect = c.messageLabel.attributedText!.boundingRect(with: CGSize(width: tableView.frame.width-100, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, context: nil)
//
//                        c.frameView.frame = CGRect(x: tableView.frame.width-(rect.width+95), y: 5, width: rect.width+95, height: rect.height+30)
//                        c.messageLabel.frame = CGRect(x: 15, y: 15, width: rect.width, height: rect.height)
//
//        }
        switch cellType() {
        case "outgoing":
            guard let c = cell as? ChatMessagesOutgoingTableViewCell else {
                return cell
            }
            
            if dialogName == "Техническая поддержка"{
                  c.messageLabel.text = messages[indexPath.item].text
                c.timeLabel.text =  DateService.shared.format(messages[indexPath.item].date)
            } else {
                c.messageLabel.text = messagesU2U[indexPath.item].message
                c.timeLabel.text =  DateService.shared.format(Date(timeIntervalSince1970: TimeInterval(messagesU2U[indexPath.item].timestamp)))
            }
            let messageSize = c.messageLabel.intrinsicContentSize
            c.frameView.frame = CGRect(x: 0, y: 5, width: messageSize.width+80, height: messageSize.height+30)
            c.messageLabel.frame = CGRect(x: 15, y: 15, width: messageSize.width, height: messageSize.height)
        case "incoming":
            guard let c = cell as? ChatMessagesIncomingTableViewCell else {
                return cell
            }
                if dialogName == "Техническая поддержка"{
                c.messageLabel.text = messages[indexPath.item].text
              c.timeLabel.text =  DateService.shared.format(messages[indexPath.item].date)
                } else {
              c.messageLabel.text = messagesU2U[indexPath.item].message
              c.timeLabel.text =  DateService.shared.format(Date(timeIntervalSince1970: TimeInterval(messagesU2U[indexPath.item].timestamp)))
            }
            let rect = c.messageLabel.attributedText!.boundingRect(with: CGSize(width: tableView.frame.width-100, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, context: nil)

            c.frameView.frame = CGRect(x: tableView.frame.width-(rect.width+95), y: 5, width: rect.width+95, height: rect.height+30)
            c.messageLabel.frame = CGRect(x: 15, y: 15, width: rect.width, height: rect.height)
//        case .transferRequest:
//            guard let c = cell as? ChatMessagesTransferRequestTableViewCell else {
//                return cell
//            }
//            let name = dialogName?.split(separator: " ")[0]
//            c.messageLabel.text = "\(name ?? "")\nПопросил"
//            c.sumLabel.text = reversedMessages_[indexPath.section][indexPath.row].amount
//            c.timeLabel.text = reversedMessages_[indexPath.section][indexPath.row].time
//            c.sendButton.addTarget(self, action: #selector(sendMoneyButtonClicked(_:)), for: .touchUpInside)
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
    @objc func dismissKeyboard()    {
        view.endEditing(true)
     }
    func hideKeyboardWhenTappedAround() {
      let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(dismissKeyboard))
       tap.cancelsTouchesInView = false
       view.addGestureRecognizer(tap)
     }
 
    
    @objc func backButtonClicked() {
//        navigationController?.popViewController(animated: true)
//        navigationController?.popToRootViewController(animated: true)
       
                  dismiss(animated: true, completion: nil)
              
    }
    
    func addBackButton() {
        let btnLeftMenu = UIButton(frame: CGRect(x: 0, y: 0, width: 33/2, height: 27/2))
        btnLeftMenu.setImage(UIImage(named: "icon_navigation_back"), for: [])
        btnLeftMenu.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        navigationItem.leftBarButtonItem = barButton
    }


//    func addHideKeyBoardButton() {
//         let hideKeyBoadrd = UIButton(frame: CGRect(x: 0, y: 0, width: 33/2, height: 27/2))
//         hideKeyBoadrd.setImage(UIImage(named: "icon_navigation_back"), for: [])
//         hideKeyBoadrd.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
//         let barButton = UIBarButtonItem(customView: hideKeyBoadrd)
//         navigationItem.rightBarButtonItem = barButton
//     }
    
    func instantiatePaymentDetailsViewController() {
        if let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetailsViewController") as? PaymentsDetailsSuccessViewController {
            present(vc, animated: true)
        }
    }
}

extension ChatMessagesViewController:
UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    
    
    func prepare(){
        LivetexCoreManager.defaultManager.coreService.setVisitor(fullName(), completionHandler: { (success: Bool, error: Error?) in
                      if error == nil {
                        UserDefaults.standard.set(self.fullName() , forKey: kLivetexVisitorName)
                      }
                  })
            }
    
    func startService() {
       LivetexCoreManager.defaultManager.coreService = LCCoreService(url: "https://authentication-service-sdk-production-1.livetex.ru",
                                                                       appID: "166171",
                                                                       appKey: "demo",
                                                                       token: nil,
                                                                       deviceToken: LivetexCoreManager.defaultManager.apnToken,
                                                                       callbackQueue: OperationQueue.main,
                                                                       delegateQueue: OperationQueue.main)
         
         LivetexCoreManager.defaultManager.coreService.start { (token: String?, error: Error?) in
             if let error = error{
                 print(error)
             } else {
                 print(token!)
             }
         }

     }
    
    

    
    
    func update(_ dialogState: LCDialogState) {
        if dialogState.employee != nil {
            self.navigationItem.title = "\(dialogState.employee!.firstname) \(dialogState.employee!.lastname)"
        } else {
            self.navigationItem.title = "Оператор"
        }
    }
    
    func convertMessage(_ message: LCMessage) -> JSQMessage {
        var timeInterval: TimeInterval = 0.0
        if message.attributes.textIsSet {
            timeInterval = (message.attributes.text.created as NSString).doubleValue
            return JSQMessage(senderId: message.attributes.text.senderIsSet ? message.attributes.text.sender : senderId, senderDisplayName: "Оператор", date: Date(timeIntervalSince1970:timeInterval / 1000), text: message.attributes.text.text)
        } else {
            timeInterval = (message.attributes.file.created as NSString).doubleValue
            let fileURL: String = message.attributes.file.url.removingPercentEncoding!
            let pathExtention = (fileURL as NSString).pathExtension
            let paths: [String] = ["png", "jpg", "jpeg", "gif"]
            if paths.contains(pathExtention) {
                let media = JSQPhotoMediaItem(maskAsOutgoing: !message.attributes.file.senderIsSet)
                let url = Foundation.URL(string: message.attributes.file.url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
                URLSession.shared.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                    if let error = error as NSError? {
                        print(error)
                    } else {
                        DispatchQueue.main.async {
//                            media?.image = UIImage(data: data!)
//                            self.collectionView.collectionViewLayout.invalidateLayout(with: JSQMessagesCollectionViewFlowLayoutInvalidationContext())
//                            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                        }
                    }
                }).resume()
                
                return JSQMessage(senderId: message.attributes.file.senderIsSet ? message.attributes.file.sender : self.senderId, senderDisplayName: "", date: Date(timeIntervalSince1970:timeInterval / 1000), media: media)
            } else {
                return JSQMessage(senderId: message.attributes.file.senderIsSet ? message.attributes.file.sender : self.senderId, senderDisplayName: "", date: Date(timeIntervalSince1970:timeInterval / 1000), text: message.attributes.file.url)
            }
        }
    }

    
       func confirmMessage(_ messageId: String) {
           print(#function)
       }
       
       func receiveTextMessage(_ message: LCMessage) {
           /* Отправляем подтверждение о получении сообщения */
           LivetexCoreManager.defaultManager.coreService.confirmMessage(withID: message.messageId) { (success: Bool, error: Error?) in
               if let error = error as NSError? {
                   print(error)
               }
           }
           
           self.messages.append(self.convertMessage(message))
            fetchMessageWithSupport()
            self.tableView.reloadData()

    }
       
       func receiveFileMessage(_ message: LCMessage) {
           self.messages.append(self.convertMessage(message))
            tableView.reloadData()
//           finishReceivingMessage(animated: true)
       }
       
       func selectDestination(_ destinations: [LCDestination]) {
           /* Указываем адресат обращения */
           LivetexCoreManager.defaultManager.coreService.setDestination(destinations.first!, attributes: LCDialogAttributes(visible: [:], hidden: [:]), options: [], completionHandler: { (success: Bool, error: Error?) in
               if let error = error as NSError? {
                   print(error)
               }
           })
       }
       func reloadDestinationIfNeeded(_ response: LCSendMessageResponse) {
           if !response.destinationIsSet {
               /* Получаем список назначений */
               LivetexCoreManager.defaultManager.coreService.destinations(completionHandler: { (destinations: [LCDestination]?, error: Error?) in
                   if let error = error as NSError? {
                       print(error)
                       return
                   }
                   
                   /* Указываем адресат обращения */
                   LivetexCoreManager.defaultManager.coreService.setDestination(destinations!.first!, attributes: LCDialogAttributes(visible: [:], hidden: [:]), options: [], completionHandler: { (success: Bool, error: Error?) in
                       if let error = error as NSError? {
                           print(error)
                       }
                   })
               })
           }
       }
    
       // MARK: - JSQMessagesViewController method overrides

       
     func didPressAccessoryButton(_ sender: UIButton) {
//           self.messageTextField.contentView!.textView!.resignFirstResponder()
           let imagePickerController: UIImagePickerController = UIImagePickerController()
           imagePickerController.delegate = self
           imagePickerController.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
           imagePickerController.allowsEditing = true
           self.present(imagePickerController, animated: true, completion: nil)
       }
    
      func receiveData() {
           /* Запрашиваем текущее состояние диалога */
           LivetexCoreManager.defaultManager.coreService.state (completionHandler: { (state: LCDialogState?, error: Error?) in
               if let error = error as NSError? {
                   print(error)
               } else {
                   self.update(state!)
                self.fetchMessageWithSupport()
               }
           })
           
           /* Запрашиваем историю переписки */
           LivetexCoreManager.defaultManager.coreService.messageHistory(20, offset: 0, completionHandler: { (messageList: [LCMessage]?, error: Error?) in
               if let error = error as NSError? {
                   print(error)
                   return
               }
               
               let toConfirmList = messageList?.filter{ $0.confirm == false && ($0.attributes.text.senderIsSet || $0.attributes.file.senderIsSet) }
               toConfirmList?.forEach({ (message: LCMessage) in
                   /* Отправляем подтверждение о получении сообщения */
                   LivetexCoreManager.defaultManager.coreService.confirmMessage(withID: message.messageId, completionHandler: { (success: Bool, error: Error?) in
                       if let error = error as NSError? {
                           print(error)
                       } else {
                           message.confirm = true
                       }
                   })
                })
               
               self.messages.append(contentsOf: messageList!.reversed().map{ self.convertMessage($0) })
            self.fetchMessageWithSupport()
            self.tableView.reloadData()
           })
       }
    
}

extension ChatMessagesViewController{
   private func fetchMessages() {
      manager.messages(for: conversation) {[weak self] messages in
        self?.messagesU2U = messages.sorted(by: {$0.timestamp > $1.timestamp})
        self?.tableView.reloadData()
      }
    }
    
    private func fetchMessageWithSupport(){
        messages = messages.sorted(by: {$0.date > $1.date})
        self.tableView.reloadData()
    }
    
    private func fetchUserName() {
      guard let currentUserID = UserManager().currentUserID() else { return }
      guard let userID = conversation.userIDs.filter({$0 != currentUserID}).first else { return }
      UserManager().userData(for: userID) {[weak self] user in
        guard let name = user?.name else { return }
        self?.navigationItem.title = name
      }
    }
}
