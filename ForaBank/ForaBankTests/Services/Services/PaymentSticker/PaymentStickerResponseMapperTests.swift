//
//  PaymentStickerResponseMapperTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 01.11.2023.
//

import XCTest
@testable import ForaBank

final class PaymentStickerResponseMapperTests: XCTestCase {
    
    typealias StickerDictionary = ResponseMapper.StickerDictionary
    typealias StickerDictionaryError = ResponseMapper.StickerDictionaryError
    typealias StickerDictionaryResult = Result<StickerDictionary, StickerDictionaryError>
    
    let bundle = Bundle(for: PaymentStickerResponseMapperTests.self)
    
    func test_validResponse_shouldReturnStickerDictionary() {
     
        guard let url = bundle.url(forResource: "StickerOrderForm", withExtension: "json"),
              let json = try? Data(contentsOf: url) else {
            XCTFail("testResponseMapperStickerDictionary_Decoding : Missing file: StickerOrderForm.json")
            return
        }
        
        let map = ResponseMapper.mapStickerDictionaryResponse(
            json,
            .init(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
        )

        print(map)
    }
    
    func test_validResponse_shouldReturnStickerOrderDeliveryCourier() {
     
        guard let url = bundle.url(forResource: "StickerOrderDeliveryCourier", withExtension: "json"),
              let json = try? Data(contentsOf: url) else {
            XCTFail("testResponseMapperStickerOrderDeliveryCourier_Decoding : Missing file: StickerOrderDeliveryCourier.json")
            return
        }
        
        let map = ResponseMapper.mapStickerDictionaryResponse(
            json,
            .init(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
        )
        
        print(map)
    }
    
    func test_validResponse_shouldReturnStickerOrderDeliveryOffice() {
     
        guard let url = bundle.url(forResource: "StickerDeliveryOffice", withExtension: "json"),
              let json = try? Data(contentsOf: url) else {
            XCTFail("testResponseMapperStickerOrderDeliveryOffice_Decoding : Missing file: StickerDeliveryOffice.json")
            return
        }
        
        let map = ResponseMapper.mapStickerDictionaryResponse(
            json,
            .init(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
        )
        
        print(map)
    }
}
