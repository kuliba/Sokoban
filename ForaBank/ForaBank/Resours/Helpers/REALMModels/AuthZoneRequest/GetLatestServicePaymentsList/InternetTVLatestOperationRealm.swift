import Foundation
import RealmSwift


struct InternetTVLatestOperationRealm {
    
    static func load() {
        var latestOperations = [InternetTVLatestOperationsModel]()
        NetworkManager<GetLatestServicePaymentsDecodableModel>.addRequest(.getLatestInternetTVPayments, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let model = model else { return }
                guard let additionalListData = model.data else { return }
                
                additionalListData.forEach { list in
                    let ob = InternetTVLatestOperationsModel()
                    ob.amount    = list.amount ?? 0
                    ob.paymentDate = list.paymentDate
                    ob.puref    = list.puref

                    list.additionalList?.forEach({ parameterList in
                        let param = AdditionalListModel()
                        param.fieldName       = parameterList.fieldName
                        param.fieldValue     = parameterList.fieldValue
                        ob.additionalList.append(param)
                    })

                    latestOperations.append(ob)
                }

                let realm = try? Realm()
                do {
                    let operators = realm?.objects(InternetTVLatestOperationsModel.self)
                    realm?.beginWrite()
                    realm?.delete(operators!)
                    realm?.add(latestOperations)
                    try realm?.commitWrite()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }

        var latestOperationsTransport = [InternetTVLatestOperationsTransport]()
        NetworkManager<GetLatestServicePaymentsDecodableModel>.addRequest(.getLatestInternetTVPaymentsTransport, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let model = model else { return }
                guard let additionalListData = model.data else { return }

                additionalListData.forEach { list in
                    let ob = InternetTVLatestOperationsTransport()
                    ob.amount    = list.amount ?? 0
                    ob.paymentDate = list.paymentDate
                    ob.puref    = list.puref

                    list.additionalList?.forEach({ parameterList in
                        let param = AdditionalListModel()
                        param.fieldName       = parameterList.fieldName
                        param.fieldValue     = parameterList.fieldValue
                        ob.additionalList.append(param)
                    })

                    latestOperationsTransport.append(ob)
                }

                let realm = try? Realm()
                do {
                    let operators = realm?.objects(InternetTVLatestOperationsTransport.self)
                    realm?.beginWrite()
                    realm?.delete(operators!)
                    realm?.add(latestOperationsTransport)
                    try realm?.commitWrite()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}


