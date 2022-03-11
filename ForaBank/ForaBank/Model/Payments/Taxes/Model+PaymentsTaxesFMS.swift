//
//  Model+PaymentsTaxes.swift
//  ForaBank
//
//  Created by Max Gribov on 09.02.2022.
//

import Foundation

extension Model {
    
    func parametersFMS(_ parameters: [ParameterRepresentable], _ step: Int, _ completion: @escaping (Result<[ParameterRepresentable], Error>) -> Void) {
        
        switch step {
        case 0:
   
            // operator
            let operatorParameter = Payments.ParameterOperator(operatorType: .fms)
            
            // category
            let categoryParameter = Payments.ParameterSelect(
                Parameter(id: "a3_dutyCategory_1_1", value: nil),
                title: "Категория платежа",
                options: [
                    .init(id: "1", name: "Российский паспорт", icon: .parameterSample),
                    .init(id: "2", name: "Виза", icon: .parameterSample),
                    .init(id: "3", name: "Загран паспорт", icon: .parameterSample),
                    .init(id: "4", name: "Разрешения", icon: .parameterSample),
                    .init(id: "5", name: "Бюджет (поступления/возврат)", icon: .parameterSample),
                    .init(id: "6", name: "Штрафы", icon: .parameterSample)])
            
            completion(.success( parameters + [operatorParameter, categoryParameter]))
            
        case 1:
 
            // division
            let divisionParameter = Payments.ParameterSelectSimple(
                Parameter(id: "a3_divisionSelect_2_1", value: nil),
                icon: .parameterSample,
                title: "Данные о подразделении ФНС",
                selectionTitle: "Выберете услугу",
                options: [
                    .init(id: "inn_oktmo", name: "ИНН и ОКТМО подразделения"),
                    .init(id: "number", name: "Номер подразделения")])
            
            completion(.success( parameters + [divisionParameter]))
            
        case 2:
            
            //  service
            let serviceParameter = Payments.ParameterSelectSimple(
                Parameter(id: "a3_categorySelect_3_1", value: nil),
                icon: .parameterSample,
                title: "Тип услуги",
                selectionTitle: "Выберете услугу",
                description: "Государственная пошлина за выдачу паспорта удостоверяющего личность гражданина РФ за пределами территории РФ гражданину РФ",
                options: [
                    .init(id: "1", name: "В возрасте от 14 лет"),
                    .init(id: "2", name: "В возрасте до 14 лет"),
                    .init(id: "1", name: "В возрасте до 14 лет (новый образец)")])
            
            completion(.success( parameters + [serviceParameter]))
            
        case 3:
                      
            // division INN
            let divisionInnParameter = Payments.ParameterInput(Parameter(id: "a3_INN_4_1", value: nil), icon: .parameterSample, title: "ИНН подразделения", validator: .init(minLength: 8, maxLength: 8, regEx: nil))
            
            // division OKTMO
            let divisionOktmoParameter = Payments.ParameterInput(Parameter(id: "a3_OKTMO_5_1", value: nil), icon: .parameterSample, title: "ОКТМО подзаделения", validator: .init(minLength: 6, maxLength: 6, regEx: nil))
            
            completion(.success( parameters + [divisionInnParameter, divisionOktmoParameter]))
            
        default:
            completion(.failure(Payments.Error.unsupported))
        }
    }
    
}
