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
    
    var pushArray = [PushData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        downloadData()
        
    }
    
    private func downloadData() {
        
        let tempArray = realm?.objects(GetNotificationsModel.self)
        var tempPushArray = [CellData]()
        
        tempArray?.forEach({ model in
            tempPushArray.removeAll()
            var cellData = CellData()
            cellData.title = model.title ?? ""
            cellData.text  = model.text ?? ""
            cellData.date  = model.date ?? ""
            cellData.state = model.state ?? ""
            cellData.type  = model.type ?? ""
            tempPushArray.append(cellData)
            let push = PushData(model.date ?? "", data: tempPushArray)
            pushArray.append(push)

        })
    }
    
    func setupNavBar() {
        
        navigationItem.title = "Центр уведомлений"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_button") , style: .plain, target: self, action: #selector(backAction))
        
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
            [.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
            [.foregroundColor: UIColor.black], for: .highlighted)
        
    }
    
    @objc func backAction() {
        dismiss(animated: true, completion: nil)
        navigationController?.dismiss(animated: true, completion: nil)
    }
        
}

struct PushData {
    var header: String?
    var cellData: [CellData]?
    
    init(_ header: String, data: [CellData]) {
        self.header = header
        self.cellData = data
    }
}

struct CellData {
    
    var title: String?
    var text: String?
    var type: String?
    var state: String?
    var date: String?
    
}
