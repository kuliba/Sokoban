//
//  ServerCommands+AccountController.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/18/22.
//

import Foundation

extension ServerCommands {

	enum AccountController {

		/*
		 https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/AccountController/getAccountStatementUsingPOST
		 */
		struct GetAccountStatement: ServerCommand {

			let token: String?
			let endpoint = "/rest/getAccountStatement"
			let method: ServerCommandMethod = .post
			let parameters: [ServerCommandParameter]? = nil
			var payload: BasePayload?
            let timeout: TimeInterval? = nil

			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: [ProductStatementData]?
			}

			internal init(token: String,
						  accountNumber: String?,
						  endDate: Date?,
						  id: Int,
						  name: String?,
						  startDate: Date?,
						  statementFormat: StatementFormat?) {

				let formatter = DateFormatter.iso8601
				self.token = token

				var endDateString: String? = nil
				if let endDate = endDate {
					endDateString = formatter.string(from: endDate)
				}

				var startDateString: String? = nil
				if let startDate = startDate {
					startDateString = formatter.string(from: startDate)
				}

				self.payload = Payload(accountNumber: accountNumber,
									   endDate: endDateString,
									   id: id,
									   name: name,
									   startDate: startDateString,
									   statementFormat: statementFormat)
			}
		}

		/*
		 https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/AccountController/getPrintFormForAccountStatementUsingPOST
		 */
		struct GetPrintFormForAccountStatement: ServerDownloadCommand {

			let token: String?
			let endpoint = "/rest/getPrintFormForAccountStatement"
			let method: ServerCommandMethod = .post
			let parameters: [ServerCommandParameter]? = nil
			var payload: BasePayload?
            let timeout: TimeInterval? = nil
            let cachePolicy: URLRequest.CachePolicy = .reloadIgnoringCacheData

			internal init(token: String,
						  accountNumber: String?,
						  endDate: Date?,
						  id: Int,
						  name: String?,
						  startDate: Date?,
						  statementFormat: StatementFormat?) {

				let formatter = DateFormatter.iso8601
				self.token = token

				var endDateString: String? = nil
				if let endDate = endDate {
					endDateString = formatter.string(from: endDate)
				}

				var startDateString: String? = nil
				if let startDate = startDate {
					startDateString = formatter.string(from: startDate)
				}

				self.payload = Payload(accountNumber: accountNumber,
									   endDate: endDateString,
									   id: id,
									   name: name,
									   startDate: startDateString,
									   statementFormat: statementFormat)
			}
		}
        
        struct BasePayload: Encodable {
            
            let accountNumber: String?
            let endDate: String?
            let id: Int
            let name: String?
            let startDate: String?
            let statementFormat: StatementFormat?
        }
	}
}
