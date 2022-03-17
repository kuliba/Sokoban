//
//  Model+PaymentsTaxes.swift
//  ForaBank
//
//  Created by Max Gribov on 09.02.2022.
//

import Foundation

extension Model {
    
    func parametersFMS(_ parameters: [ParameterRepresentable], _ step: Int, _ completion: @escaping (Result<[ParameterRepresentable], Error>) -> Void) {
        
        let paramOperator = Payments.Parameter.Identifier.operator.rawValue
        
        switch step {
        case 0:
            
            // operator
            let operatorParameter = Payments.ParameterOperator(operatorType: .fms)
            
            // category
            guard let fmsCategoriesList = dictionaryFMSList()  else {
                completion(.failure(Payments.Error.unableLoadFMSCategoryOptions))
                return
            }
            
            let categoryParameter = Payments.ParameterSelect(
                Parameter(id: "a3_dutyCategory_1_1", value: nil),
                title: "Категория платежа",
                options: fmsCategoriesList.map{ .init(id: $0.value, name: $0.text, icon: ImageData(with: $0.svgImage) ?? .parameterSample)}, affectsHistory: true)
            
            completion(.success( parameters + [operatorParameter, categoryParameter]))
            
        case 1:
            guard let operatorParameter = parameters.first(where: { $0.parameter.id == paramOperator }),
                  let operatorValue = operatorParameter.parameter.value,
                  let anywayOperator = dictionaryAnywayOperator(for: operatorValue) else {
                      
                      completion(.failure(Payments.Error.missingOperatorParameter))
                      return
                  }
            
            let divisionParameterId = "a3_divisionSelect_2_1"
            guard let divisionAnywayParameter = anywayOperator.parameterList.first(where: { $0.id == divisionParameterId }),
                  let divisionAnywayParameterOptions = divisionAnywayParameter.options,
                  let divisionAnywayParameterValue = divisionAnywayParameter.value else {
                      
                      completion(.failure(Payments.Error.missingParameter))
                      return
                  }
            
            // division
            let divisionParameter = Payments.ParameterSelectSimple(
                Parameter(id: divisionParameterId, value: divisionAnywayParameterValue),
                icon: divisionAnywayParameter.iconData ?? .parameterSample,
                title: divisionAnywayParameter.title,
                selectionTitle: "Выберете услугу",
                options: divisionAnywayParameterOptions,
                affectsHistory: true)
            
            Task {
                do {
                    
                    let transferData = try await startTransfer()
                    print("")
                    
                    completion(.success(parameters + [divisionParameter]))
                    
                } catch {
                    
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
          
        default:
            completion(.failure(Payments.Error.unsupported))
        }
    }
    
    func startTransfer() async throws -> TransferAnywayResponseData {
        
        guard let token = token else {
            throw Payments.Error.unsupported
        }
        
        let command = ServerCommands.TransferController.CreateAnywayTransfer(token: token, isNewPayment: true, payload: .init(amount: 0, check: false, comment: nil, currencyAmount: "RUB", payer: .init(inn: nil, accountId: nil, accountNumber: nil, cardId: 10000200315, cardNumber: nil, phoneNumber: nil), additional: [.init(fieldid: 1, fieldname: "a3_dutyCategory_1_1", fieldvalue: "1"),.init(fieldid: 2, fieldname: "a3_divisionSelect_2_1", fieldvalue: "inn_oktmo")], puref: "iFora||6887"))
        
        return try await withCheckedThrowingContinuation({ continuation in
            
            serverAgent.executeCommand(command: command) { result in
                
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case .ok:
                        guard let transferData = response.data else {
                            continuation.resume(with: .failure(Payments.Error.failedAnywayTransferWithEmptyTransferDataResponse))
                            return
                        }
                        continuation.resume(with: .success(transferData))
                        
                    default:
                        continuation.resume(with: .failure(Payments.Error.failedAnywayTransfer(status: response.statusCode, message: response.errorMessage)))
                    }
                    
                case .failure(let error):
                    continuation.resume(with: .failure(error))
                }
            }
        })
    }
    
    /*
     func getRequestBody(amount: String, additionalArray: [[String: String]]) -> [String: AnyObject] {
         let productType = controller?.footerView.cardFromField.cardModel?.productType ?? ""
         let id = controller?.footerView.cardFromField.cardModel?.id ?? -1

         var request = [String: AnyObject]()
         if productType == "ACCOUNT" {
             request = ["check": false,
                        "amount": amount,
                        "currencyAmount": "RUB",
                        "payer": ["cardId": nil,
                                  "cardNumber": nil,
                                  "accountId": String(id)],
                        "puref": puref,
                        "additional": additionalArray] as [String: AnyObject]

         } else if productType == "CARD" {
             request = ["check": false,
                        "amount": amount,
                        "currencyAmount": "RUB",
                        "payer": ["cardId": String(id),
                                  "cardNumber": nil,
                                  "accountId": nil],
                        "puref": puref,
                        "additional": additionalArray] as [String: AnyObject]
         }
         return request
     }
     */
    
    /*
     func downloadImageAndMetadata(imageNumber: Int) async throws -> DetailedImage {
         return try await withCheckedThrowingContinuation({
             (continuation: CheckedContinuation<DetailedImage, Error>) in
             downloadImageAndMetadata(imageNumber: imageNumber) { image, error in
                 if let image = image {
                     continuation.resume(returning: image)
                 } else {
                     continuation.resume(throwing: error!)
                 }
             }
         })
     }
     */
    
    func parametersFMSMock(_ parameters: [ParameterRepresentable], _ step: Int, _ completion: @escaping (Result<[ParameterRepresentable], Error>) -> Void) {
        
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
                    .init(id: "6", name: "Штрафы", icon: .parameterSample)], affectsHistory: true)
            
            completion(.success( parameters + [operatorParameter, categoryParameter]))
            
        case 1:
            
            if let divisionParameter = parameters.first(where: { $0.parameter.id == "a3_divisionSelect_2_1" }),
                let divisionValue = divisionParameter.parameter.value {
                
                // remove division parameters
                var updatedParameters = [ParameterRepresentable]()
                for parameter in parameters {
                    
                    switch parameter.parameter.id {
                    case "a3_INN_4_1", "a3_OKTMO_5_1", "a3_NUMBER_4_1":
                        continue
                        
                    default:
                        updatedParameters.append( parameter)
                    }
                }
                
                switch divisionValue {
                case "inn_oktmo":
                    let unnParameter = Payments.ParameterInput(
                        .init(id: "a3_INN_4_1", value: nil),
                        icon: .parameterSample,
                        title: "ИНН подразделения",
                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                    
                    let oktmoParameter = Payments.ParameterInput(
                        .init(id: "a3_OKTMO_5_1", value: nil),
                        icon: .parameterSample,
                        title: "ОКТМО подразделения",
                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                    
                    completion(.success(updatedParameters + [unnParameter, oktmoParameter]))
                    
                case "number":
                    
                    let numberParameter = Payments.ParameterInput(
                        .init(id: "a3_NUMBER_4_1", value: nil),
                        icon: .parameterSample,
                        title: "Номер подразделения",
                        validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                    
                    completion(.success(updatedParameters + [numberParameter]))
                    
                default:
                    completion(.failure(Payments.Error.unexpectedOperatorValue))
                }
                
            } else {
                
                // division
                let divisionParameter = Payments.ParameterSelectSimple(
                    Parameter(id: "a3_divisionSelect_2_1", value: "inn_oktmo"),
                    icon: .parameterSample,
                    title: "Данные о подразделении ФНС",
                    selectionTitle: "Выберете услугу",
                    options: [
                        .init(id: "inn_oktmo", name: "ИНН и ОКТМО подразделения"),
                        .init(id: "number", name: "Номер подразделения")],
                    affectsHistory: true)
                
                let unnParameter = Payments.ParameterInput(
                    .init(id: "a3_INN_4_1", value: "7878787878"),
                    icon: .parameterSample,
                    title: "ИНН подразделения",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                
                let oktmoParameter = Payments.ParameterInput(
                    .init(id: "a3_OKTMO_5_1", value: nil),
                    icon: .parameterSample,
                    title: "ОКТМО подразделения",
                    validator: .init(minLength: 1, maxLength: nil, regEx: nil))
                
                completion(.success( parameters + [divisionParameter, unnParameter, oktmoParameter]))
            }
 
        case 2:
            
            var updatedParameters = [ParameterRepresentable]()
            for parameter in parameters {
                
                switch parameter.parameter.id {
                case "a3_INN_4_1", "a3_OKTMO_5_1", "a3_NUMBER_4_1":
                    updatedParameters.append(parameter.updated(editable: false))
                    
                default:
                    updatedParameters.append( parameter)
                }
            }
            
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
                    .init(id: "3", name: "В возрасте до 14 лет (новый образец)"),
                    .init(id: "4", name: "Содержащего электронный носитель информации (паспорта нового поколения)"),
                    .init(id: "4", name: "За внесение изменений в паспорт")], autoContinue: false)
            
            completion(.success( updatedParameters + [serviceParameter]))
            
        case 3:
                      
            let cardParameter = Payments.ParameterCard()
            
            let amountParameter = Payments.ParameterAmount(
                .init(id: Payments.Parameter.Identifier.amount.rawValue, value: "1234"),
                title: "Сумма перевода",
                currency: .init(description: "RUB"),
                validator: .init(minAmount: 10))
            
            completion(.success( parameters + [cardParameter, amountParameter]))
            
        case 4:
            // make all parameters not editable
            var updatedParameters = [ParameterRepresentable]()
            for parameter in parameters {
                
                updatedParameters.append(parameter.updated(editable: false))
            }
            
            let codeParameter = Payments.ParameterInput(
                .init(id: Payments.Parameter.Identifier.code.rawValue, value: nil),
                icon: .parameterSMS,
                title: "Введите код из СМС", validator: .init(minLength: 6, maxLength: 6, regEx: nil))
            
            let finalParameter = Payments.ParameterFinal()
            
            completion(.success(updatedParameters + [codeParameter, finalParameter]))
            
        default:
            completion(.failure(Payments.Error.unsupported))
        }
    }
}
