import Foundation

class InternetTVMainViewModel {

    public static var latestOp: InternetLatestOpsDO? = nil
    public static var filter = GlobalModule.INTERNET_TV_CODE

    var controller: InternetTVMainController? = nil
    var qrData = [String: String]()
    var operatorFromQR: GKHOperatorsModel? = nil
    var arrOrganizations = [GKHOperatorsModel]()
    var arrSearchedOrganizations = [GKHOperatorsModel]() {
        didSet {
            arrCustomOrg.removeAll()
            arrSearchedOrganizations.forEach {op in
                getCustomOrgs(op: op)
            }
            DispatchQueue.main.async {
                self.controller?.tableView?.reloadData()
            }
        }
    }
    var customGroups = [CustomGroup(name: "Автодор", puref: "avtodor", childPurefs: "iFora||AVDТ;iFora||AVDD", parentCode: "iFora||1051062")]
    var arrCustomOrg = [CustomGroup]()


    init() {
        if InternetTVMainViewModel.filter == GlobalModule.UTILITIES_CODE {
            AddHistoryList.add()
        }
        if InternetTVMainViewModel.filter == GlobalModule.INTERNET_TV_CODE || InternetTVMainViewModel.filter == GlobalModule.PAYMENT_TRANSPORT  {
            InternetTVLatestOperationRealm.load()
        }
     
        let operatorsList = (Model.shared.dictionaryAnywayOperatorGroups()?.compactMap { $0.returnOperators() }) ?? []
        
        let operatorCodes = [GlobalModule.UTILITIES_CODE, GlobalModule.INTERNET_TV_CODE, GlobalModule.PAYMENT_TRANSPORT]
        let parameterTypes = ["INPUT"]
        let gkhOperators = GKHOperatorsModel.childOperators(with: operatorsList, operatorCodes: operatorCodes, parameterTypes: parameterTypes)

        gkhOperators.forEach({ op in
            if !op.parameterList.isEmpty && op.parentCode?.contains(InternetTVMainViewModel.filter) ?? false {
                getCustomOrgs(op: op)
                arrOrganizations.append(op)
            }
        })
        customGroups.forEach { group in
            if group.parentCode.contains(InternetTVMainViewModel.filter) {
                arrCustomOrg.append(group)
            }
        }
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
            var item = CustomGroup(name: op.name ?? "-1", puref: "",childPurefs: "", parentCode: op.parentCode ?? "")
            item.op = op
            arrCustomOrg.append(item)
        }
    }
}

struct CustomGroup {
    var name = "Group"
    var parentCode = ""
    var isShown = false
    var puref = ""
    var childPurefs = ""
    var op: GKHOperatorsModel? = nil
    var childsOperators = [GKHOperatorsModel]()

    init (name:String, puref: String, childPurefs: String, parentCode: String) {
        self.name = name
        self.puref = puref
        self.childPurefs = childPurefs
        self.parentCode = parentCode
    }
}
