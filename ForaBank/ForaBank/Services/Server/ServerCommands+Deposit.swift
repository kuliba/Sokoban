//
//  ServerCommands+DepositController.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/31/22.
//

import Foundation

extension ServerCommands {

	enum DepositController {

		struct DepositControllerPayload: Encodable {

			let endDate: String?
			let id: Int
			let name: String?
			let startDate: String?
			let statementFormat: StatementFormat?
		}

		/*
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/DepositController/getDepositInfoUsingPOST
		 */
		struct GetDepositInfo: ServerCommand {

			let token: String
			let endpoint = "/rest/getDepositInfo"
			let method: ServerCommandMethod = .post
			let parameters: [ServerCommandParameter]? = nil
			let payload: DepositControllerPayload?

			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: DepositInfoDataItem?
			}

			internal init(token: String, endDate: Date?, id: Int, name: String?, startDate: Date?, statementFormat: StatementFormat?) {

				let formatter = DateFormatter.utc
				self.token = token
				var endDateString: String? = nil
				if let endDate = endDate {
					endDateString = formatter.string(from: endDate)
				}

				var startDateString: String? = nil
				if let startDate = startDate {
					startDateString = formatter.string(from: startDate)
				}

				self.payload = DepositControllerPayload(endDate: endDateString,
														id: id,
														name: name,
														startDate: startDateString,
														statementFormat: statementFormat)
			}
		}

		/*
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/DepositController/getDepositStatementUsingPOST
		 */
		struct GetDepositStatement: ServerCommand {

			let token: String
			let endpoint = "/rest/getDepositStatement"
			let method: ServerCommandMethod = .post
			let parameters: [ServerCommandParameter]? = nil
			let payload: DepositControllerPayload?

			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: [ProductStatementData]?
			}

			internal init(token: String, endDate: Date?, id: Int, name: String?, startDate: Date?, statementFormat: StatementFormat?) {

				let formatter = DateFormatter.utc
				self.token = token
				var endDateString: String? = nil
				if let endDate = endDate {
					endDateString = formatter.string(from: endDate)
				}

				var startDateString: String? = nil
				if let startDate = startDate {
					startDateString = formatter.string(from: startDate)
				}

				self.payload = DepositControllerPayload(endDate: endDateString,
														id: id,
														name: name,
														startDate: startDateString,
														statementFormat: statementFormat)
			}
		}

		/*
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/DepositController/openDepositUsingPOST
		 */
		struct OpenDeposit: ServerCommand {

			let token: String
			let endpoint = "/rest/openDeposit"
			let method: ServerCommandMethod = .post
			let parameters: [ServerCommandParameter]? = nil
			let payload: Payload? = nil

			struct Payload: Encodable { }

			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: EmptyData?
			}

			internal init(token: String) {

				self.token = token
			}
		}

		/*
		 https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/DepositController/saveDepositCustomNameUsingPOST
		 */
		struct SaveDepositCustomName: ServerCommand {

			let token: String
			let endpoint = "/rest/saveDepositCustomName"
			let method: ServerCommandMethod = .post
			let parameters: [ServerCommandParameter]? = nil
			let payload: DepositControllerPayload?

			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: EmptyData?
			}

			internal init(token: String, endDate: Date?, id: Int, name: String?, startDate: Date?, statementFormat: StatementFormat?) {

				let formatter = DateFormatter.utc
				self.token = token
				var endDateString: String? = nil
				if let endDate = endDate {
					endDateString = formatter.string(from: endDate)
				}

				var startDateString: String? = nil
				if let startDate = startDate {
					startDateString = formatter.string(from: startDate)
				}

				self.payload = Payload(endDate: endDateString,
									   id: id,
									   name: name,
									   startDate: startDateString,
									   statementFormat: statementFormat)
			}
		}
	}
}
