//
//  ExtensionPushHistoryViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.11.2021.
//

import UIKit
import RealmSwift

extension PushHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tempArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempArray[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PushHistoryCell

        cell.setData(tempArray[indexPath.section].items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        view.backgroundColor = .white
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 15, height: 40))
        lbl.font = UIFont.systemFont(ofSize: 15)
        lbl.text = dateFormater(tempArray[section].sections, "dd MMMM YYYY, E")
        view.addSubview(lbl)
        return view
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func dateFormater(_ string: String, _ formatter: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let date = dateFormatter.date(from: string)!
        
        let d = DateFormatter()
        d.locale = Locale(identifier: "ru")
        d.dateFormat = formatter
        
        let stringDate = d.string(from: date)
        return stringDate
    }
    
    /// Очищаем в REALM
    final func clearPushRealmData() {
        
        let realm = try? Realm()
        do {
            let a = realm?.objects(GetNotificationsCellModel.self)
            let c = realm?.objects(GetNotificationsModel.self)
            realm?.beginWrite()
            realm?.delete(a!)
            realm?.delete(c!)
            try realm?.commitWrite()
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
