//
//  ServerCommands+Transfer.swift
//  ForaBank
//
//  Created by Max Gribov on 31.01.2022.
//

import Foundation
import SVGKit

extension ServerCommands {
    
    enum TransferController {
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/TransferController/antiFraudUsingPOST
         */
        struct AntiFraud: ServerCommand {

            let token: String?
            let endpoint = "/rest/transfer/antiFraud"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: Bool?
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/TransferController/changeOutgoingUsingPOST
         */
        struct ChangeOutgoing: ServerCommand {

            let token: String?
            let endpoint = "/rest/transfer/changeOutgoing"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {
                
                let bLastName: String
                let bName: String
                let bSurName: String
                let transferReference: String
            }
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/TransferController/checkCardUsingPOST
         */
        struct CheckCard: ServerCommand {

            let token: String?
            let endpoint = "/rest/transfer/checkCard"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {
                
                let cardNumber: String
                let cryptoVersion: String
            }
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: CheckCardResponseData?
                
                struct CheckCardResponseData: Codable, Equatable {
                    
                    let check: Bool
                    let payeeCurrency: String
                }
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/TransferController/createAnywayTransferUsingPOST
         */
        struct CreateAnywayTransfer: ServerCommand {

            let token: String?
            let endpoint = "/rest/transfer/createAnywayTransfer"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]?
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            typealias Payload = TransferAnywayData
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: TransferAnywayResponseData?
            }
            
            internal init(token: String, isNewPayment: Bool, payload: Payload) {
                
                self.token = token
                var parameters = [ServerCommandParameter]()
                parameters.append(.init(name: "isNewPayment", value: isNewPayment.description))
                self.parameters = parameters
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/TransferController/createContactAddresslessTransferUsingPOST
         */
        struct CreateContactAddresslessTransfer: ServerCommand {

            let token: String?
            let endpoint = "/rest/transfer/createContactAddresslessTransfer"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            typealias Payload = TransferAnywayData
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: TransferAnywayResponseData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/TransferController/createContactAddresslessTransferUsingPOST
         */
        struct CreateDirectTransfer: ServerCommand {

            let token: String?
            let endpoint = "/rest/transfer/createDirectTransfer"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            typealias Payload = TransferAnywayData
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: TransferAnywayResponseData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/TransferController/createMe2MePullCreditTransferUsingPOST
         */
        struct CreateMe2MePullCreditTransfer: ServerCommand {

            let token: String?
            let endpoint = "/rest/transfer/createMe2MePullCreditTransfer"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            typealias Payload = TransferMe2MeData
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/TransferController/createMe2MePullDebitTransferUsingPOST
         */
        struct CreateMe2MePullDebitTransfer: ServerCommand {

            let token: String?
            let endpoint = "/rest/transfer/createMe2MePullDebitTransfer"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            typealias Payload = TransferAnywayData
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: TransferAnywayResponseData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/TransferController/createSFPTransferUsingPOST
         */
        struct CreateSFPTransfer: ServerCommand {

            let token: String?
            let endpoint = "/rest/transfer/createSFPTransfer"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            typealias Payload = TransferAnywayData
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: TransferAnywayResponseData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/TransferController/createTransferUsingPOST
         */
        struct CreateTransfer: ServerCommand {

            let token: String?
            let endpoint = "/rest/transfer/createTransfer"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            typealias Payload = TransferGeneralData
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: TransferResponseData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/TransferController/getVerificationCodeUsingGET
         */
        struct GetVerificationCode: ServerCommand {

            let token: String?
            let endpoint = "/rest/transfer/getVerificationCode"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: VerificationCodeData?
                
                struct VerificationCodeData: Codable, Equatable {
                    
                    let otp: String?
                    let resendOTPCount: Int
                }
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/TransferController/isSingleServiceUsingPOST
         */
        struct IsSingleService: ServerCommand {

            let token: String?
            let endpoint = "/rest/transfer/isSingleService"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {
                
                let puref: String
            }
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: Bool?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/TransferController/makeTransferUsingPOST
         */
        struct MakeTransfer: ServerCommand {

            let token: String?
            let endpoint = "/rest/transfer/makeTransfer"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {
                
                var cryptoVersion: String? = nil
                let verificationCode: String
            }
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: TransferResponseBaseData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/TransferController/returnOutgoingUsingPOST
         */
        struct ReturnOutgoing: ServerCommand {

            let token: String?
            let endpoint = "/rest/transfer/returnOutgoing"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {
                
                let paymentOperationDetailId: Int
                let transferReference: String
            }
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
    }
}
