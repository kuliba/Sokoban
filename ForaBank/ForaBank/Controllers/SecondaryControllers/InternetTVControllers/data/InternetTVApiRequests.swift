import Foundation


struct InternetTVApiRequests {
    static var isSingleService = true

    static func isSingleService(puref: String) {
        let body = ["puref" : puref] as [String: AnyObject]
        NetworkManager<IsSingleServiceModel>.addRequest(.isSingleService, [:], body) { model, error in
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let model = model else { return }
                guard let data = model.data else { return }
                isSingleService = data
                InternetTVDetailsFormController.iMsg?.handleMsg(what: InternetTVDetailsFormController.msgIsSingleService)
            }
        }
    }

}
