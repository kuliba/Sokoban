//
//  InternetTVMainViewModel.swift
//  ForaBank
//
//  Created by Роман Воробьев on 04.12.2021.
//

import Foundation
import RealmSwift

class InternetTVMainViewModel {

    public static var latestOp: InternetLatestOpsDO? = nil
    public static var filter = GlobalModule.INTERNET_TV_CODE

    var controller: InternetTVMainController? = nil
    var qrData = [String: String]()
    var operators: GKHOperatorsModel? = nil
    var organization = [GKHOperatorsModel]()
    var searchedOrganization = [GKHOperatorsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.controller?.tableView?.reloadData()
            }
        }
    }
    var operatorsList: Results<GKHOperatorsModel>? = nil
    lazy var realm = try? Realm()

    init() {
        InternetTVLatestOperationRealm.load()

        //observerRealm()
        operatorsList = realm?.objects(GKHOperatorsModel.self)
        operatorsList?.forEach({ op in
            if !op.parameterList.isEmpty && op.parentCode?.contains(InternetTVMainViewModel.filter) ?? false {
                organization.append(op)
            }
        })
        organization.sort {
            $0.name ?? "" < $1.name ?? ""
        }
        controller?.tableView.reloadData()
    }

    //func observerRealm() {
        //operatorsList = realm?.objects(GKHOperatorsModel.self)
//        self.token = self.operatorsList?.observe { [weak self] (changes: RealmCollectionChange) in
//            guard (self?.tableView) != nil else {
//                return
//            }
//            switch changes {
//            case .initial:
//                self?.tableView.reloadData()
//            case .update(_, let deletions, let insertions, let modifications):
//                self?.tableView.beginUpdates()
//                self?.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
//                self?.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
//                self?.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
//                self?.tableView.endUpdates()
//            case .error(let error):
//                fatalError("\(error)")
//            }
//        }
    //}
}