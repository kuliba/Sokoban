//
//  ServerCommands+AccountController.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/18/22.
//

import Foundation

extension ServerCommands {

	enum AccountController {

		enum StatementFormat: String, Codable, Equatable {

			case csv = "CSV"
			case pdf = "PDF"
		}

		/*
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/AccountController/getAccountStatementUsingPOST
		 */
		struct GetAccountStatement: ServerCommand {

			let token: String
			let endpoint = "/rest/getAccountStatement"
			let method: ServerCommandMethod = .post
			let parameters: [ServerCommandParameter]? = nil
			var payload: Payload?

			struct Payload: Encodable {

				let accountNumber: String
				let endDate: String
				let id: Int
				let name: String
				let startDate: String
				let statementFormat: StatementFormat
			}

			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: [ProductStatementData]?
			}

			internal init(token: String, payload: Payload) {

				self.token = token
				self.payload = payload
			}
		}

		/*
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/AccountController/getAccountStatementForPeriodUsingPOST
		 */
		struct GetAccountStatementForPeriod: ServerCommand {

			let token: String
			let endpoint = "/rest/getAccountStatementForPeriod"
			let method: ServerCommandMethod = .post
			let parameters: [ServerCommandParameter]? = nil
			var payload: Payload?

			struct Payload: Encodable {

				let accountNumber: String
				let endDate: String
				let id: Int
				let name: String
				let startDate: String
				let statementFormat: StatementFormat
			}

			struct Response: ServerResponse {
				
				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: [ProductStatementData]?
			}

			internal init(token: String, payload: Payload) {
				
				self.token = token
				self.payload = payload
			}
		}

		/*
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/AccountController/getPrintFormForAccountStatementUsingPOST
		 */
		struct GetPrintFormForAccountStatement: ServerCommand {

			let token: String
			let endpoint = "/rest/getPrintFormForAccountStatement"
			let method: ServerCommandMethod = .post
			let parameters: [ServerCommandParameter]? = nil
			var payload: Payload?

			struct Payload: Encodable {

				let accountNumber: String
				let endDate: String
				let id: Int
				let name: String
				let startDate: String
				let statementFormat: StatementFormat
			}

			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: EmptyData
			}

			internal init(token: String, payload: Payload) {

				self.token = token
				self.payload = payload
			}
		}

		/*
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/AccountController/getPrintMapForAccountStatementUsingPOST
		 */

		struct GetPrintMapForAccountStatement: ServerCommand {

			let token: String
			let endpoint = "/rest/getPrintMapForAccountStatement"
			let method: ServerCommandMethod = .post
			let parameters: [ServerCommandParameter]? = nil
			var payload: Payload?

			struct Payload: Encodable {

				let accountNumber: String
				let endDate: String
				let id: Int
				let name: String
				let startDate: String
				let statementFormat: StatementFormat
			}

			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: AccountStatementPrintMapResponseData?
			}

			internal init(token: String, payload: Payload) {

				self.token = token
				self.payload = payload
			}
		}
	}
}
