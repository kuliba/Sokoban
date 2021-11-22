//
//  GKHAddOperatorsList.swift
//  ForaBank
//
//  Created by Константин Савялов on 30.08.2021.
//

import Foundation
import RealmSwift

// MARK: - Save REALM
struct AddOperatorsList: DownloadQueueProtocol {

    func add(_ param: [String : String], _ body: [String: AnyObject], completion: @escaping () -> ()) {

        /// Общая информация об поставщике услуг
        var operatorsArr = [GKHOperatorsModel]()

        /// Логотип и название поставщике услуг
        var listPositionArray = [LogotypeData]()

        /// Поля для заполнения
        var synonymListArray  = [String]()
        var parametersArray   = [Parameters]()

        NetworkManager<GetAnywayOperatorsListDecodableModel>.addRequest(.getAnywayOperatorsList, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let model = model else { return }
                guard let allOperators = model.data?.operatorGroupList else { return }

                allOperators.forEach { item in
                    if item.code?.contains(GlobalModule.UTILITIES_CODE) ?? false ||
                               item.code?.contains(GlobalModule.INTERNET_TV_CODE) ?? false {
                        item.operators?.forEach({ item in
                            /// Общая информация об поставщике услуг
                            let ob = GKHOperatorsModel()
                            ob.puref   = item.code
                            ob.isGroup = item.isGroup ?? false
                            ob.name    = item.name
                            ob.region  = item.region
                            ob.parentCode = item.parentCode
                            /// Логотип и название поставщике услуг
                            item.logotypeList?.forEach({ logotypeList in
                                let l     = LogotypeData()
                                l.content = logotypeList.content
                                l.name    = logotypeList.name
                                l.code    = item.code
                                listPositionArray.append(l)
                            })
                            /// ИНН
                            item.synonymList?.forEach({ synonym in
                                synonymListArray.append(synonym)
                            })
                            /// Поля для заполнения
                            item.parameterList?.forEach({ parameterList in
                                if parameterList.viewType == "INPUT" {
                                let param = Parameters()
                                param.id        = parameterList.id
                                param.order     = parameterList.order ?? 0
                                param.title     = parameterList.title
                                param.subTitle  = parameterList.subTitle
                                param.viewType  = parameterList.viewType
                                param.dataType  = parameterList.dataType
                                param.type      = parameterList.type
                                param.mask      = parameterList.mask
                                param.regExp    = parameterList.regExp
                                param.maxLength = parameterList.maxLength ?? 0
                                param.minLength = parameterList.minLength ?? 0
                                param.rawLength = parameterList.rawLength ?? 0

                                parametersArray.append(param)
                                }
                            })
                            listPositionArray.forEach { i in
                                ob.logotypeList.append(i)
                            }
                            synonymListArray.forEach { i in
                                ob.synonymList.append(i)
                            }
                            parametersArray.forEach { i in
                                ob.parameterList.append(i)
                            }
                            ob.parameterList.sort(by: { (l, r) -> Bool in
                                return l.order < r.order
                            })

                            operatorsArr.append(ob)

                            listPositionArray.removeAll()
                            synonymListArray.removeAll()
                            parametersArray.removeAll()
                        })
                    }
                }

                let realm = try? Realm()
                do {
                    let operators = realm?.objects(GKHOperatorsModel.self)
//                            guard (operators != nil) else { return }
                    realm?.beginWrite()
                    realm?.delete(operators!)
                    realm?.add(operatorsArr)
                    try realm?.commitWrite()
                    completion()
                    print("REALM",realm?.configuration.fileURL?.absoluteString ?? "")
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
