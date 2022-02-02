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
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getAllLatestPaymentsUsingGET
		 */
		struct GetAllLatestPayments: ServerCommand {
			
			let token: String
			let endpoint = "/rest/getAllLatestPayments"
			let method: ServerCommandMethod = .get
			let parameters: [ServerCommandParameter]?
			let payload: Payload? = nil

			struct Payload: Encodable { }
			
			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: [LatestPaymentData]?
			}
			
			internal init(token: String, isPhonePayments: Bool, isCountriesPayments: Bool, isServicePayments: Bool, isMobilePayments: Bool, isInternetPayments: Bool, isTransportPayments: Bool, isTaxAndStateServicePayments: Bool) {
				
				self.token = token
				var parameters = [ServerCommandParameter]()

				parameters.append(.init(name: "isPhonePayments", value: isPhonePayments ? "true" : "false"))
				parameters.append(.init(name: "isCountriesPayments", value: isCountriesPayments ? "true" : "false"))
				parameters.append(.init(name: "isServicePayments", value: isServicePayments ? "true" : "false"))
				parameters.append(.init(name: "isMobilePayments", value: isMobilePayments ? "true" : "false"))
				parameters.append(.init(name: "isInternetPayments", value: isInternetPayments ? "true" : "false"))
				parameters.append(.init(name: "isTransportPayments", value: isTransportPayments ? "true" : "false"))
				parameters.append(.init(name: "isTaxAndStateServicePayments", value: isTaxAndStateServicePayments ? "true" : "false"))
				self.parameters = parameters
			}
		}
		
		/*
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getLatestInternetPaymentsUsingGET
		 */
		struct GetLatestInternetPayments: ServerCommand {
			
			let token: String
			let endpoint = "/rest/getLatestInternetPayments"
			let method: ServerCommandMethod = .get
			let parameters: [ServerCommandParameter]? = nil
			let payload: Payload?

			struct Payload: Encodable { }
			
			struct Response: ServerResponse {
				
				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: [LatestServicePaymentsResponseData]?
			}
			
			internal init(token: String, payload: Payload) {
				
				self.token = token
				self.payload = payload
			}
		}

		/*
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getLatestMobilePaymentsUsingGET
		 */
		struct GetLatestMobilePayments: ServerCommand {
			
			let token: String
			let endpoint = "/rest/getLatestMobilePayments"
			let method: ServerCommandMethod = .get
			let parameters: [ServerCommandParameter]? = nil
			let payload: Payload?

			struct Payload: Encodable { }
			
			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: [LatestServicePaymentsResponseData]?
			}
			
			internal init(token: String, payload: Payload) {
				
				self.token = token
				self.payload = payload
			}
		}

		/*
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getLatestPaymentsUsingGET
		 */
		struct GetLatestPayments: ServerCommand {
			
			let token: String
			let endpoint = "/rest/getLatestPayments"
			let method: ServerCommandMethod = .get
			let parameters: [ServerCommandParameter]? = nil
			let payload: Payload?

			struct Payload: Encodable { }
			
			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: [LatestPaymentsResponseData]?
			}
			
			internal init(token: String, payload: Payload) {
				
				self.token = token
				self.payload = payload
			}
		}

		/*
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getLatestPhonePaymentsUsingPOST
		 */
		struct GetLatestPhonePayments: ServerCommand {
			
			let token: String
			let endpoint = "/rest/getLatestPhonePayments"
			let method: ServerCommandMethod = .post
			let parameters: [ServerCommandParameter]? = nil
			let payload: Payload?

			struct Payload: Encodable {

				let phoneNumber: String?
			}
			
			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: [LatestPhonePaymentsResponseData]?
			}
			
			internal init(token: String, payload: Payload) {
				
				self.token = token
				self.payload = payload
			}
		}

		/*
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getLatestServicePaymentsUsingGET
		 */
		struct GetLatestServicePayments: ServerCommand {
			
			let token: String
			let endpoint = "/rest/getLatestServicePayments"
			let method: ServerCommandMethod = .get
			let parameters: [ServerCommandParameter]? = nil
			let payload: Payload?

			struct Payload: Encodable { }
			
			struct Response: ServerResponse {
				
				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: [LatestServicePaymentsResponseData]?
			}
			
			internal init(token: String, payload: Payload) {
				
				self.token = token
				self.payload = payload
			}
		}

		/*
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getLatestTransportPaymentsUsingGET
		 */
		struct GetLatestTransportPayments: ServerCommand {
			
			let token: String
			let endpoint = "/rest/getLatestTransportPayments"
			let method: ServerCommandMethod = .get
			let parameters: [ServerCommandParameter]? = nil
			let payload: Payload?

			struct Payload: Encodable { }
			
			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: [LatestServicePaymentsResponseData]?
			}
			
			internal init(token: String, payload: Payload) {
				
				self.token = token
				self.payload = payload
			}
		}

		/*
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getOperationDetailUsingPOST
		 */
		struct GetOperationDetail: ServerCommand {
			
			let token: String
			let endpoint = "/rest/getOperationDetail"
			let method: ServerCommandMethod = .post
			let parameters: [ServerCommandParameter]? = nil
			let payload: Payload?

			struct Payload: Encodable {

				let documentId: String
			}
			
			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: OperationDetailResponseData?
			}
			
			internal init(token: String, payload: Payload) {
				
				self.token = token
				self.payload = payload
			}
		}

		/*
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PaymentOperationDetailController/getPaymentCountriesUsingGET
		 */
		struct GetPaymentCountries: ServerCommand {
			
			let token: String
			let endpoint = "/rest/getPaymentCountries"
			let method: ServerCommandMethod = .get
			let parameters: [ServerCommandParameter]? = nil
			let payload: Payload?

			struct Payload: Encodable { }
			
			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: [PaymentCountriesResponseData]?
			}
			
			internal init(token: String, payload: Payload) {
				
				self.token = token
				self.payload = payload
			}
		}

	}
}
