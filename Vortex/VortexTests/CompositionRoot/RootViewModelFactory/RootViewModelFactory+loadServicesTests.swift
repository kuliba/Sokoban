//
//  RootViewModelFactory+loadServicesTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 28.12.2024.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_loadServicesTests: RootViewModelFactoryTests {
    
    func test_shouldCallHTTPClientWithGetOperatorsListByParamRequest() {
        
        let payload = makePayload()
        let (sut, httpClient, _) = makeSUT()
        XCTAssertEqual(httpClient.callCount, 0)
        
        sut.loadServices(for: payload) { _ in }
        
        XCTAssertNoDiff(
            httpClient.lastPathComponentsWithQueryValue(for: ""),
            ["getOperatorsListByParam"]
        )
    }
    
    func test_shouldCallHTTPClientWithPayload() {
        
        let payload = makePayload()
        let (sut, httpClient, _) = makeSUT()
        XCTAssertEqual(httpClient.callCount, 0)
        
        sut.loadServices(for: payload) { _ in }
        
        XCTAssertNoDiff(
            httpClient.lastPathComponentsWithQueryValue(for: "customerId"),
            ["getOperatorsListByParam-\(payload.operatorID)"]
        )
        XCTAssertNoDiff(
            httpClient.lastPathComponentsWithQueryValue(for: "type"),
            ["getOperatorsListByParam-\(payload.type)"]
        )
    }
    
    func test_shouldDeliverEmptyOnHTTPClientFailure() {
        
        let payload = makePayload()
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.loadServices(for: payload) {
            
            XCTAssert($0.isEmpty)
            exp.fulfill()
        }
        
        httpClient.complete(with: anyError())
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverEmptyOnHTTPClientSuccessEmpty() {
        
        let payload = makePayload()
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.loadServices(for: payload) {
            
            XCTAssertNoDiff($0, [])
            exp.fulfill()
        }
        
        httpClient.complete(withString: .emptyServicesValidJSON)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverSingleOnHTTPClientSuccessSingle() {
        
        let payload = makePayload()
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.loadServices(for: payload) {
            
            XCTAssertNoDiff($0, [self.singleService()])
            exp.fulfill()
        }
        
        httpClient.complete(withString: .singleServiceValidJSON)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverMultipleOnHTTPClientSuccessMultiple() {
        
        let payload = makePayload()
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.loadServices(for: payload) {
            
            XCTAssertNoDiff($0, self.multiServices())
            exp.fulfill()
        }
        
        httpClient.complete(withString: .multiServicesValidJSON)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private typealias Payload = RootViewModelFactory.GetServicesForPayload
    
    private func makePayload(
        operatorID: String = anyMessage(),
        type: String = anyMessage()
    ) -> Payload {
        
        return .init(operatorID: operatorID, type: type)
    }
    
    private func singleService() -> ServicePickerItem {
        
        return .init(
            service: .init(
                icon: "ef7a4271cdec35cc20c4ca0bb4d43f93",
                name: "КАПРЕМОНТ (Р/С ...00024)",
                puref: "iVortexNKORR||42358"
            ),
            isOneOf: false
        )
    }
    
    private func multiServices() -> [ServicePickerItem] {
        
        return [
            .init(
                service: .init(
                    icon: "ef7a4271cdec35cc20c4ca0bb4d43f93", 
                    name: "КОММУНАЛЬНЫЕ УСЛУГИ-МИРНАЯ 3",
                    puref: "iVortexNKORR||55177"
                ),
                isOneOf: true
            ),
            .init(
                service: .init(
                    icon: "ef7a4271cdec35cc20c4ca0bb4d43f93", 
                    name: "КОММУНАЛЬНЫЕ УСЛУГИ-БУРАШЕВСКОЕ Ш 62",
                    puref: "iVortexNKORR||66659"
                ),
                isOneOf: true
            ),
        ]
    }
}

extension HTTPClientSpy {
    
    func complete(
        withString string: String,
        response: HTTPURLResponse = anyHTTPURLResponse(),
        at index: Int = 0
    ) {
        complete(with: (.init(string.utf8), response), at: index)
    }
}

extension String {
    
    static let emptyServicesValidJSON = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "83216ac357627f84faccbf9438504370",
    "operatorList": [
      {
        "type": "housingAndCommunalService",
        "atributeList": []
      }
    ]
  }
}
"""
    
    static let singleServiceValidJSON = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "83216ac357627f84faccbf9438504370",
    "operatorList": [
      {
        "type": "housingAndCommunalService",
        "atributeList": [
          {
            "md5hash": "ef7a4271cdec35cc20c4ca0bb4d43f93",
            "juridicalName": "ООО ПИК-КОМФОРТ",
            "customerId": "8798",
            "serviceList": [
              {
                "channel": "iVortexNKORR",
                "protocol": "42358",
                "descr": "КАПРЕМОНТ (Р/С ...00024)"
              }
            ],
            "inn": "7701208190"
          }
        ]
      }
    ]
  }
}
"""
    
    static let multiServicesValidJSON = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "45b51b783a5a629eafd41c45b7413a3e",
    "operatorList": [
      {
        "type": "housingAndCommunalService",
        "atributeList": [
          {
            "md5hash": "ef7a4271cdec35cc20c4ca0bb4d43f93",
            "juridicalName": "ООО УК КОТИАРА",
            "customerId": "2792",
            "serviceList": [
              {
                "channel": "iVortexNKORR",
                "protocol": "55177",
                "descr": "КОММУНАЛЬНЫЕ УСЛУГИ-МИРНАЯ 3"
              },
              {
                "channel": "iVortexNKORR",
                "protocol": "66659",
                "descr": "КОММУНАЛЬНЫЕ УСЛУГИ-БУРАШЕВСКОЕ Ш 62"
              }
            ],
            "inn": "6950220774"
          }
        ]
      }
    ]
  }
}
"""
}
