//
//  ServerCommands+PaymentOperationDetail.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/24/22.
//

import Foundation

extension ServerCommands {
    
    enum PaymentOperationDetailContoller {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getAllLatestPaymentsUsingGET
         */
        struct GetAllLatestPayments: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getAllLatestPayments"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable { }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [LatestPaymentData]?
                
                private enum CodingKeys: CodingKey {
                    case statusCode, errorMessage, data
                }
                
                init(statusCode: ServerStatusCode, errorMessage: String?, data: [LatestPaymentData]) {
                    self.statusCode = statusCode
                    self.errorMessage = errorMessage
                    self.data = data
                }
                
                init(from decoder: Decoder) throws {
                    
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.statusCode = try container.decode(ServerStatusCode.self, forKey: .statusCode)
                    self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
                    
                    var containerData = try container.nestedUnkeyedContainer(forKey: .data)
                    
                    var data = [LatestPaymentData]()
                    var items = containerData
                    
                    while !containerData.isAtEnd {
                        
                        let paymentData = try containerData.decode(LatestPaymentData.self)
                        let paymentType = paymentData.type
                        
                        switch paymentType {
                        case .phone:
                            let paymentData = try items.decode(PaymentGeneralData.self)
                            data.append(paymentData)
                            
                        case .internet, .mobile, .service, .transport, .taxAndStateService, .outside:
                            let paymentData = try items.decode(PaymentServiceData.self)
                            data.append(paymentData)
                            
                        default:
                            break
                        }
                    }
                    self.data = data
                }
            }
            
            init(token: String, isPhonePayments: Bool, isServicePayments: Bool, isMobilePayments: Bool, isInternetPayments: Bool, isTransportPayments: Bool, isTaxAndStateServicePayments: Bool, isOutsidePayments: Bool) {
                
                self.token = token
                var parameters = [ServerCommandParameter]()
                
                parameters.append(.init(name: "isPhonePayments", value: isPhonePayments.asString))
                parameters.append(.init(name: "isServicePayments", value: isServicePayments.asString))
                parameters.append(.init(name: "isMobilePayments", value: isMobilePayments.asString))
                parameters.append(.init(name: "isInternetPayments", value: isInternetPayments.asString))
                parameters.append(.init(name: "isTransportPayments", value: isTransportPayments.asString))
                parameters.append(.init(name: "isTaxAndStateServicePayments", value: isTaxAndStateServicePayments.asString))
                parameters.append(.init(name: "isOutsidePayments", value: isOutsidePayments.asString))
                
                self.parameters = parameters
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getLatestInternetPaymentsUsingGET
         */
        struct GetLatestInternetPayments: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getLatestInternetPayments"
            let method: ServerCommandMethod = .get
            let payload: Payload?
            
            struct Payload: Encodable { }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [PaymentServiceData]?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getLatestMobilePaymentsUsingGET
         */
        struct GetLatestMobilePayments: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getLatestMobilePayments"
            let method: ServerCommandMethod = .get
            let payload: Payload?
            
            struct Payload: Encodable { }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [PaymentServiceData]?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getLatestPaymentsUsingGET
         */
        struct GetLatestPayments: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getLatestPayments"
            let method: ServerCommandMethod = .get
            let payload: Payload?
            
            struct Payload: Encodable { }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [PaymentGeneralData]?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getLatestPhonePaymentsUsingPOST
         */
        struct GetLatestPhonePayments: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getLatestPhonePaymentsWithDefaultBank"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let phoneNumber: String
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [PaymentPhoneData]?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getLatestServicePaymentsUsingGET
         */
        struct GetLatestServicePayments: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getLatestServicePayments"
            let method: ServerCommandMethod = .get
            let payload: Payload?
            
            struct Payload: Encodable { }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [PaymentServiceData]?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getLatestTransportPaymentsUsingGET
         */
        struct GetLatestTransportPayments: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getLatestTransportPayments"
            let method: ServerCommandMethod = .get
            let payload: Payload?
            
            struct Payload: Encodable { }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [PaymentServiceData]?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getOperationDetailUsingPOST
         */
        struct GetOperationDetail: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getOperationDetail"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let documentId: String
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: OperationDetailData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/PaymentOperationDetailController/getOperationDetailByPaymentId
         */
        struct GetOperationDetailByPaymentId: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getOperationDetailByPaymentId"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let paymentOperationDetailId: Int
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: OperationDetailData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getPaymentCountriesUsingGET
         */
        struct GetPaymentCountries: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getPaymentCountries"
            let method: ServerCommandMethod = .get
            let payload: Payload?
            
            struct Payload: Encodable { }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [PaymentCountryData]?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getBicAccountCheck
         */
        struct GetBicAccountCheck: ServerCommand {
            
            let token: String
            let endpoint = "/rest/v1/getBicAccountCheck"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let bic: String
                let account: String
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: BicAccountCheck?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
    }
}

