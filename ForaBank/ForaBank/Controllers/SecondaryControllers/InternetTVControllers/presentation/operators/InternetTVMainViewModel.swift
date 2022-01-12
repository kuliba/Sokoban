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
        if InternetTVMainViewModel.filter == GlobalModule.UTILITIES_CODE {
            AddHistoryList.add()
        }
        if InternetTVMainViewModel.filter == GlobalModule.INTERNET_TV_CODE {
            InternetTVLatestOperationRealm.load()
        }
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
}
