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
        
        let landing = try XCTUnwrap(map(statusCode: 200))
        
        XCTAssertNotNil(landing)
    }
    
    func test_map_statusCodeNot200_FailureNotOk() throws {
        
        let landing = try XCTUnwrap(map(statusCode: 400))
        
        XCTAssertNoDiff(landing, .failure(.notOkStatus))
    }
    
    func test_map_statusCode200_dataNotValid_FailureMapError() throws {
        
        let landing = try XCTUnwrap(map(statusCode: 200, data: Data("test".utf8)))
        
        XCTAssertNoDiff(landing, .failure(.mapError))
    }
    
    func test_map_statusCode200_dataEmpty() throws {
        
        let landing = try XCTUnwrap(map(data: Data(String.emptySample.utf8)))
        
        XCTAssertNoDiff(landing.header, [])
        XCTAssertNoDiff(landing.main, [])
        XCTAssertNoDiff(landing.footer, [])
        XCTAssertNoDiff(landing.details, [])
        XCTAssertNoDiff(landing.serial, "abc")
    }
    
    func test_map_deliversSerial() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.serial, "41")
    }
    
    func test_map_deliversHeader() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.header, [
            .pageTitle(.init(
                text: "a",
                subtitle: nil,
                transparency: true))
        ])
    }
    
    func test_map_deliversMultiLineHeadersInMain() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.main.multiLineHeaders, [
            .init(
                backgroundColor: "w",
                regularTextList: ["a"],
                boldTextList: ["b"])
        ])
    }
    
    func test_map_deliversMultiTextsHeadersInMain() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.main.multiTexts, [
            .init(text: ["a"])
        ])
    }
    
    func test_map_deliversMultiMarkersTextsInMain() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.main.multiMarkersTexts, [
            .init(
                backgroundColor: "g",
                style: "p",
                list: ["а", "б", "в"]
            )
        ])
    }
    
    func test_map_deliversMuiltiTextsWithIconsHorizontalsInMain() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.main.muiltiTextsWithIconsHorizontals, [
            .init(list:[
                .init(md5hash:"a", title:"b"),
                .init(md5hash:"c", title:"d"),
                .init(md5hash:"e", title:"f")
            ])
        ])
    }
    
    func test_map_deliversListVerticalRoundImagesInMain() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.main.listVerticalRoundImages, [
            .init(
                title: "a",
                displayedCount: 5.0,
                dropButtonOpenTitle: "b",
                dropButtonCloseTitle: "c",
                list: [
                    .init(
                        md5hash: "87",
                        title: "a",
                        subInfo: nil,
                        link: nil,
                        appStore: nil,
                        googlePlay: nil,
                        detail: .init(groupId: "b", viewId: "c")
                    )
                ]
            )
        ])
    }
    
    func test_map_deliversListHorizontalRoundImagesInMain() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.main.listHorizontalRoundImages, [
            .init(
                title: "a",
                list: [
                    .init(
                        md5hash:"60",
                        title:"a",
                        subInfo:"1%",
                        details: .init(groupId:"b", viewId:"c")
                    )]
            )
        ])
    }
    
    func test_map_deliversListHorizontalRectangleImagesInMain() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.main.listHorizontalRectangleImages, [
            .init(list: [
                .init(
                    imageLink: "link",
                    link: "a",
                    detail: .init(groupId: "b", viewId: "z")
                ),
                .init(
                    imageLink: "link1",
                    link: "a",
                    detail: .init(groupId: "b", viewId: "c")
                )
            ])
        ])
    }
    
    func test_map_deliversAll() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.details.count, 1)
        XCTAssertNoDiff(landing.header.count, 1)
        XCTAssertNoDiff(landing.main.count, 7)
        XCTAssertNoDiff(landing.footer.count, 1)
    }
    
    func test_map_deliversDetail() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.details, [
            .init(
                groupId: "b",
                dataGroup: [
                    .init(
                        viewId: "c",
                        dataView: [
                            .iconWithTwoTextLines(
                                .init(
                                    md5hash: "60",
                                    title: "d",
                                    subTitle: nil)),
                            .textsWithIconHorizontal(
                                .init(
                                    md5hash: "41",
                                    title: "f",
                                    contentCenterAndPull: true))
                        ])
                ])])
    }
    
    func test_map_deliversFooter() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.footer, [
            .pageTitle(.init(
                text: "Footer",
                subtitle: nil,
                transparency: true))
        ])
    }
    
    // MARK: - Helpers
    
    typealias Result = Swift.Result<Landing, LandingMapper.MapperError>
    
    private func map(
        data: Data = Data(String.sample.utf8)
    ) throws -> Landing {
        
        let decodableLanding = LandingMapper.map(
            data,
            anyHTTPURLResponse(200)
        )
        return try decodableLanding.get()
    }
    
    private func map(
        statusCode: Int,
        data: Data = Data(String.sample.utf8)
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
    
    static let emptySample = """
{
    "data": {
        "header": [],
        "main": [],
        "footer": [],
        "details": [],
        "serial": "abc"
    }
}
"""
    static let sample: Self = """
{
   "data":{
      "header":[
         {
            "type":"PAGE_TITLE",
            "data":{
               "text":"a",
               "transparency":true
            }
         }
      ],
      "main":[
        {
            "type": "IMAGE",
            "data": {
                "isPlaceholder": false,
                "imageLink": "link",
                "backgroundColor": "w"
            }
        },
         {
            "type":"MULTI_LINE_HEADER",
            "data":{
               "backgroundColor":"w",
               "regularTextList":[
                  "a"
               ],
               "boldTextList":[
                  "b"
               ]
            }
         },
         {
            "type":"MULTI_TEXTS_WITH_ICONS_HORIZONTAL",
            "data":[
               {
                  "md5hash":"a",
                  "title":"b"
               },
               {
                  "md5hash":"c",
                  "title":"d"
               },
               {
                  "md5hash":"e",
                  "title":"f"
               }
            ]
         },
         {
            "type":"LIST_HORIZONTAL_ROUND_IMAGE",
            "data":{
               "title":"a",
               "list":[
                  {
                     "md5hash":"60",
                     "title":"a",
                     "subInfo":"1%",
                     "details":{
                        "detailsGroupId":"b",
                        "detailViewId":"c"
                     }
                  }
               ]
            }
         },
      {
        "type": "LIST_HORIZONTAL_RECTANGLE_IMAGE",
        "data": {
          "list": [
            {
              "imageLink": "link",
              "link": "a",
              "details": {
                "detailsGroupId": "b",
                "detailViewId": "z"
              }
            },
            {
              "imageLink": "link1",
              "link": "a",
              "details": {
                "detailsGroupId": "b",
                "detailViewId": "c"
              }
            }
          ]
        }
      },
      {
        "type": "MULTI_TEXT",
        "data": {
          "list": [
            "a"
          ]
        }
      },
      {
        "type": "LIST_VERTICAL_ROUND_IMAGE",
        "data": {
          "title": "a",
          "displayedCount": 5.0,
          "dropButtonOpenTitle": "b",
          "dropButtonCloseTitle": "c",
          "list": [
            {
              "md5hash": "87",
              "title": "a",
              "details": {
                "detailsGroupId": "b",
                "detailViewId": "c"
              }
            }
          ]
        }
        },
        {
            "type": "MULTI_MARKERS_TEXT",
            "data": {
                "backgroundColor": "g",
                "style": "p",
                "list": [
                    "а",
                    "б",
                    "в"
            ]
            }
        }
      ],
      "footer":[
        {
            "type":"PAGE_TITLE",
            "data":{
                "text":"Footer",
                "transparency":true
             }
        }
      ],
      "details":[
         {
            "detailsGroupId":"b",
            "dataGroup":[
               {
                  "detailViewId":"c",
                  "dataView":[
                     {
                        "type":"ICON_WITH_TWO_TEXT_LINES",
                        "data":{
                           "md5hash":"60",
                           "title":"d"
                        }
                     },
                     {
                        "type":"TEXTS_WITH_ICON_HORIZONTAL",
                        "data":{
                           "md5hash":"41",
                           "title":"f",
                           "contentCenterAndPull":true
                        }
                     }
                  ]
               }
            ]
         }
      ],
      "serial":"41"
   }
}
"""
}

extension Array where Element == Landing.DataView {
    
    var iconWithTwoTextLines: [Landing.IconWithTwoTextLines] {
        
        compactMap {
            if case let .iconWithTwoTextLines(iconWithTwoTextLines) = $0 {
                return iconWithTwoTextLines
            } else {
                return nil
            }
        }
    }
    
    var multiLineHeaders: [Landing.MultiLineHeader] {
        
        compactMap {
            if case let .multi(.lineHeader(multiLineHeader)) = $0 {
                return multiLineHeader
            } else {
                return nil
            }
        }
    }
    
    var multiTexts: [Landing.MultiText] {
        
        compactMap {
            if case let .multi(.text(multiText)) = $0 {
                return multiText
            } else {
                return nil
            }
        }
    }
    
    var multiMarkersTexts: [Landing.MultiMarkersText] {
        
        compactMap {
            if case let .multi(.markersText(multiMarkersText)) = $0 {
                return multiMarkersText
            } else {
                return nil
            }
        }
    }
    
    var muiltiTextsWithIconsHorizontals: [Landing.MuiltiTextsWithIconsHorizontal] {
        
        compactMap {
            if case let .multi(.textsWithIconsHorizontalArray(muiltiTextsWithIconsHorizontal)) = $0 {
                return muiltiTextsWithIconsHorizontal
            } else {
                return nil
            }
        }
    }
    
    var listVerticalRoundImages: [Landing.ListVerticalRoundImage] {
        
        compactMap {
            if case let .list(.verticalRoundImage(listVerticalRoundImage)) = $0 {
                return listVerticalRoundImage
            } else {
                return nil
            }
        }
    }
    
    var listHorizontalRoundImages: [Landing.ListHorizontalRoundImage] {
        
        compactMap {
            if case let .list(.horizontalRoundImage(listHorizontalRoundImage)) = $0 {
                return listHorizontalRoundImage
            } else {
                return nil
            }
        }
    }
    
    var listHorizontalRectangleImages: [Landing.ListHorizontalRectangleImage] {
        
        compactMap {
            if case let .list(.horizontalRectangleImage(listHorizontalRectangleImage)) = $0 {
                return listHorizontalRectangleImage
            } else {
                return nil
            }
        }
    }
}
