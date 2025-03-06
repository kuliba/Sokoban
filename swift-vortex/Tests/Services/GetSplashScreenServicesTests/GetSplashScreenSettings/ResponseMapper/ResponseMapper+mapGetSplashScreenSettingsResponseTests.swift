//
//  ResponseMapper+mapGetSplashScreenSettingsResponseTests.swift
//
//
//  Created by Igor Malyarov on 06.03.2025.
//

import GetSplashScreenServices
import RemoteServices
import XCTest

final class ResponseMapper_mapGetSplashScreenSettingsResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidFailure_onEmptyData() {
        
        let emptyData: Data = .empty
        
        XCTAssertNoDiff(
            map(emptyData),
            .failure(.invalid(statusCode: 200, data: emptyData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onInvalidData() {
        
        let invalidData: Data = .invalidData
        
        XCTAssertNoDiff(
            map(invalidData),
            .failure(.invalid(statusCode: 200, data: invalidData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onEmptyJSON() {
        
        let emptyJSON: Data = .emptyJSON
        
        XCTAssertNoDiff(
            map(emptyJSON),
            .failure(.invalid(statusCode: 200, data: emptyJSON))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onEmptyDataResponse() {
        
        let emptyDataResponse: Data = .emptyDataResponse
        
        XCTAssertNoDiff(
            map(emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: emptyDataResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onNullServerResponse() {
        
        let nullServerResponse: Data = .nullServerResponse
        
        XCTAssertNoDiff(
            map(.nullServerResponse),
            .failure(.invalid(statusCode: 200, data: nullServerResponse))
        )
    }
    
    func test_map_shouldDeliverServerError_onServerError() {
        
        XCTAssertNoDiff(
            map(.serverError),
            .failure(.server(
                statusCode: 102,
                errorMessage: "Возникла техническая ошибка"
            ))
        )
    }
    
    func test_map_shouldDeliverInvalidFailure_onNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(.validData, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: .validData))
            )
        }
    }
    
    func test_map_shouldDeliverResponse_onValidData() throws {
        
        XCTAssertNoDiff(map(.validData), .success(.init(
            list: [
                .night3,
                .morning2,
                .day4,
                .evening1,
            ],
            serial: "26077d6c95a1fde70bfee4a05402f340"
        )))
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.GetSplashScreenSettingsResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapGetSplashScreenSettingsResponse(data, httpURLResponse)
    }
}

private extension ResponseMapper.SplashScreenSettings {
    
    static let day4: Self = .init(
        link: "/products/splash/DAY4.png",
        viewDuration: 10000,
        hasAnimation: true,
        bankLogo: .init(
            color: "#000000",
            shadow: .init(
                x: 10,
                y: 0,
                blur: 10,
                color: "#FFFFFF",
                opacity: 50
            )
        ),
        text: .init(
            color: "#000000",
            size: 24,
            value: "Добрый день, (заставка для отладки цветов и теней!",
            shadow: .init(
                x: 0,
                y: 4,
                blur: 12,
                color: "#FFFFFF",
                opacity: 25
            )
        ),
        background: .init(
            hasBackground: true,
            color: "#000000",
            opacity: 25
        ),
        subtext: .init(
            color: "#00000",
            size: 18,
            value: "Test test test",
            shadow: .init(
                x: 0,
                y: 4,
                blur: 12,
                color: "#1C1C1C",
                opacity: 25
            )
        ),
        bankName: .init(
            color: "#000000",
            shadow: .init(
                x: 25,
                y: 25,
                blur: 0,
                color: "#FFFFFF",
                opacity: 25
            )
        )
    )
    static let evening1: Self = .init(
        link: "/products/splash/EVENING1.png",
        viewDuration: 3000,
        hasAnimation: true,
        bankLogo: .init(
            color: "#FFFFFF",
            shadow: .init(
                x: 0,
                y: 4,
                blur: 64,
                color: "#000000",
                opacity: 25
            )
        ),
        text: .init(
            color: "#FFFFFF",
            size: 24,
            value: "Добрый вечер!",
            shadow: .init(
                x: 0,
                y: 4,
                blur: 12,
                color: "#000000",
                opacity: 25
            )
        ),
        background: .init(
            hasBackground: false
        ),
        subtext: .init(
            color: "#FFFFFF",
            size: 18,
            shadow: .init(
                x: 0,
                y: 4,
                blur: 12,
                color: "#1C1C1C",
                opacity: 25
            )
        ),
        bankName: .init(
            color: "#FFFFFF",
            shadow: .init(
                x: 0,
                y: 4,
                blur: 4,
                color: "#000000",
                opacity: 25
            )
        )
    )
    static let morning2: Self = .init(
        link: "/products/splash/MORNING2.png",
        viewDuration: 3000,
        hasAnimation: true,
        bankLogo: .init(
            color: "#FFFFFF",
            shadow: .init(
                x: 0,
                y: 4,
                blur: 64,
                color: "#000000",
                opacity: 25
            )
        ),
        text: .init(
            color: "#FFFFFF",
            size: 24,
            value: "Доброе утро!",
            shadow: .init(
                x: 0,
                y: 4,
                blur: 12,
                color: "#000000",
                opacity: 25
            )
        ),
        background: .init(
            hasBackground: false
        ),
        subtext: .init(
            color: "#FFFFFF",
            size: 18,
            shadow: .init(
                x: 0,
                y: 4,
                blur: 12,
                color: "#1C1C1C",
                opacity: 25
            )
        ),
        bankName: .init(
            color: "#FFFFFF",
            shadow: .init(
                x: 0,
                y: 4,
                blur: 4,
                color: "#000000",
                opacity: 25
            )
        )
    )
    static let night3: Self = .init(
        link: "/products/splash/NIGHT3.png",
        viewDuration: 3000,
        hasAnimation: true,
        bankLogo: .init(
            color: "#FFFFFF",
            shadow: .init(
                x: 0,
                y: 4,
                blur: 64,
                color: "#000000",
                opacity: 25
            )
        ),
        text: .init(
            color: "#FFFFFF",
            size: 24,
            value: "Доброй ночи!",
            shadow: .init(
                x: 0,
                y: 4,
                blur: 12,
                color: "#000000",
                opacity: 25
            )
        ),
        background: .init(
            hasBackground: false
        ),
        subtext: .init(
            color: "#FFFFFF",
            size: 18,
            shadow: .init(
                x: 0,
                y: 4,
                blur: 12,
                color: "#1C1C1C",
                opacity: 25
            )
        ),
        bankName: .init(
            color: "#FFFFFF",
            shadow: .init(
                x: 0,
                y: 4,
                blur: 4,
                color: "#000000",
                opacity: 25
            )
        )
    )
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    static let validData: Data = String.validData.json
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
    
    static let validData = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "26077d6c95a1fde70bfee4a05402f340",
    "splash": [
      {
        "link": "/products/splash/NIGHT3.png",
        "viewDuration": 3000,
        "hasAnimation": true,
        "bankLogo": {
          "color": "#FFFFFF",
          "shadow": {
            "x": 0,
            "y": 4,
            "blur": 64,
            "color": "#000000",
            "opacity": 25
          }
        },
        "text": {
          "color": "#FFFFFF",
          "size": 24,
          "value": "Доброй ночи!",
          "shadow": {
            "x": 0,
            "y": 4,
            "blur": 12,
            "color": "#000000",
            "opacity": 25
          }
        },
        "background": {
          "hasBackground": false
        },
        "subtext": {
          "color": "#FFFFFF",
          "size": 18,
          "shadow": {
            "x": 0,
            "y": 4,
            "blur": 12,
            "color": "#1C1C1C",
            "opacity": 25
          }
        },
        "bankName": {
          "color": "#FFFFFF",
          "shadow": {
            "x": 0,
            "y": 4,
            "blur": 4,
            "color": "#000000",
            "opacity": 25
          }
        }
      },
      {
        "link": "/products/splash/MORNING2.png",
        "viewDuration": 3000,
        "hasAnimation": true,
        "bankLogo": {
          "color": "#FFFFFF",
          "shadow": {
            "x": 0,
            "y": 4,
            "blur": 64,
            "color": "#000000",
            "opacity": 25
          }
        },
        "text": {
          "color": "#FFFFFF",
          "size": 24,
          "value": "Доброе утро!",
          "shadow": {
            "x": 0,
            "y": 4,
            "blur": 12,
            "color": "#000000",
            "opacity": 25
          }
        },
        "background": {
          "hasBackground": false
        },
        "subtext": {
          "color": "#FFFFFF",
          "size": 18,
          "shadow": {
            "x": 0,
            "y": 4,
            "blur": 12,
            "color": "#1C1C1C",
            "opacity": 25
          }
        },
        "bankName": {
          "color": "#FFFFFF",
          "shadow": {
            "x": 0,
            "y": 4,
            "blur": 4,
            "color": "#000000",
            "opacity": 25
          }
        }
      },
      {
        "link": "/products/splash/DAY4.png",
        "viewDuration": 10000,
        "hasAnimation": true,
        "bankLogo": {
          "color": "#000000",
          "shadow": {
            "x": 10,
            "y": 0,
            "blur": 10,
            "color": "#FFFFFF",
            "opacity": 50
          }
        },
        "text": {
          "color": "#000000",
          "size": 24,
          "value": "Добрый день, (заставка для отладки цветов и теней!",
          "shadow": {
            "x": 0,
            "y": 4,
            "blur": 12,
            "color": "#FFFFFF",
            "opacity": 25
          }
        },
        "background": {
          "hasBackground": true,
          "color": "#000000",
          "opacity": 25
        },
        "subtext": {
          "color": "#00000",
          "size": 18,
          "value": "Test test test",
          "shadow": {
            "x": 0,
            "y": 4,
            "blur": 12,
            "color": "#1C1C1C",
            "opacity": 25
          }
        },
        "bankName": {
          "color": "#000000",
          "shadow": {
            "x": 25,
            "y": 25,
            "blur": 0,
            "color": "#FFFFFF",
            "opacity": 25
          }
        }
      },
      {
        "link": "/products/splash/EVENING1.png",
        "viewDuration": 3000,
        "hasAnimation": true,
        "bankLogo": {
          "color": "#FFFFFF",
          "shadow": {
            "x": 0,
            "y": 4,
            "blur": 64,
            "color": "#000000",
            "opacity": 25
          }
        },
        "text": {
          "color": "#FFFFFF",
          "size": 24,
          "value": "Добрый вечер!",
          "shadow": {
            "x": 0,
            "y": 4,
            "blur": 12,
            "color": "#000000",
            "opacity": 25
          }
        },
        "background": {
          "hasBackground": false
        },
        "subtext": {
          "color": "#FFFFFF",
          "size": 18,
          "shadow": {
            "x": 0,
            "y": 4,
            "blur": 12,
            "color": "#1C1C1C",
            "opacity": 25
          }
        },
        "bankName": {
          "color": "#FFFFFF",
          "shadow": {
            "x": 0,
            "y": 4,
            "blur": 4,
            "color": "#000000",
            "opacity": 25
          }
        }
      }
    ]
  }
}
"""
}
