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
        return tempArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempArray?[section].getNotificationsEntity.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PushHistoryCell
        let a = tempArray?[indexPath.section].getNotificationsEntity[indexPath.row]
        
        guard tempArray?[indexPath.section].getNotificationsEntity[indexPath.row] != nil else { return PushHistoryCell()}
        if tempArray?[indexPath.section].getNotificationsEntity.count != 0 {
        cell.setData(a)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        view.backgroundColor = .white
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 15, height: 40))
        lbl.font = UIFont.systemFont(ofSize: 15)
        lbl.text = dateFormater(tempArray?[section].date ?? "", "dd MMMM, E")
        view.addSubview(lbl)
        return view
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == tableView.numberOfSections - 1 {
            print("Последняя секция в истории пушей 🏁")
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                self.offsetNumber += 15
                self.downloadPushArray()
                print("Последняя ячейка в истории пушей 🚩")
            }
        }
        
    }
    
    
    func dateFormater(_ string: String, _ formatter: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let date = dateFormatter.date(from: string)!
        
        let d = DateFormatter()
        d.locale = Locale(identifier: "ru_RU")
        d.dateFormat = formatter
        
        let stringDate = d.string(from: date)
        return stringDate
    }
    
    func observerRealm() {
        self.token = self.tempArray?.observe { [weak self] ( changes: RealmCollectionChange) in
            guard (self?.tableView) != nil else {return}
            switch changes {
            case .initial:
                self?.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self?.tableView.beginUpdates()
                self?.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self?.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self?.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self?.tableView.endUpdates()
            case .error(let error):
                fatalError("\(error)")
            }
        }
        
    }
    
    /// Очищаем в REALM
    final func clearPushRealmData() {
        
        let realm = try? Realm()
        do {
//            let b = realm?.objects(GetNotificationsEntitytModel.self)
            let a = realm?.objects(GetNotificationsCellModel.self)
            let c = realm?.objects(GetNotificationsModel.self)
            realm?.beginWrite()
//            realm?.delete(b!)
            realm?.delete(a!)
            realm?.delete(c!)
            try realm?.commitWrite()
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
