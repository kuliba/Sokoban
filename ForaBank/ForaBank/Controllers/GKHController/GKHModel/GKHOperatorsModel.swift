//
//  GKHOperatorsModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.08.2021.
//

import Foundation
import RealmSwift

// MARK: - GKHOperatorsModel
class GKHOperatorsModel: Object {

    @objc dynamic var code: String?
    @objc dynamic var isGroup = false
    @objc dynamic var name: String?
    @objc dynamic var region: String?
    
    var logotypeList = List<LogotypeData>()
    let synonymList = List<String>()
    let parameterList = List<Parameters>()
    
}

// MARK: - LogotypeData
class LogotypeData: Object {
    @objc dynamic var content: String?
    @objc dynamic var name: String?
}

// MARK: - ParameterList
class Parameters: Object {

    @objc dynamic var id: String?
    @objc dynamic var order = 0
    @objc dynamic var title: String?
    @objc dynamic var subTitle: String?
    @objc dynamic var viewType: String?
    @objc dynamic var dataType: String?
    @objc dynamic var type: String?
    @objc dynamic var mask: String?
    @objc dynamic var regExp: String?
    @objc dynamic var maxLength = 0
    @objc dynamic var minLength = 0
    @objc dynamic var rawLength = 0
    
}

// MARK: - Save REALM
struct AddOperatorsList {
    
    static func add() {
        
        /// Общая информация об поставщике услуг
        var operatorsArray = [GKHOperatorsModel]()
        var tempOperators = GKHOperatorsModel()
        var tempOperatorsArray = [GKHOperatorsModel]()
    
        /// Логотип и название поставщике услуг
        var listPositionArray = [LogotypeData]()
        /// Поля для заполнения
        var synonymListArray = [String]()
        var parametersArray = [Parameters]()
        
        NetworkManager<GetAnywayOperatorsListDecodableModel>.addRequest(.getAnywayOperatorsList, [:], [:]) { model, error in
            
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let model = model else { return }
                guard let lastPaymentsList = model.data else { return }
    
                lastPaymentsList.forEach { d in
                    if d.name == "Коммунальные услуги и ЖКХ" {
                        d.operators?.forEach({ operators in
                            /// Общая информация об поставщике услуг
                            let a = GKHOperatorsModel()
                            a.code = operators.code
                            a.isGroup = operators.isGroup ?? false
                            a.name = operators.name
                            a.region = operators.region
                            /// Логотип и название поставщике услуг
                            operators.logotypeList?.forEach({ logotypeList in
                                let l = LogotypeData()
                                l.content = logotypeList.content
                                l.name = logotypeList.name
                                listPositionArray.append(l)
                            })
                            /// ИНН
                            operators.synonymList?.forEach({ synonym in
                                synonymListArray.append(synonym)
                            })
                            /// Поля для заполнения
                            operators.parameterList?.forEach({ parameterList in
                                let p = Parameters()
                                p.id        = parameterList.id
                                p.order     = parameterList.order ?? 0
                                p.title     = parameterList.title
                                p.subTitle  = parameterList.subTitle
                                p.viewType  = parameterList.viewType?.rawValue
                                p.dataType  = parameterList.dataType?.rawValue
                                p.type      = parameterList.type?.rawValue
                                p.mask      = parameterList.mask
                                p.regExp    = parameterList.regExp
                                p.maxLength = parameterList.maxLength ?? 0
                                p.minLength = parameterList.minLength ?? 0
                                p.rawLength = parameterList.rawLength ?? 0
                                parametersArray.append(p)
                            })
                            tempOperators = a
                            listPositionArray.forEach { i in
                                tempOperators.logotypeList.append(i)
                            }
                            synonymListArray.forEach { i in
                                tempOperators.synonymList.append(i)
                            }
                            parametersArray.forEach { i in
                                tempOperators.parameterList.append(i)
                            }
                            tempOperatorsArray.append(tempOperators)
                            listPositionArray.removeAll()
                            synonymListArray.removeAll()
                            parametersArray.removeAll()
                        })
                        operatorsArray = tempOperatorsArray
                        /// Сохраняем в REALM
                        let realm = try? Realm()
                        do {
                            let operators = realm?.objects(GKHOperatorsModel.self)
                            guard (operators != nil) else { return }
                            realm?.beginWrite()
                            realm?.delete(operators!)
                            realm?.add(operatorsArray)
                            try realm?.commitWrite()
                            print("REALM",realm?.configuration.fileURL?.absoluteString ?? "")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
}
