import Foundation
import RealmSwift

class InternetTVMainViewModel {

    public static var latestOp: InternetLatestOpsDO? = nil
    public static var filter = GlobalModule.INTERNET_TV_CODE

    var controller: InternetTVMainController? = nil
    var qrData = [String: String]()
    var operatorFromQR: GKHOperatorsModel? = nil
    var arrOrganizations = [GKHOperatorsModel]()
    var arrSearchedOrganizations = [GKHOperatorsModel]() {
        didSet {
            arrSearchedOrganizations.forEach {op in
                getCustomOrgs(op: op)
            }
            DispatchQueue.main.async {
                self.controller?.tableView?.reloadData()
            }
        }
    }
    var customGroups = [CustomGroup(name: "Автодор", puref: "avtodor", childPurefs: "iFora||AVDТ;iFora||AVDD")]
    var arrCustomOrg = [CustomGroup]()
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
            print("op5555  \(op.parentCode) + \(op.name)")
            if !op.parameterList.isEmpty && op.parentCode?.contains(InternetTVMainViewModel.filter) ?? false {
                getCustomOrgs(op: op)
                arrOrganizations.append(op)
            }
        })
        arrCustomOrg.append(contentsOf: customGroups)
        arrCustomOrg.sort {
            $0.name ?? "" < $1.name ?? ""
        }
        controller?.tableView.reloadData()
    }
    
    func getCustomOrgs(op:GKHOperatorsModel) {
        var isFound = false
        var counter = 0
        for i in customGroups.indices {
            if customGroups[i].childPurefs.contains(op.puref ?? "-1") == true {
                customGroups[i].childsOperators.append(op)
                isFound = true
            }
            counter += 1
        }
        if !isFound {
            var item = CustomGroup(name: op.name ?? "-1", puref: "",childPurefs: "")
            item.op = op
            arrCustomOrg.append(item)
        }
    }
}

struct CustomGroup {
    var name = "Group"
    var isShown = false
    var puref = ""
    var childPurefs = ""
    var op: GKHOperatorsModel? = nil
    var childsOperators = [GKHOperatorsModel]()

    init (name:String, puref: String, childPurefs: String) {
        self.name = name
        self.puref = puref
        self.childPurefs = childPurefs
    }
}
