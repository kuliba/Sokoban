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
    
    var currentPage = 0
    var isLoadingList = false
    
    var tempArray = [PushHistoryModel]()
    var offset = UserDefaults.standard.object(forKey: "offset") as? String ?? ""
    var offsetNumber = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentPage = Int(self.offset) ?? 0
        self.offsetNumber = Int(self.offset) ?? 0
        readCash()
        downloadPushArray()
        setupNavBar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
   
    func loadMoreItemsForList() {
           currentPage += 1
           downloadPushArray()
       }
    
    // MARK: Загрузка истории пушей
    /// Отправляем запрос на сервер, для получения истории пушей
    func downloadPushArray() {
        self.isLoadingList = true
        showActivity()
        let tempOffset = String(offsetNumber)
        print("tempOffset :", offsetNumber)
        let body = ["offset": tempOffset,
                    "limit": "10",
                    "notificationType": "PUSH"
                     ]
        
        let query = [URLQueryItem(name: "notificationState", value: "SENT"),
                     URLQueryItem(name: "notificationState", value: "DELIVERED"),
                     URLQueryItem(name: "notificationState", value: "READ"),
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
            
            DispatchQueue.main.async {
                var model = PushHistoryViewModel()
                model.addSections { sections in
                    self?.tempArray = sections
                }
                self?.tableView?.reloadData()
                self?.isLoadingList = false
                self?.offsetNumber += 10
                UserDefaults.standard.setValue(String(self?.offsetNumber ?? 0), forKey: "offset")
            }
           print("tempOffset2 :", self?.tempArray.count ?? 0 )
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
                self.loadMoreItemsForList()
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
