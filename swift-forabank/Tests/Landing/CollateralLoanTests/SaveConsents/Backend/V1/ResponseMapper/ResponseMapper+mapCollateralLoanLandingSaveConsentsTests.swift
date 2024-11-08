//
//  ResponseMapper+mapCollateralLoanLandingSaveConsentsTests.swift
//
//
//  Created by Valentin Ozerov on 24.10.2024.
//

import RemoteServices
import XCTest

final class ResponseMapper_mapCollateralLoanLandingSaveConsentsResponseTests: XCTestCase {
    
    func test_map_shouldDeliverValidData() {
        
        XCTAssertNoDiff(
            map(.validData),
            .success(.stub)
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyData() {
        
        XCTAssertNoDiff(
            map(.empty),
            .failure(.invalid(statusCode: 200, data: .empty))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnInvalidData() {
        
        XCTAssertNoDiff(
            map(.invalidData),
            .failure(.invalid(statusCode: 200, data: .invalidData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyJSON() {
        
        XCTAssertNoDiff(
            map(.emptyJSON),
            .failure(.invalid(statusCode: 200, data: .emptyJSON))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyDataResponse() {
        
        XCTAssertNoDiff(
            map(.emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: .emptyDataResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNullServerResponse() {
        
        XCTAssertNoDiff(
            map(.nullServerResponse),
            .failure(.invalid(statusCode: 200, data: .nullServerResponse))
        )
    }
    
    func test_map_shouldDeliverServerErrorOnServerError() {
        
        XCTAssertNoDiff(
            map(.serverError),
            .failure(.server(
                statusCode: 102,
                errorMessage: "Возникла техническая ошибка"
            ))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNonOkHTTPResponse() throws {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(.validData, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: .validData))
            )
        }
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyList() {
        
        let emptyDataResponse: Data = .emptyListResponse
        
        XCTAssertNoDiff(
            map(emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: emptyDataResponse))
        )
    }
    
    // MARK: - Helpers
    
    private typealias MappingResult = Swift.Result<
        ResponseMapper.CollateralLoanLandingSaveConsentsResponse,
        ResponseMapper.MappingError
    >
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        ResponseMapper.mapSaveConsentsResponse(data, httpURLResponse)
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let emptyListResponse: Data = String.emptyList.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    static let validData: Data = String.validJson.json
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static let invalidData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "junk" }
}
"""
    
    static let emptyJSON = "{}"
    
    static let emptyDataResponse = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": {}
}
"""
    
    static let nullServerResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": null
}
"""
    
    static let serverError = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""
    
    static let emptyList = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": []
}
"""
    
    static let validJson = """
{
"statusCode": 200,
"errorMessage": null,
"data": {
    "applicationId": 9,
    "name": "Кредит под залог транспорта",
    "amount": 99998,
    "termMonth": 365,
    "collateralType": "CAR",
    "interestRate": 18,
    "collateralInfo": "Лада",
    "documents": [
"/persons/381/collateral_loan_applications/9/consent_processing_personal_data.pdf",
"/persons/381/collateral_loan_applications/9/consent_request_credit_history.pdf"
    ],
    "cityName": "Москва",
    "status": "submitted_for_review",
    "responseMessage": "Специалист банка свяжется с Вами в ближайшее время."
    }
}
"""
}

private extension ResponseMapper.CollateralLoanLandingSaveConsentsResponse {
    
    static let stub: Self = .init(
        applicationId: 9,
        name: "Кредит под залог транспорта",
        amount: 99998,
        termMonth: 365,
        collateralType: "CAR",
        interestRate: 18,
        collateralInfo: "Лада",
        documents: [
            "/persons/381/collateral_loan_applications/9/consent_processing_personal_data.pdf",
            "/persons/381/collateral_loan_applications/9/consent_request_credit_history.pdf"
        ],
        cityName: "Москва",
        status: "submitted_for_review",
        responseMessage: "Специалист банка свяжется с Вами в ближайшее время."
    )
}
