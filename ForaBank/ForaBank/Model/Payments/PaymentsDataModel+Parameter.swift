//
//  PaymentsDataModel+Parameter.swift
//  ForaBank
//
//  Created by Max Gribov on 10.02.2022.
//

import Foundation

extension Payments.Parameter {
    
    enum Identifier: String {
        
        case category       = "ru.forabank.sense.category"
        case service        = "ru.forabank.sense.service"
        case `operator`     = "ru.forabank.sense.operator"
    }
    
    static let emptyMock = Payments.Parameter(id: UUID().uuidString, value: "")
}

extension Payments {
   
    class ParameterSelectService: Parameter {
        
        let category: Category
        let options: [Option]
        
        internal init(category: Category, options: [Option]) {
            
            self.category = category
            self.options = options
            super.init(id: Payments.Parameter.Identifier.category.rawValue, value: nil)
        }
        
        struct Option: Identifiable {
            
            var id: String { service.rawValue }
            let service: Service
            let title: String
            let description: String
            let icon: ImageData
        }
    }
    
    class ParameterTemplate: Parameter {
        
        let templateId: PaymentTemplateData.ID
        
        internal init(value: Parameter.Result, templateId: PaymentTemplateData.ID) {
            
            self.templateId = templateId
            super.init(id: value.id, value: value.value)
        }
    }
    
    class ParameterSelect: Parameter {
        
        let title: String
        let options: [Option]
        
        internal init(value: Parameter.Result, title: String, options: [Option]) {
            
            self.title = title
            self.options = options
            super.init(id: value.id, value: value.value)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
            let icon: ImageData
        }
    }
    
    class ParameterSelectSimple: Parameter {
        
        let icon: ImageData
        let title: String
        let selectionTitle: String
        let description: String?
        let options: [Option]
        
        internal init(value: Parameter.Result, icon: ImageData, title: String, selectionTitle: String, description: String? = nil, options: [Option]) {
            
            self.icon = icon
            self.title = title
            self.selectionTitle = selectionTitle
            self.description = description
            self.options = options
            super.init(id: value.id, value: value.value)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
        }
    }
    
    class ParameterSelectSwitch: Parameter {
        
        let options: [Option]
        
        internal init(value: Parameter.Result, options: [Option]) {
            
            self.options = options
            super.init(id: value.id, value: value.value)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
        }
    }
    
    class ParameterInput: Parameter {
        
        let icon: ImageData
        let title: String
        let validator: Validator
        
        internal init(value: Parameter.Result, icon: ImageData, title: String, validator: Validator) {
            
            self.icon = icon
            self.title = title
            self.validator = validator
            super.init(id: value.id, value: value.value)
        }
        
        struct Validator: ValidatorProtocol {
            
            let minLength: Int
            let maxLength: Int?
            let regEx: String?
            
            func isValid(value: String) -> Bool {
                
                guard value.count >= minLength else {
                    return false
                }
                
                if let maxLength = maxLength {
                    
                    guard value.count < maxLength else {
                        return false
                    }
                }
                
                //TODO: validate with regex if present
                
                return true
            }
        }
    }
    
    class ParameterInfo: Parameter {
        
        let icon: ImageData
        let title: String
        
        internal init(value: Parameter.Result, icon: ImageData, title: String) {
            
            self.icon = icon
            self.title = title
            super.init(id: value.id, value: value.value)
        }
    }
    
    class ParameterName: Parameter {
        
        let title: String
        let lastName: Name
        let firstName: Name
        let middleName: Name
        
        internal init(value: Parameter.Result, title: String, lastName: Name, firstName: Name, middleName: Name) {
            
            self.title = title
            self.lastName = lastName
            self.firstName = firstName
            self.middleName = middleName
            super.init(id: value.id, value: value.value)
        }
        
        struct Name {
            
            let title: String
            let value: String
        }
    }
    
    class ParameterAmount: Parameter {
        
        let title: String
        let currency: Currency
        let validator: Validator
        var amount: Double {
            //TODO: double from value
            return 0
        }
        
        internal init(value: Parameter.Result, title: String, currency: Currency, validator: Validator) {
            
            self.title = title
            self.currency = currency
            self.validator = validator
            super.init(id: value.id, value: value.value)
        }
        
        struct Validator: ValidatorProtocol {
            
            let minAmount: Double
            
            func isValid(value: Double) -> Bool {
                
                guard value >= minAmount else {
                    return false
                }
                
                return true
            }
        }
    }
}
