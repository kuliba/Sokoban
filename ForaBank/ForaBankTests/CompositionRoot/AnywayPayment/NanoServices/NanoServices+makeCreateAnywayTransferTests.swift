//
//  NanoServices+makeCreateAnywayTransferTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 27.03.2024.
//

@testable import ForaBank
import XCTest

final class NanoServices_makeCreateAnywayTransferTests: XCTestCase {
    
    func test_shouldCallHTTPClientOnce() throws {
        
        _ = try checkRequest()
    }
    
    func test_shouldSetURL() throws {
        
        try assertURL("https://pl.forabank.ru/dbo/api/v3/rest/transfer/createAnywayTransfer")
    }
    
    func test_shouldSetHTTPMethodToPOST() throws {
        
        try assertHTTPMethod("POST")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        try assertCachePolicy(.reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_shouldPassPayload() throws {
        
        try XCTAssertNotNil(checkRequest(with: makePayload()).httpBody)
    }
    
    func test_shouldDeliverNilOnFailure() {
        
        expect(toDeliver: .failure(.connectivityError), on: .failure(anyError()))
    }
    
    func test_shouldDeliverNilOnEmptyData() {
        
        expect(toDeliver: .failure(.connectivityError), onData: .empty)
    }
    
    func test_shouldDeliverNilOnEmptyJSON() {
        
        expect(toDeliver: .failure(.connectivityError), onData: .emptyJSON)
    }
    
    func test_shouldDeliverNilOnEmptyArrayJSON() {
        
        expect(toDeliver: .failure(.connectivityError), onData: .emptyArrayJSON)
    }
    
    func test_shouldDeliverNilOnInvalidData() {
        
        expect(toDeliver: .failure(.connectivityError), onData:  .invalid)
    }
    
    func test_shouldDeliverNilOnNullServerResponse() {
        
        expect(toDeliver: .failure(.connectivityError), onData: .nullServerResponse)
    }
    
    func test_shouldDeliverNilOnEmptyServerData() {
        
        expect(toDeliver: .failure(.connectivityError), onData: .emptyServerData)
    }
    
    func test_shouldDeliverNilOnEmptyArrayServerData() {
        
        expect(toDeliver: .failure(.connectivityError), onData: .emptyArrayServerData)
    }
    
    func test_shouldDeliverNilOnInvalidServerData() {
        
        expect(toDeliver: .failure(.connectivityError), onData: .invalidServerData)
    }
    
    func test_shouldDeliverServerErrorWithMessageOnServerError() {
        
        expect(toDeliver: .failure(.serverError("Возникла техническая ошибка")), onData: .serverError)
    }
    
    func test_shouldDeliverNilOnValidDataNonOKStatusCode() {
        
        for nonOkStatusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOKResponse = anyHTTPURLResponse(with: nonOkStatusCode)
            expect(toDeliver: .failure(.connectivityError), on: .success((.valid, nonOKResponse)))
        }
    }
    
    func test_shouldDeliverResponseOnValidData() {
        
        expect(
            toDeliver: .success(.init(
                additionals: [],
                finalStep: false,
                needMake: false,
                needOTP: false,
                needSum: false,
                parametersForNextStep: [
                    .init(
                        dataType: .string,
                        id: "1",
                        inputFieldType: .account,
                        isPrint: true,
                        isRequired: true,
                        order: 1,
                        phoneBook: false,
                        rawLength: 0,
                        isReadOnly: false,
                        regExp: "^.{1,250}$",
                        svgImage: "svgImage",
                        title: "Лицевой счет",
                        type: .input,
                        viewType: .input
                    )
                ],
                paymentOperationDetailID: 54321
            )),
            onData: .valid
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = NanoServices.CreateAnywayTransfer
    private typealias Payload = NanoServices.CreateAnywayTransferPayload
    private typealias Result = NanoServices.CreateAnywayTransferResult
    private typealias Response = NanoServices.CreateAnywayTransferResponse
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy
    ) {
        let httpClient = HTTPClientSpy()
        let sut = NanoServices.makeCreateAnywayTransfer(httpClient, { _,_,_ in })
        
        trackForMemoryLeaks(httpClient, file: file, line: line)
        
        return (sut, httpClient)
    }
    
    private func assertURL(
        with payload: Payload = makePayload(),
        _ urlString: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let request = try checkRequest(file: file, line: line)
        XCTAssertNoDiff(request.url?.absoluteString, urlString, file: file, line: line)
    }
    
    private func assertHTTPMethod(
        with payload: Payload = makePayload(),
        _ httpMethod: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let request = try checkRequest(file: file, line: line)
        XCTAssertNoDiff(request.httpMethod, httpMethod, file: file, line: line)
    }
    
    private func assertCachePolicy(
        with payload: Payload = makePayload(),
        _ cachePolicy: URLRequest.CachePolicy,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let request = try checkRequest(file: file, line: line)
        XCTAssertNoDiff(request.cachePolicy, cachePolicy, file: file, line: line)
    }
    
    private func checkRequest(
        with payload: Payload = makePayload(),
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> URLRequest {
        
        let (make, httpClient) = makeSUT()
        make(payload) { _ in }
        
        let count = httpClient.requests.count
        XCTAssertNoDiff(count, 1, "Expected to have one request, but got \(count) insted.")
        
        return try XCTUnwrap(httpClient.requests.first, file: file, line: line)
    }
    
    private func expect(
        with payload: Payload = makePayload(),
        toDeliver expectedResult: Result,
        onData data: Data,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (make, httpClient) = makeSUT()
        
        expect(
            make,
            with: payload,
            toDeliver: expectedResult,
            on: { httpClient.complete(with: .success((data, okResponse))) },
            file: file, line: line
        )
    }
    
    private func expect(
        with payload: Payload = makePayload(),
        toDeliver expectedResult: Result,
        on httpClientResult: HTTPClient.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (make, httpClient) = makeSUT()
        
        expect(
            make,
            with: payload,
            toDeliver: expectedResult,
            on: { httpClient.complete(with: httpClientResult) },
            file: file, line: line
        )
    }
    
    private func expect(
        _ sut: @escaping SUT,
        with payload: Payload = makePayload(),
        toDeliver expectedResult: Result,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        var receivedResult: Result?
        
        sut(payload) {
            
            receivedResult = $0
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(receivedResult, expectedResult, "\nExpected \(String(describing: expectedResult)), got \(String(describing: receivedResult)) instead.", file: file, line: line)
    }
}

private let okResponse = anyHTTPURLResponse(with: 200)

private func makePayload(
    accountID: Int? = nil,
    accountNumber: String? = nil,
    amount: Decimal? = nil,
    cardID: Int? = nil,
    cardNumber: String? = nil,
    comment: String? = nil,
    currencyAmount: String? = nil,
    fieldID: Int = generateRandom11DigitNumber(),
    fieldName: String = UUID().uuidString,
    fieldValue: String = UUID().uuidString,
    inn: String? = nil,
    mcc: String? = nil,
    phoneNumber: String? = nil,
    puref: String? = nil
) -> NanoServices.CreateAnywayTransferPayload {
    
    .init(
        additionals: [
            .init(
                fieldID: fieldID,
                fieldName: fieldName,
                fieldValue: fieldValue
            )
        ],
        amount: amount,
        check: false,
        comment: comment,
        currencyAmount: currencyAmount,
        mcc: mcc,
        payer: .init(
            accountID: accountID,
            accountNumber: accountNumber,
            cardID: cardID,
            cardNumber: cardNumber,
            inn: inn,
            phoneNumber: phoneNumber
        ),
        puref: puref
    )
}
private extension Data {
    
    static let valid = json(.valid)
}

private extension String {
    
    static let valid = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "needMake": null,
        "needOTP": null,
        "amount": null,
        "creditAmount": null,
        "fee": null,
        "currencyAmount": null,
        "currencyPayer": null,
        "currencyPayee": null,
        "currencyRate": null,
        "debitAmount": null,
        "payeeName": null,
        "paymentOperationDetailId": 54321,
        "documentStatus": null,
        "needSum": false,
        "additionalList": [],
        "parameterListForNextStep": [
            {
                "id": "1",
                "order": 1,
                "title": "Лицевой счет",
                "subTitle": null,
                "viewType": "INPUT",
                "dataType": "%String",
                "type": "Input",
                "mask": null,
                "regExp": "^.{1,250}$",
                "maxLength": null,
                "minLength": null,
                "rawLength": 0,
                "isRequired": true,
                "content": null,
                "readOnly": false,
                "isPrint": true,
                "svgImage": "svgImage",
                "inputFieldType": "ACCOUNT",
                "dataDictionary": null,
                "dataDictionaryРarent": null,
                "group": null,
                "subGroup": null,
                "inputMask": null,
                "phoneBook": null
            }
        ],
        "finalStep": false,
        "infoMessage": null,
        "printFormType": null,
        "scenario": null
    }
}
"""
}
