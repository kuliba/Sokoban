//
//  ServerCommands+DepositController.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/31/22.
//

import Foundation

extension ServerCommands {

	enum DepositController {

		/*
		 https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/DepositController/getDepositInfoUsingPOST
		 */
		struct GetDepositInfo: ServerCommand {

			let token: String?
			let endpoint = "/rest/getDepositInfo"
			let method: ServerCommandMethod = .post
			let parameters: [ServerCommandParameter]? = nil
			let payload: BasePayload?
            let timeout: TimeInterval? = nil

			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: DepositInfoDataItem?
			}

			internal init(token: String, endDate: Date?, id: Int, name: String?, startDate: Date?, statementFormat: StatementFormat?) {

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

				self.payload = BasePayload(endDate: endDateString,
														id: id,
														name: name,
														startDate: startDateString,
														statementFormat: statementFormat)
			}
		}

		/*
		 https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/DepositController/getDepositStatementUsingPOST
		 */
		struct GetDepositStatement: ServerCommand {

			let token: String?
			let endpoint = "/rest/getDepositStatement"
			let method: ServerCommandMethod = .post
			let parameters: [ServerCommandParameter]? = nil
			let payload: BasePayload?
            let timeout: TimeInterval? = nil

			struct Response: ServerResponse {

				let statusCode: ServerStatusCode
				let errorMessage: String?
				let data: [ProductStatementData]?
			}

			internal init(token: String, endDate: Date?, id: Int, name: String?, startDate: Date?, statementFormat: StatementFormat?) {

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

				self.payload = BasePayload(endDate: endDateString,
														id: id,
														name: name,
														startDate: startDateString,
														statementFormat: statementFormat)
			}
		}

		/*
		 https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/DepositController/openDepositUsingPOST
		 */
		struct OpenDeposit: ServerCommand {

			let token: String?
			let endpoint = "/rest/openDeposit"
			let method: ServerCommandMethod = .post
			let parameters: [ServerCommandParameter]? = nil
			let payload: Payload? = nil
            let timeout: TimeInterval? = nil

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
         http://192.168.50.113:8080/swagger-ui/index.html#/DepositController/saveDepositCustomName
         */
        struct SaveDepositName: ServerCommand {
            
            let token: String?
            let endpoint = "/rest/saveDepositName"
            let method: ServerCommandMethod = .post
            let payload: BasePayload?
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String, payload: BasePayload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController//dict//rest/getDepositProductListUsingGet
         */
        struct GetDepositProductList: ServerCommand {

            let token: String?
            let endpoint = "/rest/getDepositProductList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]? = nil
            var payload: Payload? = nil
            let timeout: TimeInterval? = nil

            struct Payload: Encodable {}

            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let data: [DepositProductData]?
                let errorMessage: String?
            }
            
            internal init(token: String) {

                self.token = token
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController/dict//rest/closeDeposit
         */
        struct CloseDeposit: ServerCommand {

            let token: String?
            let endpoint = "/rest/closeDeposit"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil

            struct Payload: Encodable {
                    
                    let id: Int
                    let name: String?
                    let startDate: String?
                    let endDate: String?
                    let statementFormat: StatementFormat?
                    let accountId: Int?
                    let cardId: Int?
            }

            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let data: TransferData?
                let errorMessage: String?
                
                struct TransferData: Codable, Equatable {
                    
                    let paymentOperationDetailId: Int?
                    let documentStatus: String
                    let accountNumber: String?
                    let closeDate: Int?
                    let comment: String?
                    let category: String?
                }
            }
            
            internal init(token: String, payload: Payload) {

                self.token = token
                self.payload = payload
            }
        }
        
        struct BasePayload: Encodable {

            let endDate: String?
            let id: Int
            let name: String?
            let startDate: String?
            let statementFormat: StatementFormat?
        }
	}
}
