import Foundation


struct InternetTVApiRequests {
    static var isSingleService = true
    static var userInfo:ClintInfoModelData? = nil

    static func isSingleService(puref: String, completion: @escaping () -> Void) {
        let body = ["puref" : puref] as [String: AnyObject]
        NetworkManager<IsSingleServiceModel>.addRequest(.isSingleService, [:], body) { model, error in
            if error != nil {
                
            } else {
                guard let model = model else { return }
                guard let data = model.data else { return }
                isSingleService = data
                completion()
            }
        }
    }

    static func getMosParkingList() {
        NetworkManager<MosParkingListModel>.addRequest(.getMosParkingList, [:], [:]) { model, error in
            if error != nil {
                
            } else {
                guard let model = model else { return }
                guard let data = model.data else { return }
                MosParkingViewController.mosParkingList = data
                MosParkingViewController.iMsg?.handleMsg(what: -1)
            }
        }
    }

    static func getClientInfo() {
        NetworkManager<ClintInfoModel>.addRequest(.getClientInfo, [:], [:]) { model, error in
            if error != nil {
                
            } else {
                guard let model = model else { return }
                guard let data = model.data else { return }
                InternetTVApiRequests.userInfo = data
            }
        }
    }

    static func createAnywayTransfer(request: [String: AnyObject], completion: @escaping (CreateTransferAnswerModel?, String?) -> ()) {
        NetworkManager<CreateTransferAnswerModel>.addRequest(.createAnywayTransfer, [:], request) { respModel, error in
            if error != nil {
                completion(nil, error!)
            }
            guard let respModel = respModel else { return }
            if respModel.statusCode == 0 {
                completion(respModel, nil)
            } else {
                completion(nil, respModel.errorMessage)
            }
        }
    }

    static func createAnywayTransferNew(request: [String: AnyObject], completion: @escaping (CreateTransferAnswerModel?, String?) -> ()) {
        NetworkManager<CreateTransferAnswerModel>.addRequest(.createAnywayTransferNew, [:], request) { respModel, error in
            if error != nil {
                completion(nil, error!)
            }
            guard let respModel = respModel else { return }
            if respModel.statusCode == 0 {
                completion(respModel, nil)
            } else {
                completion(nil, respModel.errorMessage)
            }
        }
    }
}
