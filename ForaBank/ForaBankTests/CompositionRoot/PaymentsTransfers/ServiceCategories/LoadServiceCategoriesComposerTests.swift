//
//  LoadServiceCategoriesComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 25.08.2024.
//

import CombineSchedulers
import ForaTools
import Foundation

typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void

final class LoadServiceCategoriesComposer {
    
    private let getServiceCategoryList: NanoServices.GetServiceCategoryList
    
    init(
        collectionPeriod: DispatchTimeInterval,
        httpClient: HTTPClient,
        log: @escaping Log,
        backgroundScheduler: AnySchedulerOf<DispatchQueue>
    ) {
#warning("could be injected by higher level composer")
        let collectorBundler = RequestCollectorBundler(
            collectionPeriod: collectionPeriod,
            scheduler: backgroundScheduler,
            performRequest: httpClient.performRequest(_:completion:)
        )
        let debugNetworkLog = { log(.debug, .network, $0, $1, $2) }
        
        self.getServiceCategoryList = NanoServices.makeGetServiceCategoryList(
            httpClient: collectorBundler,
            log: debugNetworkLog
        )
    }
}

extension LoadServiceCategoriesComposer {
    
    typealias LoadServiceCategoriesCompletion = ([ServiceCategory]) -> Void
    typealias LoadServiceCategories = (@escaping LoadServiceCategoriesCompletion) -> Void
    
    func compose() -> LoadServiceCategories {
        
        // return { [weak self] completion in self?.load(completion) }
        return { self.load($0) }
    }
}

extension RequestCollectorBundler: HTTPClient
where Request == URLRequest,
      Response == Result<(Data, HTTPURLResponse), any Error> {
    
    public func performRequest(
        _ request: Request,
        completion: @escaping Completion
    ) {
        process(request, completion)
    }
}

private extension LoadServiceCategoriesComposer {
    
    func load(
        _ completion: @escaping LoadServiceCategoriesCompletion
    ) {
        getServiceCategoryList {
            
            let categories = (try? $0.get())?.categoryGroupList ?? []
            completion(categories)
        }
    }
}

@testable import ForaBank
import XCTest

final class LoadServiceCategoriesComposerTests: XCTestCase {
    
    func test_shouldPerformOneCallOnMultipleRequests() {
        
        let (sut, httpClient, scheduler) = makeSUT(
            collectionPeriod: .milliseconds(100)
        )
        
        sut { _ in  }
        sut { _ in  }
        sut { _ in  }
        sut { _ in  }
        
        scheduler.advance(to: .init(.now().advanced(by: .milliseconds(99))))
        
        XCTAssertEqual(httpClient.callCount, 0)
        
        scheduler.advance(to: .init(.now().advanced(by: .milliseconds(100))))
        
        XCTAssertEqual(httpClient.callCount, 1)
    }
    
    func test_shouldPerformOneCallOnMultipleRequestsSeparatedBySmallDelayWithinCollectionPeriod() {
        
        let (sut, httpClient, scheduler) = makeSUT(
            collectionPeriod: .milliseconds(200)
        )
        
        scheduler.advance(to: .init(.now().advanced(by: .milliseconds(50))))
        sut { _ in  }
        XCTAssertEqual(httpClient.callCount, 0)
        
        scheduler.advance(to: .init(.now().advanced(by: .milliseconds(100))))
        sut { _ in  }
        XCTAssertEqual(httpClient.callCount, 0)
        
        scheduler.advance(to: .init(.now().advanced(by: .milliseconds(150))))
        sut { _ in  }
        XCTAssertEqual(httpClient.callCount, 0)
        
        scheduler.advance(to: .init(.now().advanced(by: .milliseconds(200))))
        sut { _ in  }
        XCTAssertEqual(httpClient.callCount, 1)
    }
    
    func test_shouldPerformOneCallForCollectionPeriod() {
        
        let (sut, httpClient, scheduler) = makeSUT(
            collectionPeriod: .milliseconds(150)
        )
        
        scheduler.advance(to: .init(.now().advanced(by: .milliseconds(50))))
        sut { _ in  }
        XCTAssertEqual(httpClient.callCount, 0)
        
        scheduler.advance(to: .init(.now().advanced(by: .milliseconds(100))))
        sut { _ in  }
        XCTAssertEqual(httpClient.callCount, 0)
        
        scheduler.advance(to: .init(.now().advanced(by: .milliseconds(150))))
        sut { _ in  }
        XCTAssertEqual(httpClient.callCount, 1)
        
        httpClient.complete(with: .failure(anyNSError()))
        wait(timeout: 0.05) // wait for RequestBundler
        
        scheduler.advance(to: .init(.now().advanced(by: .milliseconds(200))))
        sut { _ in  }
        
        XCTExpectFailure("Need to find a bug.") {
         
            XCTAssertEqual(httpClient.callCount, 2)
        }
    }
    
    func test_shouldDeliverSameResponseForAllClients() {
        
        let valid = validData()
        let (sut, httpClient, scheduler) = makeSUT(
            collectionPeriod: .milliseconds(100)
        )
        var receivedCategories = [[ServiceCategory]]()
        
        sut { receivedCategories.append($0) }
        sut { receivedCategories.append($0) }
        
        scheduler.advance(to: .init(.now().advanced(by: .milliseconds(100))))
        
        httpClient.complete(with: .success((valid, anyHTTPURLResponse())))
        wait(timeout: 0.05) // wait for RequestBundler
        
        XCTAssertNoDiff(receivedCategories, [[.one], [.one]])
    }
    
    // TODO: add logging tests
    
    // MARK: - Helpers
    
    private typealias Composer = LoadServiceCategoriesComposer
    private typealias SUT = Composer.LoadServiceCategories
    
    private func makeSUT(
        collectionPeriod: DispatchTimeInterval,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let httpClient = HTTPClientSpy()
        let scheduler = DispatchQueue.test
        let composer = Composer(
            collectionPeriod: collectionPeriod,
            httpClient: httpClient,
            log: { _,_,_,_,_ in }, // TODO: add logging tests
            backgroundScheduler: scheduler.eraseToAnyScheduler()
        )
        let sut = composer.compose()
        
#warning("restore memory tracking")
                trackForMemoryLeaks(composer, file: file, line: line)
        // trackForMemoryLeaks(httpClient, file: file, line: line)
        // trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, httpClient, scheduler)
    }
    
    private func validData() -> Data {
        
        let json = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "1bebd140bc2660211fbba306105479ae",
    "categoryGroupList": [
      {
        "type": "mobile",
        "name": "Мобильная связь",
        "ord": 20,
        "md5hash": "c16ee4f2d0b7cea6f8b92193bccce4d7",
        "paymentFlow": "MOBILE",
        "latestPaymentsCategory": "isMobilePayments",
        "search": false
      }
    ]
  }
}
"""
        return .init(json.utf8)
    }
}

private extension ServiceCategory {
    
    static let one: Self = .init(
        latestPaymentsCategory: .mobile,
        md5Hash: "c16ee4f2d0b7cea6f8b92193bccce4d7",
        name: "Мобильная связь",
        ord: 20,
        paymentFlow: .mobile,
        search: false,
        type: .mobile
    )
}
