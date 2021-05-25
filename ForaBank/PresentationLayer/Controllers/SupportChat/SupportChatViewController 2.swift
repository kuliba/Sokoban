//
//  ChatViewController.swift
//  LiveTex SDK
//
//  Created by Эмиль Абдуселимов on 12.08.16.
//  Copyright © 2016 LiveTex. All rights reserved.
//

import UIKit
import LivetexCore
import JSQMessagesViewController

let kLivetexVisitorName = "kLivetexVisitorName"

@available(iOS 13.0, *)
@available(iOS 13.0, *)
class ChatViewController: JSQMessagesViewController,
                          LCCoreServiceDelegate,
                          UIImagePickerControllerDelegate,
                          UINavigationControllerDelegate {
    var messages = [JSQMessage]()
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var destination: LCDestination?
    
    @IBOutlet weak var titleLable: UILabel!
 
    override func viewWillAppear(_ animated: Bool) {
        /* Получаем список назначений */
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startService()
        prepare()
        self.senderId = ""
        self.senderDisplayName = ""
        self.inputToolbar.contentView.backgroundColor = .white
        self.inputToolbar.contentView.borderWidth = 0
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "LessLine"), for: .normal)
        self.inputToolbar.contentView.textView.placeHolder = "Написать сообщение…"
        self.inputToolbar.contentView.textView.borderWidth = 0
        self.inputToolbar.contentView.leftBarButtonItem.setImage(UIImage(named: "LeftButtonPath"), for: .normal)
        
        self.navigationController?.isNavigationBarHidden = true
        let screenSize: CGRect = UIScreen.main.bounds
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 69))
        
        myView.backgroundColor = UIColor(hexFromString: "ED433D")
        self.view.addSubview(myView)
        let label = UILabel()
        label.text = "Чат"
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont(name: "Roboto-Regular", size: 16)
        myView.addSubview(label)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: myView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: myView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        
        let roundedView = RoundedEdgeView(frame: CGRect(x: 0, y: myView.frame.size.height, width: screenSize.width, height: 40))
        roundedView.backgroundColor = UIColor(hexFromString: "ED433D")
        
        self.view.addSubview(roundedView)
        
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor(hexFromString: "ED433D"))
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        collectionView?.collectionViewLayout.springinessEnabled = false
        automaticallyScrollsToMostRecentMessage = true
        LivetexCoreManager.defaultManager.coreService.delegate = self

        receiveData()
        
       
        
        
    }
    func prepare(){
        LivetexCoreManager.defaultManager.coreService.setVisitor("name", completionHandler: { (success: Bool, error: Error?) in
                      if error == nil {
                          UserDefaults.standard.set("name", forKey: kLivetexVisitorName)
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
             if let error = error as? NSError {
                 print(error)
             } else {
                 print(token!)
             }
         }
     }
    
    func receiveData() {
        /* Запрашиваем текущее состояние диалога */
        LivetexCoreManager.defaultManager.coreService.state (completionHandler: { (state: LCDialogState?, error: Error?) in
            if let error = error as NSError? {
                print(error)
            } else {
                self.update(state!)
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
            self.finishReceivingMessage()
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
    
    func convertMessage(_ message: LCMessage) -> JSQMessage {
        var timeInterval: TimeInterval = 0.0
        if message.attributes.textIsSet {
            timeInterval = (message.attributes.text.created as NSString).doubleValue
            return JSQMessage(senderId: message.attributes.text.senderIsSet ? message.attributes.text.sender : self.senderId, senderDisplayName: "", date: Date(timeIntervalSince1970:timeInterval / 1000), text: message.attributes.text.text)
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
                            media?.image = UIImage(data: data!)
                            self.collectionView.collectionViewLayout.invalidateLayout(with: JSQMessagesCollectionViewFlowLayoutInvalidationContext())
                            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                        }
                    }
                }).resume()
                
                return JSQMessage(senderId: message.attributes.file.senderIsSet ? message.attributes.file.sender : self.senderId, senderDisplayName: "", date: Date(timeIntervalSince1970:timeInterval / 1000), media: media)
            } else {
                return JSQMessage(senderId: message.attributes.file.senderIsSet ? message.attributes.file.sender : self.senderId, senderDisplayName: "", date: Date(timeIntervalSince1970:timeInterval / 1000), text: message.attributes.file.url)
            }
        }
    }
    
    // MARK: - UIImagePickerController
    
//    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//
//        let image = info[UIImagePickerController.setEditing(UIImagePickerController)]
//        let imageData = UIImagePNGRepresentation(image)
//        /* Отправляем файловое сообщение */
//        LivetexCoreManager.defaultManager.coreService.sendFileMessage(imageData!) { (response: LCSendMessageResponse?, error: Error?) in
//            if let error = error as NSError? {
//                print(error)
//            } else {
//                /* Переназначаем адресат обращения в случае необходимости */
//                self.reloadDestinationIfNeeded(response!)
//                let message = LCMessage(messageId: response!.messageId, attributes: response!.attributes, confirm: true)
//                self.messages.append(self.convertMessage(message))
//                self.finishSendingMessage()
//            }
//        }
//
//        picker.dismiss(animated: true, completion: nil)
//    }
    
    // MARK: - LCCoreServiceDelegate
    
    func update(_ dialogState: LCDialogState) {
        if dialogState.employee != nil {
            self.navigationItem.title = "\(dialogState.employee!.firstname) \(dialogState.employee!.lastname)"
        } else {
            self.navigationItem.title = "Оператор"
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
        finishReceivingMessage(animated: true)
    }
    
    func receiveFileMessage(_ message: LCMessage) {
        self.messages.append(self.convertMessage(message))
        finishReceivingMessage(animated: true)
    }
    
    func selectDestination(_ destinations: [LCDestination]) {
        /* Указываем адресат обращения */
        LivetexCoreManager.defaultManager.coreService.setDestination(destinations.first!, attributes: LCDialogAttributes(visible: [:], hidden: [:]), options: [], completionHandler: { (success: Bool, error: Error?) in
            if let error = error as NSError? {
                print(error)
            }
        })
    }
    
    // MARK: - JSQMessagesViewController method overrides
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        /* Отправляем текстовое сообщение */
        LivetexCoreManager.defaultManager.coreService.sendTextMessage(text) { (response: LCSendMessageResponse?, error: Error?) in
            if let error = error as NSError? {
                print(error)
            } else {
                /* Переназначаем адресат обращения в случае необходимости */
                self.reloadDestinationIfNeeded(response!)
                let message = LCMessage(messageId: response!.messageId, attributes: response!.attributes, confirm: false)
                self.messages.append(self.convertMessage(message))
                self.finishSendingMessage(animated: true)
            }
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        let imagePickerController: UIImagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: - JSQMessages CollectionView DataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        return messages[indexPath.item].senderId == self.senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = self.messages[indexPath.item]
        
        if !message.isMediaMessage {
            var tintColor: UIColor = UIColor()
            if message.senderId == self.senderId {
                tintColor = UIColor.white
                
            } else {
                tintColor = UIColor.black
                
                
            }
            
            cell.textView.textColor = tintColor
            

        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]
        if message.senderId == self.senderId {
            return nil
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        let currentMessage = self.messages[indexPath.item]
        if currentMessage.senderId == self.senderId {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
}
