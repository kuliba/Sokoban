//
//  Model+PaymentsTaxes.swift
//  ForaBank
//
//  Created by Max Gribov on 09.02.2022.
//

import Foundation

extension Model {
    
    func parametersFMS(_ parameters: [Model.Parameter], _ step: Int, _ completion: @escaping (Result<[Model.Parameter], Error>) -> Void) {
        
        let paramOperator = Parameter.ID.operator.rawValue
        let paramCategory = "a3_dutyCategory_1_1"
        let paramDivision = "a3_divisionSelect_2_1"
        let paramService = "a3_categorySelect_3_1"
        let paramDivisionINN = "a3_INN_4_1"
        let paramDivisionOKTMO = "a3_OKTMO_5_1"
        
        switch step {
        case 0:
   
            // operator
            let operatorValue = Parameter.Value(id: paramOperator, value: Operator.fms.rawValue)
            let operatorParameter = Parameter(value: operatorValue, type: .hidden)
            
            // category
            let categoryValue = Parameter.Value(id: paramCategory, value: "")
            let categoryParameter = Parameter(value: categoryValue, type: .select([.init(id: "1", name: "Российский паспорт", icon: .parameterSample), .init(id: "2", name: "Виза", icon: .parameterSample), .init(id: "3", name: "Загран паспорт", icon: .parameterSample)], icon: .parameterSample, title: "Категория платежа"))
            
            completion(.success( parameters + [operatorParameter, categoryParameter]))
            
        case 1:
 
            // division
            let divisionValue = Parameter.Value(id: paramDivision, value: "inn_oktmo")
            let divisionParameter = Parameter(value: divisionValue, type: .selectSimple([.init(id: "inn_oktmo", name: "ИНН и ОКТМО подразделения"), .init(id: "number", name: "Номер подразделения")], icon: .parameterSample, title: "Данные о подразделении ФНС", selectionTitle: "Выберете услугу", description: nil))
            
            completion(.success(parameters + [divisionParameter]))
            
        case 2:
            
            //  service
            let serviceValue = Parameter.Value(id: paramService, value: "")
            let serviceParameter = Parameter(value: serviceValue, type: .selectSimple([.init(id: "1", name: "В возрасте от 14 лет"), .init(id: "2", name: "В возрасте до 14 лет"), .init(id: "1", name: "В возрасте до 14 лет (новый образец)")], icon: .parameterSample, title: "Тип услуги", selectionTitle: "Выберете услугу", description: "Государственная пошлина за выдачу паспорта удостоверяющего личность гражданина РФ за пределами территории РФ гражданину РФ"))
            
            completion(.success( parameters + [serviceParameter]))
            
        case 3:
                      
            // division INN
            let divisionInnValue = Parameter.Value(id: paramDivisionINN, value: "")
            let divisionInnParameter = Parameter(value: divisionInnValue, type: .input(icon: .parameterSample, title: "ИНН подразделения", validator: .init(minLength: 8, maxLength: 8, regEx: nil)))
            
            // division OKTMO
            let divisionOktmoValue = Parameter.Value(id: paramDivisionOKTMO, value: "")
            let divisionOktmoParameter = Parameter(value: divisionOktmoValue, type: .input(icon: .parameterSample, title: "ОКТМО подзаделения", validator: .init(minLength: 6, maxLength: 6, regEx: nil)))
            
            completion(.success( parameters + [divisionInnParameter, divisionOktmoParameter]))
            
        default:
            completion(.failure(Payments.Error.unsupported))
        }
    }
}
