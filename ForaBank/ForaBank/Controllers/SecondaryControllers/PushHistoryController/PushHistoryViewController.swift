//
//  PushHistoryViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.11.2021.
//

import UIKit
import RealmSwift

class PushHistoryViewController: UIViewController {
    
    public static func storyboardInstance() -> PushHistoryViewController? {
        let storyboard = UIStoryboard(name: "PushHistoryStoryboard", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "pushHistory") as? PushHistoryViewController
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var realm = try? Realm()
    var token: NotificationToken?
    var tempArray: Results <GetNotificationsModel>?
    
    var offsetNumber = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        tempArray = realm?.objects(GetNotificationsModel.self)
        setupNavBar()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        downloadPushArray()
    }
    
    // MARK: Загрузка истории пушей
    /// Отправляем запрос на сервер, для получения истории пушей
    func downloadPushArray() {
        let tempOffset = String(offsetNumber)
        let body = ["offset": tempOffset,
                    "limit" : "100",
                    "notificationType" : "PUSH",
                    "notificationState" : "SENT"
        ]
        GetNotificationsModelSaved.add(body, [:]) {
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    
    deinit {
        clearPushRealmData()
    }
    
}



/*
 Всякий раз, когда размер содержимого превышает высоту прокрутки, он будет прокручиваться в соответствии с правильной позицией.
 */
//extension UIScrollView {
//
//    func scrollToBottom(animated: Bool) {
//        var y: CGFloat = 0.0
//        let HEIGHT = self.frame.size.height
//        if self.contentSize.height > HEIGHT {
//            y = self.contentSize.height - HEIGHT
//        }
//        self.setContentOffset(CGPointMake(0, y), animated: animated)
//    }
//}
