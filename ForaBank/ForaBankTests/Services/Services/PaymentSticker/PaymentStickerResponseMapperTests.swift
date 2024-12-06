//
//  PaymentStickerResponseMapperTests.swift
//  VortexTests
//
//  Created by Дмитрий Савушкин on 01.11.2023.
//

import XCTest
@testable import ForaBank

final class PaymentStickerResponseMapperTests: XCTestCase {
        
    func test_validResponse_shouldReturnStickerDictionary() throws {
        
        let json = try getJSON(from: "StickerOrderForm")
        let responseOK = anyHTTPURLResponse()
        
        let result = ResponseMapper.mapStickerDictionaryResponse(
            json,
            responseOK
        )
        
        XCTAssertEqual(
            result,
            .success(.orderForm(.init(
                header: [.pageTitle],
                main: [
                    .hint,
                    .banner,
                    .productSelect,
                    .separator,
                    .delivery,
                    .endSeparator
                ],
                footer: [],
                serial: "051a8c3dd042a7e02fdcc27d02b067a5"
            ))))
    }
    
    func test_validResponse_shouldReturnStickerOrderDeliveryCourier() throws {
        
        let json = try getJSON(from: "StickerOrderDeliveryCourier")
        let responseOK = anyHTTPURLResponse()
        
        let result = ResponseMapper.mapStickerDictionaryResponse(
            json,
            responseOK
        )
        
        XCTAssertEqual(
            result,
            .success(.deliveryType(.init(
                main: [
                    .separator,
                    .citySelector,
                    .endSeparator
                ],
                serial: "2c40ceed25158964529f8500a49e096d"
            ))))
    }
    
    func test_validResponse_shouldReturnStickerOrderDeliveryOffice() throws {
        
        let json = try getJSON(from: "StickerDeliveryOffice")
        let responseOK = anyHTTPURLResponse()
        
        let result = ResponseMapper.mapStickerDictionaryResponse(
            json,
            responseOK
        )
        
        XCTAssertEqual(
            result,
            .success(.deliveryType(.init(
                main: [
                    .separator,
                    .citySelector,
                    .separatorSubGroup,
                    .officeSelector,
                    .endSeparator
                ],
                serial: "1628aa7e604f917f1ed4fe214187c81a"
            ))))
    }
}

//MARK: Helpers

private extension StickerDictionaryResponse.Main {
    
    static let separator = Self.init(type: .separator, data: .separator(.init(color: "#F6F6F7")))
    static let endSeparator = Self.init(type: .endSeparator, data: .separator(.init(color: "#F6F6F7")))
    static let citySelector = Self.init(type: .citySelector, data: .citySelector(
        .init(
            title: "Выберите город",
            subtitle: "Поиск по городам",
            isCityList: true,
            md5hash: "59cab489ad1a9b209d23da59182467d1"
        )))
    static let separatorSubGroup = Self.init(type: .separatorSubGroup, data: .separatorGroup)
    
    static let officeSelector = Self.init(type: .officeSelector, data: .officeSelector(.init(
        title: "Выберите отделение",
        subtitle: "Поиск по городам",
        md5hash: "c9a79500ff29bab6251e474112e7da47"
    )))
    
    static let hint = Self.init(type: .textsWithIconHorizontal, data: .hint(.init(
        title: "Выберите счет карты, к которому будет привязан стикер",
        md5hash: "472c6bf19f04641f277d838797288bfa",
        contentCenterAndPull: false
    )))
    
    static let banner = Self.init(type: .productInfo, data: .banner(.init(
        title: "Платежный стикер",
        subtitle: "Стоимость обслуживания взимается единоразово за весь срок при заказе стикера ",
        currencyCode: 810,
        currency: "RUB",
        md5hash: "66148dfe4f00acfbf08da9ddf07cabff",
        txtConditionList: [.init(
            name: "При получении в офисе",
            description: "",
            value: 790
        ), .init(
            name: "При доставке курьером",
            description: "",
            value: 1500
        )]))
    )
    
    static let productSelect = Self.init(type: .productSelect, data: .product(.init(withoutPadding: true)))
    
    static let delivery = Self.init(type: .selector, data: .selector(.init(
        
        title: "Выберите способ доставки",
        subtitle: "Выберите значение",
        md5hash: "8a7af0edd29b167bf02c7ba17153d2a6",
        list: [.init(
            type: .typeDeliveryOffice,
            md5hash: "1a1d2457d9fea470354bef35a6eb48eb",
            title: "Получить в офисе",
            backgroundColor: "#94BCFF",
            value: 790
        ), .init(
            type: .typeDeliveryCourier,
            md5hash: "f15e0a6e625980de374b4fc14df5e8f4",
            title: "Доставка курьером",
            backgroundColor: "#B39CDB",
            value: 1500
        )]))
    )
}

private extension StickerDictionaryResponse.StickerOrderForm.Header {
    
    static let pageTitle = Self.init(type: .pageTitle, data: .init(
        title: "Оформление заявки",
        isFixed: true
    ))
}

