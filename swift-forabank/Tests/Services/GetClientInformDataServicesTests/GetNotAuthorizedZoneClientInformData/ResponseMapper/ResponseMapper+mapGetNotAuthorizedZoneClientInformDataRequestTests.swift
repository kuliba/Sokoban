//
//  ResponseMapper+mapGetNotAuthorizedZoneClientInformDataRequestTests.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 30.09.2024.
//

import GetClientInformDataServices
import RemoteServices
import XCTest

final class ResponseMapper_mapGetNotAuthorizedZoneClientInformDataRequestTests: XCTestCase {
    
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
    
    func test_map_shouldDeliverInvalidFailureOnNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(.notAuthorized, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: .notAuthorized))
            )
        }
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyList() {
                
        XCTAssertNoDiff(
            map(.emptyListResponse),
            .failure(.invalid(statusCode: 200, data: .emptyListResponse))
        )
    }

    func test_map_shouldDeliverInvalidFailureWithNoSerial() {
       
        XCTAssertNoDiff(
            map(.nullSerialResponse),
            .failure(.invalid(statusCode: 200, data: .nullSerialResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureWithNoNotAuthorizedList() {
        
        XCTAssertNoDiff(
            map(.nullNotAuthorizedListResponse),
            .failure(.invalid(statusCode: 200, data: .nullNotAuthorizedListResponse))
        )
    }
    
    func test_map_withNilAuthBlocking_shouldOmitItem() throws {
        
        let mapped = try mapResult(.withNilAuthBlocking)
        
        XCTAssert(mapped.list.isEmpty)
    }

    func test_map_withNilTitle_shouldOmitItem() throws {
        
        let mapped = try mapResult(.withNilTitle)
        
        XCTAssert(mapped.list.isEmpty)
    }
    
    func test_map_withNilText_shouldOmitItem() throws {
        
        let mapped = try mapResult(.withNilText)
        
        XCTAssert(mapped.list.isEmpty)
    }

    func test_map_withNilAction_shouldOmitItem() throws {
        
        let mapped = try mapResult(.withNilAction)
        
        XCTAssertNil(mapped.list.first?.update?.action)
    }
    
    func test_map_withNilPlatform_shouldOmitItem() throws {

        let mapped = try mapResult(.withNilPlatform)

        XCTAssertNil(mapped.list.first?.update?.platform)
    }

    func test_map_withNilVersion_shouldOmitItem() throws {

        let mapped = try mapResult(.withNilVersion)

        XCTAssertNil(mapped.list.first?.update?.version)
    }

    func test_map_withNilLink_shouldOmitItem() throws {

        let mapped = try mapResult(.withNilLink)

        XCTAssertNil(mapped.list.first?.update?.link)
    }

    func test_map_shouldOmitItemWithNilAuthBlocking() throws {
        
        let mapped = try mapResult(.withNilAuthBlockingInOne)
        
        XCTAssertNoDiff(mapped.list.map(\.authBlocking), [true])
    }

    func test_map_shouldOmitItemWithNilTitle() throws {
        
        let mapped = try mapResult(.withNilTitleInOne)
        
        XCTAssertNoDiff(mapped.list.map(\.title), ["TITLE"])
    }
    
    func test_map_shouldOmitItemWithNilText() throws {
        
        let mapped = try mapResult(.withNilTextInOne)
        
        XCTAssertNoDiff(mapped.list.map(\.text), ["TEXT"])
    }
        
    func test_map_shouldAllowOptionalUpdate() throws {
        
        let mapped = try mapResult(.withNilUpdateInOne)
        
        XCTAssertNoDiff(mapped.list.map(\.update), [ nil,
            .init(
                action: "ACTION",
                platform: "iOS",
                version: "VERSION",
                link: "LINK"
            )
        ])
    }
    
    func test_map_shouldHandleOptionalActionInUpdate() throws {
        
        let mapped = try mapResult(.withNilActionInOne)
        
        XCTAssertNoDiff(mapped.list.map(\.update?.action), [nil, "ACTION"])
    }
    
    func test_map_shouldHandleOptionalPlatformInUpdate() throws {
        
        let mapped = try mapResult(.withNilPlatformInOne)
        
        XCTAssertNoDiff(mapped.list.map(\.update?.platform), [nil, "iOS"])
    }
    
    func test_map_shouldHandleOptionalVersionInUpdate() throws {
        
        let mapped = try mapResult(.withNilVersionInOne)
        
        XCTAssertNoDiff(mapped.list.map(\.update?.version), [nil, "VERSION"])
    }

    func test_map_shouldHandleOptionalLinkInUpdate() throws {
        
        let mapped = try mapResult(.withNilLinkInOne)
        
        XCTAssertNoDiff(mapped.list.map(\.update?.link), [nil, "LINK"])
    }

    func test_map_withEmptyTitle_shouldDeliverValidTitle() throws {
        
        let mapped = try mapResult(.withEmptyTitle)
        
        XCTAssertNoDiff(mapped.list.first?.title, "")
    }
    
    func test_map_withEmptyText_shouldDeliverValidText() throws {
        
        let mapped = try mapResult(.withEmptyText)
        
        XCTAssertNoDiff(mapped.list.first?.text, "")
    }
    
    func test_map_withEmptyAction_shouldDeliverValidAction() throws {
        
        let mapped = try mapResult(.withEmptyAction)
        
        XCTAssertNoDiff(mapped.list.first?.update?.action, "")
    }
    
    func test_map_withEmptyPlatform_shouldDeliverValidPlatform() throws {
        
        let mapped = try mapResult(.withEmptyPlatform)

        XCTAssertNoDiff(mapped.list.first?.update?.platform, "")
    }
    
    func test_map_withEmptyVersion_shouldDeliverValidVersion() throws {
        
        let mapped = try mapResult(.withEmptyVersion)

        XCTAssertNoDiff(mapped.list.first?.update?.version, "")
    }
    
    func test_map_withEmptyLink_shouldDeliverValidLink() throws {
        
        let mapped = try mapResult(.withEmptyLink)

        XCTAssertNoDiff(mapped.list.first?.update?.link, "")
    }

    func test_map_shouldDeliverResponseWithNotAuthorized() throws {
        
        try assert(.notAuthorized, .notAuthorized)
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.GetNotAuthorizedZoneClientInformDataResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetNotAuthorizedZoneClientInformDataResponse(data, httpURLResponse)
    }
    
    private func mapResult(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) throws -> Response {

        try ResponseMapper.mapGetNotAuthorizedZoneClientInformDataResponse(data, httpURLResponse).get()
    }

    private func assert(
        _ data: Data,
        _ response: Response,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let receivedResponse = try map(data).get()
        XCTAssertNoDiff(receivedResponse, response, file: file, line: line)
    }
}

private extension ResponseMapper.GetNotAuthorizedZoneClientInformDataResponse {
    
    static let notAuthorized: Self = .init(
        list: [
            .init(
                authBlocking: true,
                title: "Ой сломалось",
                text: "Мы уже знаем о проблеме и работаем над её исправлением. Попробуйте зайти позже, а пока можете посмотреть наши продукты",
                update: nil
            ),
            .init(
                authBlocking: false,
                title: "Внимание!",
                text: "Вышло новое обновление! Обновитесь скорее!",
                update: .init(
                    action: "optional",
                    platform: "iOS",
                    version: "7.12.15",
                    link: "LINK"
                )
            )
        ],
        serial: "1bebd140bc2660211fbba306105479ae"
    )

}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let emptyListResponse: Data = String.emptyList.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let nullSerialResponse: Data = String.nullSerial.json
    static let nullNotAuthorizedListResponse: Data = String.nullNotAuthorizedList.json
    static let serverError: Data = String.serverError.json
    static let notAuthorized: Data = String.notAuthorized.json
    static let withEmptyTitle: Data = String.withEmptyTitle.json
    static let withEmptyText: Data = String.withEmptyText.json
    static let withEmptyAction: Data = String.withEmptyAction.json
    static let withEmptyPlatform: Data = String.withEmptyPlatform.json
    static let withEmptyVersion: Data = String.withEmptyVersion.json
    static let withEmptyLink: Data = String.withEmptyLink.json
    static let withNilAuthBlocking: Data = String.withNilAuthBlocking.json
    static let withNilTitle: Data = String.withNilTitle.json
    static let withNilText: Data = String.withNilText.json
    static let withNilAction: Data = String.withNilAction.json
    static let withNilPlatform: Data = String.withNilPlatform.json
    static let withNilVersion: Data = String.withNilVersion.json
    static let withNilLink: Data = String.withNilLink.json
    static let withNilAuthBlockingInOne: Data = String.withNilAuthBlockingInOne.json
    static let withNilTitleInOne: Data = String.withNilTitleInOne.json
    static let withNilTextInOne: Data = String.withNilTextInOne.json
    static let withNilUpdateInOne: Data = String.withNilUpdateInOne.json
    static let withNilActionInOne: Data = String.withNilActionInOne.json
    static let withNilPlatformInOne: Data = String.withNilPlatformInOne.json
    static let withNilVersionInOne: Data = String.withNilVersionInOne.json
    static let withNilLinkInOne: Data = String.withNilLinkInOne.json
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
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "categoryGroupList": []
  }
}
"""
    
    static let nullSerial = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": null,
        "notAuthorized": []
    }
}
"""
    
    static let nullNotAuthorizedList = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": null
    }
}
"""

    static let notAuthorized = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": true,
                "title": "Ой сломалось",
                "text": "Мы уже знаем о проблеме и работаем над её исправлением. Попробуйте зайти позже, а пока можете посмотреть наши продукты"
            },
            {
                "authBlocking": false,
                "title": "Внимание!",
                "text": "Вышло новое обновление! Обновитесь скорее!",
                "update": {
                    "action": "optional",
                    "platform": "iOS",
                    "version": "7.12.15",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""

    static let withEmptyTitle = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": true,
                "title": "",
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""

    static let withEmptyText = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": true,
                "title": "TITLE",
                "text": "",
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""
    
    static let withEmptyAction = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": true,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "",
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""
    
    static let withEmptyPlatform = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": true,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": "",
                    "version": "VERSION",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""

    static let withEmptyVersion = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": true,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": "",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""

    static let withEmptyLink = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": true,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": ""
                }
            }
        ]
    }
}
"""

    static let withNilAuthBlocking = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": null,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "optional",
                    "platform": "iOS",
                    "version": "7.12.15",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""

    static let withNilTitle = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": true,
                "title": null,
                "text": "TEXT",
                "update": {
                    "action": "optional",
                    "platform": "iOS",
                    "version": "7.12.15",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""

    static let withNilText = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": true,
                "title": "TITLE",
                "text": null,
                "update": {
                    "action": "optional",
                    "platform": "iOS",
                    "version": "7.12.15",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""
    
    static let withNilAction = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": true,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": null,
                    "platform": "iOS",
                    "version": "7.12.15",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""

    static let withNilPlatform = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": true,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "optional",
                    "platform": null,
                    "version": "7.12.15",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""

    static let withNilVersion = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": true,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "optional",
                    "platform": "iOS",
                    "version": null,
                    "link": "LINK"
                }
            }
        ]
    }
}
"""

    static let withNilLink = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": true,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "optional",
                    "platform": "iOS",
                    "version": "7.12.15",
                    "link": null
                }
            }
        ]
    }
}
"""

    static let withNilAuthBlockingInOne = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": null,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": "LINK"
                }
            },
            {
                "authBlocking": true,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""
    
    static let withNilTitleInOne = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": false,
                "title": null,
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": "LINK"
                }
            },
            {
                "authBlocking": false,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": "LINK"     
                }
            }
        ]
    }
}
"""
    
    static let withNilTextInOne = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": false,
                "title": "TITLE",
                "text": null,
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": "LINK"
                }
            },
            {
                "authBlocking": false,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""
    
    static let withNilUpdateInOne = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": false,
                "title": "TITLE",
                "text": "TEXT",
                "update": null
            },
            {
                "authBlocking": false,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""
    
    static let withNilActionInOne = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": false,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": null,
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": "LINK"
                }
            },
            {
                "authBlocking": false,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""
    
    static let withNilPlatformInOne = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": false,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": null,
                    "version": "VERSION",
                    "link": "LINK"
                }
            },
            {
                "authBlocking": false,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""
    
    static let withNilVersionInOne = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": false,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": null,
                    "link": "LINK"
                }
            },
            {
                "authBlocking": false,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""
    
    static let withNilLinkInOne = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "serial": "1bebd140bc2660211fbba306105479ae",
        "notAuthorized": [
            {
                "authBlocking": false,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": null
                }
            },
            {
                "authBlocking": false,
                "title": "TITLE",
                "text": "TEXT",
                "update": {
                    "action": "ACTION",
                    "platform": "iOS",
                    "version": "VERSION",
                    "link": "LINK"
                }
            }
        ]
    }
}
"""
}
