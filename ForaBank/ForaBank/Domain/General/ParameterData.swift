//
//  ParameterData.swift
//  ForaBank
//
//  Created by Дмитрий on 03.02.2022.
//

import Foundation

struct ParameterData: Codable, Equatable, Identifiable {
    
    let content: String?
    let dataType: String?
    let id: String
    let isPrint: Bool?
    let isRequired: Bool?
    let mask: String?
    let maxLength: Int?
    let minLength: Int?
    let order: Int?
    let rawLength: Int
    let readOnly: Bool?
    let regExp: String?
    let subTitle: String?
    let title: String
    let type: String?
    let inputFieldType: inputFieldType?
    let dataDictionary: String?
    let dataDictionaryРarent: String?
    let group: String?
    let subGroup: String?
    let inputMask: String?
    let phoneBook: Bool?
    let svgImage: SVGImageData?
    let viewType: ViewType
    
    enum ViewType: String, Codable, Equatable, Unknownable {
        
        case constant = "CONSTANT"
        case input = "INPUT"
        case output = "OUTPUT"
        case unknown
    }
    
    enum inputFieldType: String, Codable, Equatable, Unknownable {
        case address = "ADDRESS"
        case bic = "BIC"
        case account = "ACCOUNT"
        case purpose = "PURPOSE"
        case phone = "PHONE"
        case date = "DATE"
        case insurance = "INSURANCE"
        case penalty = "PENALTY"
        case counter = "COUNTER"
        case view = "VIEW"
        case name = "NAME"
        case inn = "INN"
        case oktmo = "OKTMO"
        case recipient = "RECIPIENT"
        case amount = "AMOUNT"
        case bank = "BANK"
        case unknown
    }
}

extension ParameterData {
    
    var value: String? { content }
    
    var view: Payments.Parameter.View {
        
        switch type?.lowercased() {
        case "select": return .select
        case "masklist": return .selectSwitch
        case "input", "string", "int": return .input
        default: return .info
        }
    }
    
    enum OptionsStyle {
        
        //"=,inn_oktmo=ИНН и ОКТМО подразделения,number=Номер подразделения"
        case general
        
        //"=:1=оплата за жилищно-коммунальные услуги:2=оплата за электроэнергию:3=оплата за технический надзор"
        case extended

        //"=;RUB=USD,EUR; USD=RUB,EUR"
        case currency
    }
    
    enum ParameterType: String {
        
        case personalAccount = "a3_PERSONAL_ACCOUNT_1_1"
        case account = "account"
        case code = "a3_CODE_3_1"
    }
    
    var parameterType: ParameterType? {
        
        return ParameterType(rawValue: id)
    }
    
    func options(style: OptionsStyle) -> [Option]? {

        guard let data = dataType else {
            return nil
        }

        var options = [Option]()

        switch style {
        case .general:

            let dataSplitted = data.split(separator: ",")

            for chunk in dataSplitted {

                let chunkSplitted = chunk.split(separator: "=")

                guard chunkSplitted.count == 2, chunkSplitted[0] != "", chunkSplitted[1] != "" else {
                    continue
                }

                let id = String(chunkSplitted[0])
                let name = String(chunkSplitted[1])
                let option = Option(id: id, name: name)

                options.append(option)
            }

        case .extended:

            let dataSplitted = data.split(separator: ":")

            for chunk in dataSplitted {

                let chunkSplitted = chunk.split(separator: "=")

                guard chunkSplitted.count == 2, chunkSplitted[0] != "", chunkSplitted[1] != "" else {
                    continue
                }

                let id = String(chunkSplitted[0])
                let name = String(chunkSplitted[1])
                let option = Option(id: id, name: name)

                options.append(option)
            }

        case .currency:
            let dataSplitted = data.split(separator: ";")

            for chunk in dataSplitted {

                let chunkSplitted = chunk.split(separator: "=")

                guard chunkSplitted.count == 2, chunkSplitted[0] != "", chunkSplitted[1] != "" else {
                    continue
                }

                let name = String(chunkSplitted[0]).replacingOccurrences(of: " ", with: "")

                let option = name.split(separator: ",").map({Option(id: $0.description, name: $0.description)})
                options += option
            }
        }

        guard options.isEmpty == false else {
            return nil
        }

        return options
    }
    
    var switchOptions: [Payments.ParameterSelectSwitch.Option]? {
        
        //TODO: implementation required
        return nil
    }
    
    var iconData: ImageData? {
        
        guard let svgImage = svgImage else {
            return nil
        }
        
        return ImageData(with: svgImage)
    }
}

//MARK: - Validator

extension ParameterData {
    
    var validator: Payments.Validation.RulesSystem {
        
        var rules = [any PaymentsValidationRulesSystemRule]()
        
        if let minLength = minLength {
            
            rules.append(Payments.Validation.MinLengthRule(minLenght: UInt(minLength), actions: [.post: .warning("Минимальная длинна должна быть \(minLength) символов.")]))
        }
        
        if let maxLength = maxLength {
            
            rules.append(Payments.Validation.MaxLengthRule(maxLenght: UInt(maxLength), actions: [.post: .warning("Максимальная длинна должна не превышать \(maxLength) символов.")]))
        }
        
        if let regExp = regExp {
            
            rules.append(Payments.Validation.RegExpRule(regExp: regExp, actions: [.post: .warning("Введено некорректное значение")]))
        }
        
        return .init(rules: rules)
    }
}

extension ParameterData: CustomDebugStringConvertible {
    
    var debugDescription: String {
        
        "id: \(id) value: \(value ?? "empty") title: \(title) data: \(dataType ?? "empty") type: \(type)"
    }
}
