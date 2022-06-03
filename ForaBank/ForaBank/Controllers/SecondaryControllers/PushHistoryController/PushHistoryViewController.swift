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
    
    var isLoadingList = false
    var tempArray = [PushHistoryModel]()
    var offsetNumber = "0"
    override func viewDidLoad() {
        super.viewDidLoad()
        readCash()
        downloadPushArray()
        setupNavBar()
    }

    // MARK: Загрузка истории пушей
    /// Отправляем запрос на сервер, для получения истории пушей
    func downloadPushArray() {
        self.isLoadingList = true
        showActivity()
        print("tempOffset :", offsetNumber)
        let body = ["offset": offsetNumber,
                    "limit": "10" ]
        
        let query = [URLQueryItem(name: "notificationState", value: "SENT"),
                     URLQueryItem(name: "notificationState", value: "DELIVERED"),
                     URLQueryItem(name: "notificationState", value: "READ"),
                     URLQueryItem(name: "notificationType", value: "PUSH"),
                     URLQueryItem(name: "notificationType", value: "SMS"),
        ]
        
        GetNotificationsModelSaved.add(body, [:], query) { [weak self] error in
            self?.dismissActivity()
            if (error != nil && error != "not update") {
                self?.showAlert(with: "Ошибка", and: error ?? "")
                return
            }
            
            if error == "not update" {
                return
            }
            self?.offsetNumber = "1"
            DispatchQueue.main.async {
                var model = PushHistoryViewModel()
                model.addSections { sections in
                    self?.tempArray = sections
                }
                self?.tableView?.reloadData()
                self?.isLoadingList = false
            }
            self?.tableView?.reloadData()
        }
    }
    
    
    func readCash() {
        DispatchQueue.main.async {
            var model = PushHistoryViewModel()
            model.addSections { sections in
                self.tempArray = sections
            }
            self.tableView?.reloadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
            self.downloadPushArray()
        }
    }
    
    deinit {
//        clearPushRealmData()
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
