//
//  Model+PaymentsTaxes.swift
//  ForaBank
//
//  Created by Max Gribov on 09.02.2022.
//

import Foundation

extension Model {
    
    func parametersFMS(_ parameters: [Model.Parameter], _ step: Int, _ completion: @escaping (Result<[Model.Parameter], Error>) -> Void) {
        
        let paramOperator = Payments.Parameter.Identifier.operator.rawValue
        let paramCategory = "a3_dutyCategory_1_1"
        let paramDivision = "a3_divisionSelect_2_1"
        let paramService = "a3_categorySelect_3_1"
        let paramDivisionINN = "a3_INN_4_1"
        let paramDivisionOKTMO = "a3_OKTMO_5_1"
        
        switch step {
        case 0:
   
            // operator
            let operatorValue = Parameter.Result(id: paramOperator, value: Operator.fms.rawValue)
            let operatorParameter = Parameter(value: operatorValue)
            
            // category
            let categoryValue = Parameter.Result(id: paramCategory, value: nil)
            let categoryParameter = Payments.ParameterSelect(value: categoryValue, title: "Категория платежа", options: [.init(id: "1", name: "Российский паспорт", icon: .parameterSample), .init(id: "2", name: "Виза", icon: .parameterSample), .init(id: "3", name: "Загран паспорт", icon: .parameterSample), .init(id: "4", name: "Разрешения", icon: .parameterSample), .init(id: "5", name: "Бюджет (поступления/возврат)", icon: .parameterSample), .init(id: "6", name: "Штрафы", icon: .parameterSample)])
            
            completion(.success( parameters + [operatorParameter, categoryParameter]))
            
        case 1:
 
            // division
            let divisionValue = Parameter.Result(id: paramDivision, value: "inn_oktmo")
            let divisionParameter = Payments.ParameterSelectSimple(value: divisionValue, icon: .parameterSample, title: "Данные о подразделении ФНС", selectionTitle: "Выберете услугу", options: [.init(id: "inn_oktmo", name: "ИНН и ОКТМО подразделения"), .init(id: "number", name: "Номер подразделения")])
            
            completion(.success( parameters + [divisionParameter]))
            
        case 2:
            
            //  service
            let serviceValue = Parameter.Result(id: paramService, value: nil)
            let serviceParameter = Payments.ParameterSelectSimple(value: serviceValue, icon: .parameterSample, title: "Тип услуги", selectionTitle: "Выберете услугу", description: "Государственная пошлина за выдачу паспорта удостоверяющего личность гражданина РФ за пределами территории РФ гражданину РФ", options: [.init(id: "1", name: "В возрасте от 14 лет"), .init(id: "2", name: "В возрасте до 14 лет"), .init(id: "1", name: "В возрасте до 14 лет (новый образец)")])
           
            completion(.success( parameters + [serviceParameter]))
            
        case 3:
                      
            // division INN
            let divisionInnValue = Parameter.Result(id: paramDivisionINN, value: nil)
            let divisionInnParameter = Payments.ParameterInput(value: divisionInnValue, icon: .parameterSample, title: "ИНН подразделения", validator: .init(minLength: 8, maxLength: 8, regEx: nil))
            
            // division OKTMO
            let divisionOktmoValue = Parameter.Result(id: paramDivisionOKTMO, value: nil)
            let divisionOktmoParameter = Payments.ParameterInput(value: divisionOktmoValue, icon: .parameterSample, title: "ОКТМО подзаделения", validator: .init(minLength: 6, maxLength: 6, regEx: nil))
            
            completion(.success( parameters + [divisionInnParameter, divisionOktmoParameter]))
            
        default:
            completion(.failure(Payments.Error.unsupported))
        }
    }
}
