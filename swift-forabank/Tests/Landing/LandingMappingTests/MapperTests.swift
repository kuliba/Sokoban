//
//  MapperTests.swift
//  
//
//  Created by Andryusina Nataly on 29.08.2023.
//

@testable import LandingMapping
import XCTest

final class MapperTests: XCTestCase {
    
    func test_map_statusCode200_LandingNotNil() throws {
        
        let landing = try XCTUnwrap(map(statusCode: 200).get())
        
        XCTAssertNotNil(landing)
    }
    
    func test_map_statusCodeNot200_FailureNotOk() throws {
        
        let landing = try XCTUnwrap(map(statusCode: 400))
        
        XCTAssertNoDiff(landing, .failure(.notOkStatus))
    }
    
    func test_map_deliversSerial() throws {
        
        let landing = try XCTUnwrap(map().get())
        
        XCTAssertNoDiff(landing.serial, "41c44e57adfeb9af7535139c495dd181")
    }
    
    func test_map_deliversHeader() throws {
        
        let landing = try XCTUnwrap(map().get())
        
        XCTAssertNoDiff(landing.header, [
            .init(
                type: .pageTitle,
                data: .init(
                    text: "Переводы за рубеж",
                    transparency: true)
            )])
    }
    
    func test_map_deliversMain() throws {
        
        let landing = try XCTUnwrap(map().get())
        
        XCTAssertNoDiff(landing.main, [
            .empty,
            .multiLineHeader(
                .init(
                    backgroundColor: "WHITE",
                    regularTextList: ["Переводы"],
                    boldTextList: ["за рубеж"])
            ),
            .multiTextsWithIconsHorizontalArray([
                .init(
                    md5hash:"a442191010ad33a883625f93d91037b1",
                    title:"Быстро"
                ),
                .init(
                    md5hash:"7df826030e8d418be0a33edde3a26ad0",
                    title:"Безопасно"
                ),
                .init(
                    md5hash:"5d9427225e136f31d26a211b9207dc3b",
                    title:"Выгодно"
                )
            ]),
            .listHorizontalRoundImage(
                .init(
                    title: "Популярные направления",
                    list: [
                        .init(
                            md5hash:"6046e5eaff596a41ce9845cca3b0a887",
                            title:"Армения",
                            subInfo:"1%",
                            details:
                                    .init(
                                        detailsGroupId:"forCountriesList",
                                        detailViewId:"Armeniya"
                                    )
                        )]
                ))])
    }
    
    func test_map_deliversDetail() throws {
        
        let landing = try XCTUnwrap(map().get())
        
        XCTAssertNoDiff(landing.details, [
            .init(
                detailsGroupId: "bannersLanding",
                dataGroup: [
                    .init(
                        detailViewId: "moreTransfers",
                        dataView: [
                            .iconWithTwoTextLines(
                                .init(
                                    md5hash: "6046e5eaff596a41ce9845cca3b0a887",
                                    title: "Больше возможностей при переводах в Армению",
                                    subTitle: nil)),
                            .textsWithIconHorizontal(
                                .init(
                                    md5hash: "411d86beb3c9e68dfd8dd46bd544ea49",
                                    title: "Теперь до 1 000 000 ₽",
                                    contentCenterAndPull: true))
                        ])
                ])])
    }
    
    // MARK: - Helpers
    typealias Result = Swift.Result<Landing, LandingMapper.MapperError>
    
    private func map(
        statusCode: Int = 200,
        data: Data = Data(String.multiLineHeader.utf8)
    ) -> Result {
        
        let decodableLanding = LandingMapper.map(
            data,
            anyHTTPURLResponse(statusCode)
        )
        return decodableLanding
    }
    
    private func anyHTTPURLResponse(
        _ statusCode: Int = 200
    ) -> HTTPURLResponse {
        
        .init(
            url: URL(string: "https://www.forabank.ru/")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil)!
    }
}

private extension String {
    
    static let multiLineHeader: Self = """
{
   "data":{
      "header":[
         {
            "type":"PAGE_TITLE",
            "data":{
               "text":"Переводы за рубеж",
               "transparency":true
            }
         }
      ],
      "main":[
        {
            "type": "IMAGE",
            "data": {
                "isPlaceholder": false,
                "imageLink": "dict/getProductCatalogImage?image=/products/banners/Header_abroad.png",
                "backgroundColor": "WHITE"
            }
        },
         {
            "type":"MULTI_LINE_HEADER",
            "data":{
               "backgroundColor":"WHITE",
               "regularTextList":[
                  "Переводы"
               ],
               "boldTextList":[
                  "за рубеж"
               ]
            }
         },
         {
            "type":"MULTI_TEXTS_WITH_ICONS_HORIZONTAL",
            "data":[
               {
                  "md5hash":"a442191010ad33a883625f93d91037b1",
                  "title":"Быстро"
               },
               {
                  "md5hash":"7df826030e8d418be0a33edde3a26ad0",
                  "title":"Безопасно"
               },
               {
                  "md5hash":"5d9427225e136f31d26a211b9207dc3b",
                  "title":"Выгодно"
               }
            ]
         },
         {
            "type":"LIST_HORIZONTAL_ROUND_IMAGE",
            "data":{
               "title":"Популярные направления",
               "list":[
                  {
                     "md5hash":"6046e5eaff596a41ce9845cca3b0a887",
                     "title":"Армения",
                     "subInfo":"1%",
                     "details":{
                        "detailsGroupId":"forCountriesList",
                        "detailViewId":"Armeniya"
                     }
                  }
               ]
            }
         }
      ],
      "footer":[
         
      ],
      "details":[
         {
            "detailsGroupId":"bannersLanding",
            "dataGroup":[
               {
                  "detailViewId":"moreTransfers",
                  "dataView":[
                     {
                        "type":"ICON_WITH_TWO_TEXT_LINES",
                        "data":{
                           "md5hash":"6046e5eaff596a41ce9845cca3b0a887",
                           "title":"Больше возможностей при переводах в Армению"
                        }
                     },
                     {
                        "type":"TEXTS_WITH_ICON_HORIZONTAL",
                        "data":{
                           "md5hash":"411d86beb3c9e68dfd8dd46bd544ea49",
                           "title":"Теперь до 1 000 000 ₽",
                           "contentCenterAndPull":true
                        }
                     }
                  ]
               }
            ]
         }
      ],
      "serial":"41c44e57adfeb9af7535139c495dd181"
   }
}
"""
}
