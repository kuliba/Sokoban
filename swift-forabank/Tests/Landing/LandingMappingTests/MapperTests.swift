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
    
    func test_map_statusCode200_errorNotNil_dataEmpty_error() throws {
        
        let landing = try XCTUnwrap(map(data: Data(String.error.utf8)))
        
        XCTAssertNoDiff(landing.statusCode, 404)
        XCTAssertNoDiff(landing.errorMessage, "404: Не найден запрос к серверу")
        XCTAssertNoDiff(landing.header, [])
        XCTAssertNoDiff(landing.main, [])
        XCTAssertNoDiff(landing.footer, [])
        XCTAssertNoDiff(landing.details, [])
        XCTAssertNoDiff(landing.serial, nil)
    }
    
    func test_map_statusCode200_dataEmpty() throws {
        
        let landing = try XCTUnwrap(map(data: Data(String.emptySample.utf8)))
        
        XCTAssertNoDiff(landing.statusCode, 0)
        XCTAssertNoDiff(landing.errorMessage, nil)
        XCTAssertNoDiff(landing.header, [])
        XCTAssertNoDiff(landing.main, [])
        XCTAssertNoDiff(landing.footer, [])
        XCTAssertNoDiff(landing.details, [])
        XCTAssertNoDiff(landing.serial, "abc")
    }
    
    func test_map_statusCode200_abroadOrderCard_deliversAll() throws {
        
        let landing = try XCTUnwrap(map(data: Data(String.abroadOrderCard.utf8)))
        
        XCTAssertNoDiff(landing.header.count, 0)
        XCTAssertNoDiff(landing.main.count, 16)
        XCTAssertNoDiff(landing.footer.count, 0)
        XCTAssertNoDiff(landing.details.count, 0)
        XCTAssertNoDiff(landing.serial, "037ab501b74e7390de68b5f844cd8b0f")
    }
    
    func test_map_statusCode200_abroadTransfer_deliversAll() throws {
        
        let landing = try XCTUnwrap(map(data: Data(String.abroadTransfer.utf8)))
        
        XCTAssertNoDiff(landing.header.count, 1)
        XCTAssertNoDiff(landing.main.count, 15)
        XCTAssertNoDiff(landing.footer.count, 0)
        XCTAssertNoDiff(landing.details.count, 3)
        XCTAssertNoDiff(landing.serial, "d706714ec041828eadf4b46af8cdb662")
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
                        detail: .init(groupId: "b", viewId: "c"), 
                        action: nil
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
    
    func test_map_deliversMultiButtonsInMain() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.main.multiButtons, [
            .init(list: [
                .init(
                    text: "a",
                    style: "b",
                    detail: .init(groupId: "c", viewId: "d"),
                    link: nil,
                    action: nil),
                .init(
                    text: "f",
                    style: "w",
                    detail: nil,
                    link: nil,
                    action: .init(type: "g"))
            ])
        ])
    }
    
    func test_map_deliversMultiTypeButtonsInMain() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.main.multiTypeButtons, [
            .init(md5hash: "63", backgroundColor: "g", text: "a", buttonText: "b", buttonStyle: "c", textLink: "l", action: .init(type: "d", outputData: .init(tarif: 7, type: 6)), detail: nil)
        ])
    }
    
    func test_map_deliversImagesInMain() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.main.images, [
            .init(withPlaceholder: false, backgroundColor: "w", link: "link")
        ])
    }
    
    func test_map_deliversImageSvgInMain() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.main.imageSvgs, [
            .init(backgroundColor: "W", md5hash: "51")
        ])
    }
    
    func test_map_deliversListDropDownTextsInMain() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.main.listDropDownTexts, [
            .init(
                title: "title",
                list: [
                    .init(title: "a.\ng", description: "b"),
                    .init(title: "c", description: "d")
                ])
        ])
    }
    
    func test_map_deliversSpacingInMain() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.main.spacing, [
            .init(backgroundColor: "w", type: "b")
        ])
    }
    
    func test_map_deliversAll() throws {
        
        let landing = try XCTUnwrap(map())
        
        XCTAssertNoDiff(landing.details.count, 1)
        XCTAssertNoDiff(landing.header.count, 1)
        XCTAssertNoDiff(landing.main.count, 13)
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
    
    func test_map_limits_deliversHeader() throws {
        
        let landing = try XCTUnwrap(map(data: Data(String.limits.utf8)))
        
        XCTAssertNoDiff(landing.header, [
            .pageTitle(.init(
                text: "Управление",
                subtitle: nil,
                transparency: false))
        ])
    }
    
    func test_map_limits_deliversLimitsInMain() throws {
        
        let landing = try XCTUnwrap(map(data: Data(String.limits.utf8)))
        
        XCTAssertNoDiff(landing.main.listHorizontalRectangleLimits, [
            .init(list: [
                .init(
                    action: .init(type: "changeLimit"),
                    limitType: "DEBIT_OPERATIONS",
                    md5hash: "7cc9921ddb97efc14a7de912106ea0d4",
                    title: "Платежи и переводы",
                    limits: [
                        .init(id: "LMTTZ01", title: "Осталось сегодня", colorHEX: "#1C1C1C"),
                        .init(id: "LMTTZ02", title: "Осталось в этом месяце", colorHEX: "#FF3636")
                    ]),
                .init(
                    action: .init(type: "changeLimit"),
                    limitType: "WITHDRAWAL",
                    md5hash: "bec5d6f65faaea15f56cd46b86a78897",
                    title: "Снятие наличных",
                    limits: [
                        .init(id: "LMTTZ03", title: "Осталось сегодня", colorHEX: "#1C1C1C"),
                        .init(id: "LMTTZ04", title: "Осталось в этом месяце", colorHEX: "#FF3636")
                    ])
            ])
        ])
    }

    func test_map_limits_deliversListHorizontalRectangleImagesInMain() throws {
        
        let landing = try XCTUnwrap(map(data: Data(String.limits.utf8)))

        XCTAssertNoDiff(landing.main.listHorizontalRectangleImages, [
            .init(list: [
                .init(
                    imageLink: "dict/getProductCatalogImage?image=/products/banners/ordering_additional_card.png",
                    link: "https://www.forabank.ru/private/cards/",
                    detail: .init(groupId: "QR_SCANNER", viewId: "")
                ),
                .init(
                    imageLink: "dict/getBannerCatalogImage?image=/products/banners/Georgia_12_12_2023.png",
                    link: "",
                    detail: .init(groupId: "CONTACT_TRANSFER", viewId: "GE")
                ),
                .init(
                    imageLink: "dict/getProductCatalogImage?image=/products/banners/payWithSticker.png",
                    link: "",
                    detail: .init(groupId: "LANDING", viewId: "abroadSticker")
                )

            ])
        ])
    }

    func test_map_limits_deliversListVerticalRoundImagesInMain() throws {
        
        let landing = try XCTUnwrap(map(data: Data(String.limits.utf8)))
        
        XCTAssertNoDiff(landing.main.listVerticalRoundImages, [
            .init(
                title: "Прочее",
                displayedCount: nil,
                dropButtonOpenTitle: nil,
                dropButtonCloseTitle: nil,
                list: [
                    .init(
                        md5hash: "fdcc2b1f146ed76ce73629f4a35d9b7d",
                        title: "Управление подписками",
                        subInfo: nil,
                        link: nil,
                        appStore: nil,
                        googlePlay: nil,
                        detail: nil,
                        action: .init(type: "subscriptionControl")
                    )
                ]
            )
        ])
    }

    func test_map_limitsWithErrors_deliversListHorizontalRectangleImagesWithDefaultValuesInMain() throws {
        
        let landing = try XCTUnwrap(map(data: Data(String.limitsWithErrorsInMain.utf8)))

        XCTAssertNoDiff(landing.main.listHorizontalRectangleImages, [
            .init(list: [
                .init(
                    imageLink: "",
                    link: "https://www.forabank.ru/private/cards/",
                    detail: .init(groupId: "QR_SCANNER", viewId: "")
                ),
                .init(
                    imageLink: "dict/getBannerCatalogImage?image=/products/banners/Georgia_12_12_2023.png",
                    link: "",
                    detail: .init(groupId: "", viewId: "GE")
                ),
                .init(
                    imageLink: "dict/getProductCatalogImage?image=/products/banners/payWithSticker.png",
                    link: "",
                    detail: .init(groupId: "LANDING", viewId: "")
                )

            ])
        ])
    }

    func test_map_limitsWithListHorizontalRectangleImagesError_deliversListVerticalRoundImagesInMain() throws {
        
        let landing = try XCTUnwrap(map(data: Data(String.limitsWithErrorsInMain.utf8)))
        
        XCTAssertNoDiff(landing.main.listVerticalRoundImages, [
            .init(
                title: "Прочее",
                displayedCount: nil,
                dropButtonOpenTitle: nil,
                dropButtonCloseTitle: nil,
                list: [
                    .init(
                        md5hash: "fdcc2b1f146ed76ce73629f4a35d9b7d",
                        title: "Управление подписками",
                        subInfo: nil,
                        link: nil,
                        appStore: nil,
                        googlePlay: nil,
                        detail: nil,
                        action: .init(type: "subscriptionControl")
                    )
                ]
            )
        ])
    }
    
    func test_map_limitSettings_deliversHeader() throws {
        
        let landing = try XCTUnwrap(map(data: Data(String.limitSettings.utf8)))
        
        XCTAssertNoDiff(landing.header, [
            .pageTitle(.init(
                text: "Настройка лимитов",
                subtitle: nil,
                transparency: false))
        ])
    }

    func test_map_limitSettings_deliversBlocksHorizontalRectangularInMain() throws {
        
        let landing = try XCTUnwrap(map(data: Data(String.limitSettings.utf8)))
        
        XCTAssertNoDiff(landing.main.blocksHorizontalRectangular, [
            .init(list: [
                .init(limitType: "DEBIT_OPERATIONS", description: "Переводы себе, другим людям и организациям, оплата услуг в приложении", title: "Лимит платежей и переводов", limits: [
                    .init(id: "LMTTZ01", title: "В день", md5hash: "16f4b68434e5d9bb15f03dedc525e77b", text: "Сумма", maxSum: 999999999),
                    .init(id: "LMTTZ02", title: "В месяц", md5hash: "16f4b68434e5d9bb15f03dedc525e77b", text: "Сумма", maxSum: 999999999)
                ]),
                .init(limitType: "WITHDRAWAL", description: "Снятие наличных в банкоматах или операции приравненные к снятию наличных", title: "Лимит снятия наличных", limits: [
                    .init(id: "LMTTZ03", title: "В день", md5hash: "16f4b68434e5d9bb15f03dedc525e77b", text: "Сумма", maxSum: 150000),
                    .init(id: "LMTTZ04", title: "В месяц", md5hash: "16f4b68434e5d9bb15f03dedc525e77b", text: "Сумма", maxSum: 500000)
                ])

            ])
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
    "statusCode":0,
    "errorMessage":null,
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
    "statusCode":0,
    "errorMessage":null,
   "data":{
      "header":[
         {
            "type":"PAGE_TITLE",
            "data":{
               "title":"a",
               "transparency":true
            }
         }
      ],
      "main":[
              {
                "type": "IMAGE_SVG",
                "data": {
                  "md5hash": "51",
                  "backgroundColor": "W"
                }
              },
      {
        "type": "VERTICAL_SPACING",
        "data": {
          "backgroundColor": "w",
          "spacingType": "b"
        }
      },
      {
        "type": "LIST_DROP_DOWN_TEXTS",
        "data": {
          "title": "title",
          "list": [
            {
              "title": "a.\ng",
              "description": "b"
            },
            {
              "title": "c",
              "description": "d"
            }
          ]
        }
      },
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
        },
        {
        "type": "MULTI_BUTTONS",
        "data": {
          "list": [
            {
              "buttonText": "a",
              "buttonStyle": "b",
              "details": {
                "detailsGroupId": "c",
                "detailViewId": "d"
              }
            },
            {
              "buttonText": "f",
              "buttonStyle": "w",
              "action": {
                "actionType": "g"
              }
            }
          ]
        }
      },
      {
                "type": "MULTI_TYPE_BUTTONS",
                "data": {
                  "backgroundColor": "g",
                  "md5hash": "63",
                  "text": "a",
                  "textLink": "l",
                  "buttonText": "b",
                  "buttonStyle": "c",
                  "action": {
                    "actionType": "d",
                    "outputData": {
                      "cardTarif": 7,
                      "cardType": 6
                    }
                  }
                }
              }
      ],
      "footer":[
        {
            "type":"PAGE_TITLE",
            "data":{
                "title":"Footer",
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
    static let abroadOrderCard: Self = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "main": [
            {
                "type": "PAGE_TITLE",
                "data": {
                    "title": "Выберите продукт",
                    "transparency": true
                }
            },
            {
                "type": "VERTICAL_SPACING",
                "data": {
                    "backgroundColor": "GREY",
                    "spacingType": "BIG"
                }
            },
            {
                "type": "MULTI_LINE_HEADER",
                "data": {
                    "backgroundColor": "GREY",
                    "boldTextList": [
                        "МИР",
                        "«Все включено»"
                    ]
                }
            },
            {
                "type": "MULTI_MARKERS_TEXT",
                "data": {
                    "backgroundColor": "GREY",
                    "style": "PADDING",
                    "list": [
                        "Обслуживание – 0 ₽",
                        "Кешбэк: до 40% партнерский, 5% сезонный, 1% – остальные покупки",
                        "4% - выгода при покупке топлива в приложении «Турбо»",
                        "Сумма кешбэка – до 10 000 ₽/мес.",
                        "Бонусы и кешбэк по «Привет, Мир!»"
                    ]
                }
            },
            {
                "type": "IMAGE",
                "data": {
                    "isPlaceholder": true,
                    "imageLink": "dict/getProductCatalogImage?image=/products/products/product_1.png",
                    "backgroundColor": "GREY"
                }
            },
            {
                "type": "MULTI_TYPE_BUTTONS",
                "data": {
                    "backgroundColor": "GREY",
                    "md5hash": "63895ae0220683560a3d999da619c88d",
                    "text": "Подробные условия",
                    "textLink": "https://www.forabank.ru/user-upload/dok-dbo-fl/tariffs/vse-vklyucheno_2-0.pdf",
                    "buttonText": "Заказать",
                    "buttonStyle": "whiteRed",
                    "action": {
                        "actionType": "orderCard",
                        "outputData": {
                            "cardTarif": 7.0,
                            "cardType": 6.0
                        }
                    }
                }
            },
            {
                "type": "VERTICAL_SPACING",
                "data": {
                    "backgroundColor": "BLACK",
                    "spacingType": "BIG"
                }
            },
            {
                "type": "MULTI_LINE_HEADER",
                "data": {
                    "backgroundColor": "BLACK",
                    "regularTextList": [
                        "Пакет"
                    ],
                    "boldTextList": [
                        "Премиальный"
                    ]
                }
            },
            {
                "type": "MULTI_MARKERS_TEXT",
                "data": {
                    "backgroundColor": "BLACK",
                    "style": "PADDING",
                    "list": [
                        "Валюта счета: ₽/$/€",
                        "Кешбэк: до 20% у партнеров, 7% сезонный, 2% канцтовары, 1,2% — остальные покупки, до 20 000 ₽/мес.",
                        "Кредитный лимит до 1 500 000 ₽, ставка от 17% годовых"
                    ]
                }
            },
            {
                "type": "IMAGE",
                "data": {
                    "isPlaceholder": true,
                    "imageLink": "dict/getProductCatalogImage?image=/products/products/product_2.png",
                    "backgroundColor": "BLACK"
                }
            },
            {
                "type": "MULTI_TYPE_BUTTONS",
                "data": {
                    "backgroundColor": "BLACK",
                    "md5hash": "cac49ca8557d2e66d321f5fe1151235e",
                    "text": "Подробные условия",
                    "textLink": "https://www.forabank.ru/user-upload/dok-dbo-fl/tariffs/paket-premialnyy.pdf",
                    "buttonText": "Заказать",
                    "buttonStyle": "whiteRed",
                    "action": {
                        "actionType": "orderCard",
                        "outputData": {
                            "cardTarif": 38.0,
                            "cardType": 5.0
                        }
                    }
                }
            },
            {
                "type": "VERTICAL_SPACING",
                "data": {
                    "backgroundColor": "GREY",
                    "spacingType": "BIG"
                }
            },
            {
                "type": "MULTI_LINE_HEADER",
                "data": {
                    "backgroundColor": "GREY",
                    "boldTextList": [
                        "«МИР",
                        "Пенсионная»"
                    ]
                }
            },
            {
                "type": "MULTI_MARKERS_TEXT",
                "data": {
                    "backgroundColor": "GREY",
                    "style": "PADDING",
                    "list": [
                        "Обслуживание 0 ₽",
                        "Доход на остаток от 10 001 ₽/мес., до 7,25%",
                        "Кешбэк: 5% сезонный, 2% — в аптеках, 20% партнерский, 1% — др. покупки",
                        "В 5-ке лучших пенсионных карт, «Выберу.ру» от 23.08.2022 г."
                    ]
                }
            },
            {
                "type": "IMAGE",
                "data": {
                    "isPlaceholder": true,
                    "imageLink": "dict/getProductCatalogImage?image=/products/products/product_3.png",
                    "backgroundColor": "GREY"
                }
            },
            {
                "type": "MULTI_TYPE_BUTTONS",
                "data": {
                    "backgroundColor": "GREY",
                    "md5hash": "63895ae0220683560a3d999da619c88d",
                    "text": "Подробные условия",
                    "textLink": "https://www.forabank.ru/user-upload/dok-dbo-fl/tariffs/mir-pensionnaya.pdf",
                    "buttonText": "Заказать",
                    "buttonStyle": "whiteRed",
                    "action": {
                        "actionType": "orderCard",
                        "outputData": {
                            "cardTarif": 26.0,
                            "cardType": 6.0
                        }
                    }
                }
            }
        ],
        "serial": "037ab501b74e7390de68b5f844cd8b0f"
    }
}
"""
    static let abroadTransfer: Self = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "header": [
            {
                "type": "PAGE_TITLE",
                "data": {
                    "title": "Переводы за рубеж",
                    "transparency": true
                }
            }
        ],
        "main": [
            {
                "type": "IMAGE",
                "data": {
                    "isPlaceholder": false,
                    "imageLink": "dict/getProductCatalogImage?image=/products/banners/Header_abroad.png",
                    "backgroundColor": "WHITE"
                }
            },
            {
                "type": "MULTI_LINE_HEADER",
                "data": {
                    "backgroundColor": "WHITE",
                    "regularTextList": [
                        "Переводы"
                    ],
                    "boldTextList": [
                        "за рубеж"
                    ]
                }
            },
            {
                "type": "VERTICAL_SPACING",
                "data": {
                    "backgroundColor": "WHITE",
                    "spacingType": "BIG"
                }
            },
            {
                "type": "VERTICAL_SPACING",
                "data": {
                    "backgroundColor": "WHITE",
                    "spacingType": "BIG"
                }
            },
            {
                "type": "MULTI_TEXTS_WITH_ICONS_HORIZONTAL",
                "data": [
                    {
                        "md5hash": "a442191010ad33a883625f93d91037b1",
                        "title": "Быстро"
                    },
                    {
                        "md5hash": "7df826030e8d418be0a33edde3a26ad0",
                        "title": "Безопасно"
                    },
                    {
                        "md5hash": "5d9427225e136f31d26a211b9207dc3b",
                        "title": "Выгодно"
                    }
                ]
            },
            {
                "type": "LIST_HORIZONTAL_ROUND_IMAGE",
                "data": {
                    "title": "Популярные направления",
                    "list": [
                        {
                            "md5hash": "6046e5eaff596a41ce9845cca3b0a887",
                            "title": "Армения",
                            "subInfo": "1%",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Armeniya"
                            }
                        },
                        {
                            "md5hash": "c63878a33f9caef203972501cbd06359",
                            "title": "Узбекистан",
                            "subInfo": "1,5%",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Uzbekistan"
                            }
                        },
                        {
                            "md5hash": "a6c13609939eb58093394ff12b0cf650",
                            "title": "Турция",
                            "subInfo": "0%",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Turkey"
                            }
                        },
                        {
                            "md5hash": "cfcbbed7d050392873d726d7a97f199e",
                            "title": "Грузия",
                            "subInfo": "1,2%",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Georgia"
                            }
                        },
                        {
                            "md5hash": "7353271bf2ff12101dba791f914d7855",
                            "title": "Казахстан",
                            "subInfo": "1%",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Kazakhstan"
                            }
                        },
                        {
                            "md5hash": "c2deb01d90d0234a073890d37e0fb06d",
                            "title": "Кыргызстан",
                            "subInfo": "1%",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Kirgizstan"
                            }
                        },
                        {
                            "md5hash": "d194c0a995d5e0bfd67b6db71e99f1e5",
                            "title": "Молдова",
                            "subInfo": "1%",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Moldova"
                            }
                        },
                        {
                            "md5hash": "cd6b86a0e95e22cfbc8e73bcedd6083f",
                            "title": "Таджикистан",
                            "subInfo": "1,5%",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Tadzhikistan"
                            }
                        }
                    ]
                }
            },
            {
                "type": "TEXTS_WITH_ICON_HORIZONTAL",
                "data": {
                    "md5hash": "5da774ddfc9bc0961fac3e12cba88c55",
                    "title": "Более 5 000 переводов в месяц",
                    "contentCenterAndPull": false
                }
            },
            {
                "type": "LIST_HORIZONTAL_RECTANGLE_IMAGE",
                "data": {
                    "list": [
                        {
                            "imageLink": "dict/getProductCatalogImage?image=/products/banners/Product_abroad_1.png",
                            "link": "https://www.forabank.ru/landings/mig/",
                            "details": {
                                "detailsGroupId": "bannersLanding",
                                "detailViewId": "oneThousandForTransfer"
                            }
                        },
                        {
                            "imageLink": "dict/getProductCatalogImage?image=/products/banners/deposit.png",
                            "link": "https://www.forabank.ru/landings/mig/",
                            "details": {
                                "detailsGroupId": "bannersLanding",
                                "detailViewId": "moreTransfers"
                            }
                        }
                    ]
                }
            },
            {
                "type": "LIST_VERTICAL_ROUND_IMAGE",
                "data": {
                    "title": "Список стран",
                    "displayedCount": 5.0,
                    "dropButtonOpenTitle": "Смотреть все страны",
                    "dropButtonCloseTitle": "Скрыть все страны",
                    "list": [
                        {
                            "md5hash": "873ae820e558f131084e80df69d6efad",
                            "title": "Абхазия",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Abhaziya"
                            }
                        },
                        {
                            "md5hash": "3d35ab0a583e052f1157b1e703bda356",
                            "title": "Азербайджан",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Azerbaydzhan"
                            }
                        },
                        {
                            "md5hash": "6046e5eaff596a41ce9845cca3b0a887",
                            "title": "Армения",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Armeniya"
                            }
                        },
                        {
                            "md5hash": "f48a9c3ccf4ff096590985ed0688bd69",
                            "title": "Беларусь",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Belarus"
                            }
                        },
                        {
                            "md5hash": "cfcbbed7d050392873d726d7a97f199e",
                            "title": "Грузия",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Georgia"
                            }
                        },
                        {
                            "md5hash": "39da3bbdd0b0569dd563e249105cd2f5",
                            "title": "Израиль",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Israel"
                            }
                        },
                        {
                            "md5hash": "7353271bf2ff12101dba791f914d7855",
                            "title": "Казахстан",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Kazakhstan"
                            }
                        },
                        {
                            "md5hash": "c2deb01d90d0234a073890d37e0fb06d",
                            "title": "Кыргызстан",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Kirgizstan"
                            }
                        },
                        {
                            "md5hash": "d194c0a995d5e0bfd67b6db71e99f1e5",
                            "title": "Молдова",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Moldova"
                            }
                        },
                        {
                            "md5hash": "cd6b86a0e95e22cfbc8e73bcedd6083f",
                            "title": "Таджикистан",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Tadzhikistan"
                            }
                        },
                        {
                            "md5hash": "a6c13609939eb58093394ff12b0cf650",
                            "title": "Турция",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Turkey"
                            }
                        },
                        {
                            "md5hash": "c63878a33f9caef203972501cbd06359",
                            "title": "Узбекистан",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Uzbekistan"
                            }
                        },
                        {
                            "md5hash": "ebcf044a5f0d6ec8b3531fbe167e304c",
                            "title": "Южная Осетия",
                            "details": {
                                "detailsGroupId": "forCountriesList",
                                "detailViewId": "Uzhnaya Osetia"
                            }
                        }
                    ]
                }
            },
            {
                "type": "LIST_VERTICAL_ROUND_IMAGE",
                "data": {
                    "title": "Преимущества",
                    "list": [
                        {
                            "md5hash": "c1922354c30751af8867aa0e13d07fa1",
                            "title": "Выгодно",
                            "subTitle": "Низкие проценты"
                        },
                        {
                            "md5hash": "d66499e075262b782331c20b5fbe7299",
                            "title": "Мгновенно",
                            "subTitle": "На карту получателя"
                        },
                        {
                            "md5hash": "d5cbcabf90f3406a0bb7779579e2a2cb",
                            "title": "Круглосуточно",
                            "subTitle": "В мобильном приложении"
                        },
                        {
                            "md5hash": "d072abacb3d2ed748777db9dd39d29ec",
                            "title": "Удобно",
                            "subTitle": "По номеру телефона"
                        }
                    ]
                }
            },
            {
                "type": "MULTI_BUTTONS",
                "data": {
                    "list": [
                        {
                            "buttonText": "Заказать карту",
                            "buttonStyle": "blackWhite",
                            "details": {
                                "detailsGroupId": "cardsLanding",
                                "detailViewId": "twoColorsLanding"
                            }
                        },
                        {
                            "buttonText": "Войти и перевести",
                            "buttonStyle": "whiteRed",
                            "action": {
                                "actionType": "goToMain"
                            }
                        }
                    ]
                }
            },
            {
                "type": "LIST_DROP_DOWN_TEXTS",
                "data": {
                    "title": "Часто задаваемые вопросы",
                    "list": [
                        {
                            "title": "Как можно отправить перевод за рубеж?",
                            "description": "В приложении в разделе «Платежи» выберите «Перевести за рубеж и по РФ».\nВыберите страну и введите номер телефона или ФИО получателя. Номера мобильного телефона будет достаточно для перевода в Армению или ФИО получателя при переводе в другие страны."
                        },
                        {
                            "title": "Как можно отправить перевод в Армению?",
                            "description": "В приложении выберите Перевод по номеру телефона и введите номер телефона получателя. Далее следуйте подсказкам системы и выберите банк – получателя в Армении."
                        },
                        {
                            "title": "В какой валюте можно отправить и получить перевод?",
                            "description": "Валюта отправки и получения перевода зависит от выбранной страны получения перевода. Например, отправка переводов в Армению осуществляется в рублях, а получить перевод можно на карту с валютой счета – рубль РФ, драм, доллар США или евро."
                        },
                        {
                            "title": "Какую сумму можно отправить и сколько стоит перевод?",
                            "description": "В Армению можно отправить до 1 млн. рублей за операцию / в день / в месяц. Комиссия составит 1%.\nВ другие страны по ПС Contact – до 5 000$ или эквивалент в другой валюте за операцию / в день / в месяц. Комиссия от 0% до 2% от суммы перевода зависит от страны и валюты перевода."
                        },
                        {
                            "title": "Как быстро получатель сможет получить денежные средства?",
                            "description": "Перевод будет зачислен моментально, при переводах в Армению средства поступят на счет/карту в банке-партнере.\nПри переводах в иные страны перевод доступен к получению через несколько секунд в пунктах выдачи наличных (ПВН) ПС Contact."
                        }
                    ]
                }
            },
            {
                "type": "LIST_VERTICAL_ROUND_IMAGE",
                "data": {
                    "title": "Онлайн поддержка",
                    "list": [
                        {
                            "md5hash": "db3914574f451ed3efe4fea1d6ac95c",
                            "title": "Telegram",
                            "link": "https://t.me/forabank_bot",
                            "appStore": "https://apps.apple.com/ru/app/telegram-messenger/id686449807",
                            "googlePlay": "https://play.google.com/store/apps/details?id=org.telegram.messenger"
                        },
                        {
                            "md5hash": "57ed65181beb139a5601be8a596654cd",
                            "title": "WhatsApp",
                            "link": "https://wa.me/79257756555",
                            "appStore": "https://apps.apple.com/ru/app/whatsapp-messenger/id310633997",
                            "googlePlay": "https://play.google.com/store/apps/details?id=com.whatsapp"
                        },
                        {
                            "md5hash": "c81ddc6c5a5cef87a28b7d8e7b09f884",
                            "title": "Viber",
                            "link": "viber://pa?chatURI=forabank",
                            "appStore": "https://apps.apple.com/ru/app/viber-%D0%BC%D0%B5%D1%81%D1%81%D0%B5%D0%BD%D0%B4%D0%B6%D0%B5%D1%80-%D0%B8-%D0%B2%D0%B8%D0%B4%D0%B5%D0%BE-%D1%87%D0%B0%D1%82/id382617920",
                            "googlePlay": "https://play.google.com/store/apps/details?id=com.viber.voip"
                        },
                        {
                            "md5hash": "b73c7e611ecc0813fc412925af6422ef",
                            "title": "Звонок оператору",
                            "link": "telprompt://88001009889"
                        }
                    ]
                }
            },
            {
                "type": "MULTI_TEXT",
                "data": {
                    "list": [
                        "Фора-банк является зарегистрированным поставщиком платежных услуг. Наша деятельность находится под контролем Налогово-таможенной службы (HMRC) в соответствии с Положением об отмывании денег №12667079 и регулируется Управлением по финансовому регулированию и надзору РФ"
                    ]
                }
            },
            {
                "type": "VERTICAL_SPACING",
                "data": {
                    "backgroundColor": "WHITE",
                    "spacingType": "BIG"
                }
            }
        ],
        "details": [
            {
                "detailsGroupId": "bannersLanding",
                "dataGroup": [
                    {
                        "detailViewId": "moreTransfers",
                        "dataView": [
                            {
                                "type": "ICON_WITH_TWO_TEXT_LINES",
                                "data": {
                                    "md5hash": "6046e5eaff596a41ce9845cca3b0a887",
                                    "title": "Больше возможностей при переводах в Армению"
                                }
                            },
                            {
                                "type": "TEXTS_WITH_ICON_HORIZONTAL",
                                "data": {
                                    "md5hash": "411d86beb3c9e68dfd8dd46bd544ea49",
                                    "title": "Теперь до 1 000 000 ₽",
                                    "contentCenterAndPull": true
                                }
                            },
                            {
                                "type": "LIST_VERTICAL_ROUND_IMAGE",
                                "data": {
                                    "list": [
                                        {
                                            "md5hash": "ba98336ad696bfe1400ecdd8435d2bac",
                                            "title": "Сумма перевода",
                                            "subTitle": "от 100 ₽ до 1 000 000 ₽"
                                        },
                                        {
                                            "md5hash": "8fce20724f54a0e8ceec048748efab00",
                                            "title": "Лимит",
                                            "subTitle": "1 000 000 ₽ можно использовать на одну операцию или суммарно за день или месяц"
                                        },
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "Комиссия — 1% от суммы",
                                            "subTitle": "(min 100 ₽, max 10 000 ₽)"
                                        },
                                        {
                                            "md5hash": "8b894449c5e9d69cc57dc14a6e8027f2",
                                            "title": "Отправка",
                                            "subTitle": "По номеру телефона на счет получателя в одном из банков Армении"
                                        },
                                        {
                                            "md5hash": "bd5a8a1fdc6bf099d5086923b4b42e93",
                                            "title": "Условия",
                                            "subTitle": "Предложение действует для всех зарегистрированных пользователей Фора-Онлайн"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_BUTTONS",
                                "data": {
                                    "list": [
                                        {
                                            "buttonText": "Заказать карту",
                                            "buttonStyle": "blackWhite",
                                            "details": {
                                                "detailsGroupId": "cardsLanding",
                                                "detailViewId": "twoColorsLanding"
                                            }
                                        },
                                        {
                                            "buttonText": "Войти и перевести",
                                            "buttonStyle": "whiteRed",
                                            "action": {
                                                "actionType": "goToMain"
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "WHITE",
                                    "spacingType": "BIG"
                                }
                            }
                        ]
                    },
                    {
                        "detailViewId": "oneThousandForTransfer",
                        "dataView": [
                            {
                                "type": "ICON_WITH_TWO_TEXT_LINES",
                                "data": {
                                    "md5hash": "6046e5eaff596a41ce9845cca3b0a887",
                                    "title": "Армения"
                                }
                            },
                            {
                                "type": "TEXTS_WITH_ICON_HORIZONTAL",
                                "data": {
                                    "md5hash": "411d86beb3c9e68dfd8dd46bd544ea49",
                                    "title": "Денежные переводы МИГ",
                                    "contentCenterAndPull": true
                                }
                            },
                            {
                                "type": "MULTI_MARKERS_TEXT",
                                "data": {
                                    "backgroundColor": "GREY",
                                    "style": "PADDINGWITHCORNERS",
                                    "list": [
                                        "Соверши свой первый перевод в Армению в приложении Фора-Банка*",
                                        "Получи кешбэк до 1 000 ₽*"
                                    ]
                                }
                            },
                            {
                                "type": "IMAGE_SVG",
                                "data": {
                                    "md5hash": "51d1065025fef6a2096a63570245095f",
                                    "backgroundColor": "WHITE"
                                }
                            },
                            {
                                "type": "LIST_VERTICAL_ROUND_IMAGE",
                                "data": {
                                    "list": [
                                        {
                                            "md5hash": "c1922354c30751af8867aa0e13d07fa1",
                                            "title": "Выгодно",
                                            "subTitle": "Комиссия всего 1%. Кешбэк до 1 000 ₽ за первый перевод***"
                                        },
                                        {
                                            "md5hash": "d66499e075262b782331c20b5fbe7299",
                                            "title": "Мгновенно",
                                            "subTitle": "Средства поступят на счет получателя через несколько секунд"
                                        },
                                        {
                                            "md5hash": "d5cbcabf90f3406a0bb7779579e2a2cb",
                                            "title": "Круглосуточно",
                                            "subTitle": "В мобильном приложении Фора-банка"
                                        },
                                        {
                                            "md5hash": "d072abacb3d2ed748777db9dd39d29ec",
                                            "title": "Просто",
                                            "subTitle": "По номеру телефона получателя"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "LIST_HORIZONTAL_ROUND_IMAGE",
                                "data": {
                                    "title": "Банки партнеры",
                                    "list": [
                                        {
                                            "md5hash": "1498e6b4a776464eb4e7fd845c221f06",
                                            "title": "Эвокабанк"
                                        },
                                        {
                                            "md5hash": "d5861f90100c97706a6952e0dca2e0c2",
                                            "title": "Ардшинбанк"
                                        },
                                        {
                                            "md5hash": "21b6a406c583929effd620f8853c1a39",
                                            "title": "IDBank"
                                        },
                                        {
                                            "md5hash": "27540fc63bd4e0e91165e4af3934f95b",
                                            "title": "АрраратБанк"
                                        },
                                        {
                                            "md5hash": "a9571b421f9a680cc42564240b4b63e9",
                                            "title": "АрмББ"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_BUTTONS",
                                "data": {
                                    "list": [
                                        {
                                            "buttonText": "Заказать карту",
                                            "buttonStyle": "blackWhite",
                                            "details": {
                                                "detailsGroupId": "cardsLanding",
                                                "detailViewId": "twoColorsLanding"
                                            }
                                        },
                                        {
                                            "buttonText": "Войти и перевести",
                                            "buttonStyle": "whiteRed",
                                            "action": {
                                                "actionType": "goToMain"
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_TEXT",
                                "data": {
                                    "list": [
                                        "*Акция «Кешбэк до 1000 руб. за первый перевод» – стимулирующее мероприятие, не является лотереей. Период проведения акции «Кешбэк до 1000 руб. за первый перевод» с 01 ноября 2022 по 31 января 2023 года. Информацию об организаторе акции, о правилах, порядке, сроках и месте ее проведения можно узнать на официальном сайте www.forabank.ru и в офисах АКБ «ФОРА-БАНК» (АО).",
                                        "** Участник Акции имеет право заключить с банком договор банковского счета с использованием карты МИР по тарифному плану «МИГ» или «Все включено-Промо» с бесплатным обслуживанием.",
                                        "*** Банк выплачивает Участнику Акции кешбэк в размере 100% от суммы комиссии за первый перевод, но не более 1000 рублей."
                                    ]
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "WHITE",
                                    "spacingType": "BIG"
                                }
                            }
                        ]
                    }
                ]
            },
            {
                "detailsGroupId": "cardsLanding",
                "dataGroup": [
                    {
                        "detailViewId": "twoColorsLanding",
                        "dataView": [
                            {
                                "type": "PAGE_TITLE",
                                "data": {
                                    "title": "Выберите продукт",
                                    "transparency": true
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "GREY",
                                    "spacingType": "BIG"
                                }
                            },
                            {
                                "type": "MULTI_LINE_HEADER",
                                "data": {
                                    "backgroundColor": "GREY",
                                    "boldTextList": [
                                        "МИР",
                                        "«Все включено»"
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_MARKERS_TEXT",
                                "data": {
                                    "backgroundColor": "GREY",
                                    "style": "PADDING",
                                    "list": [
                                        "Обслуживание – 0 ₽",
                                        "Кешбэк: до 40% партнерский, 5% сезонный, 1% – остальные покупки",
                                        "4% - выгода при покупке топлива в приложении «Турбо»",
                                        "Сумма кешбэка – до 10 000 ₽/мес.",
                                        "Бонусы и кешбэк по «Привет, Мир!»"
                                    ]
                                }
                            },
                            {
                                "type": "IMAGE",
                                "data": {
                                    "isPlaceholder": true,
                                    "imageLink": "dict/getProductCatalogImage?image=/products/products/product_1.png",
                                    "backgroundColor": "GREY"
                                }
                            },
                            {
                                "type": "MULTI_TYPE_BUTTONS",
                                "data": {
                                    "backgroundColor": "GREY",
                                    "md5hash": "63895ae0220683560a3d999da619c88d",
                                    "text": "Подробные условия",
                                    "textLink": "https://www.forabank.ru/user-upload/dok-dbo-fl/tariffs/vse-vklyucheno_2-0.pdf",
                                    "buttonText": "Заказать",
                                    "buttonStyle": "whiteRed",
                                    "action": {
                                        "actionType": "orderCard",
                                        "outputData": {
                                            "cardTarif": 7.0,
                                            "cardType": 6.0
                                        }
                                    }
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "BLACK",
                                    "spacingType": "BIG"
                                }
                            },
                            {
                                "type": "MULTI_LINE_HEADER",
                                "data": {
                                    "backgroundColor": "BLACK",
                                    "regularTextList": [
                                        "Пакет"
                                    ],
                                    "boldTextList": [
                                        "Премиальный"
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_MARKERS_TEXT",
                                "data": {
                                    "backgroundColor": "BLACK",
                                    "style": "PADDING",
                                    "list": [
                                        "Валюта счета: ₽/$/€",
                                        "Кешбэк: до 20% у партнеров, 7% сезонный, 2% канцтовары, 1,2% — остальные покупки, до 20 000 ₽/мес.",
                                        "Кредитный лимит до 1 500 000 ₽, ставка от 17% годовых"
                                    ]
                                }
                            },
                            {
                                "type": "IMAGE",
                                "data": {
                                    "isPlaceholder": true,
                                    "imageLink": "dict/getProductCatalogImage?image=/products/products/product_2.png",
                                    "backgroundColor": "BLACK"
                                }
                            },
                            {
                                "type": "MULTI_TYPE_BUTTONS",
                                "data": {
                                    "backgroundColor": "BLACK",
                                    "md5hash": "cac49ca8557d2e66d321f5fe1151235e",
                                    "text": "Подробные условия",
                                    "textLink": "https://www.forabank.ru/user-upload/dok-dbo-fl/tariffs/paket-premialnyy.pdf",
                                    "buttonText": "Заказать",
                                    "buttonStyle": "whiteRed",
                                    "action": {
                                        "actionType": "orderCard",
                                        "outputData": {
                                            "cardTarif": 38.0,
                                            "cardType": 5.0
                                        }
                                    }
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "GREY",
                                    "spacingType": "BIG"
                                }
                            },
                            {
                                "type": "MULTI_LINE_HEADER",
                                "data": {
                                    "backgroundColor": "GREY",
                                    "boldTextList": [
                                        "«МИР",
                                        "Пенсионная»"
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_MARKERS_TEXT",
                                "data": {
                                    "backgroundColor": "GREY",
                                    "style": "PADDING",
                                    "list": [
                                        "Обслуживание 0 ₽",
                                        "Доход на остаток от 10 001 ₽/мес., до 7,25%",
                                        "Кешбэк: 5% сезонный, 2% — в аптеках, 20% партнерский, 1% — др. покупки",
                                        "В 5-ке лучших пенсионных карт, «Выберу.ру» от 23.08.2022 г."
                                    ]
                                }
                            },
                            {
                                "type": "IMAGE",
                                "data": {
                                    "isPlaceholder": true,
                                    "imageLink": "dict/getProductCatalogImage?image=/products/products/product_3.png",
                                    "backgroundColor": "GREY"
                                }
                            },
                            {
                                "type": "MULTI_TYPE_BUTTONS",
                                "data": {
                                    "backgroundColor": "GREY",
                                    "md5hash": "63895ae0220683560a3d999da619c88d",
                                    "text": "Подробные условия",
                                    "textLink": "https://www.forabank.ru/user-upload/dok-dbo-fl/tariffs/mir-pensionnaya.pdf",
                                    "buttonText": "Заказать",
                                    "buttonStyle": "whiteRed",
                                    "action": {
                                        "actionType": "orderCard",
                                        "outputData": {
                                            "cardTarif": 26.0,
                                            "cardType": 6.0
                                        }
                                    }
                                }
                            }
                        ]
                    }
                ]
            },
            {
                "detailsGroupId": "forCountriesList",
                "dataGroup": [
                    {
                        "detailViewId": "Abhaziya",
                        "dataView": [
                            {
                                "type": "ICON_WITH_TWO_TEXT_LINES",
                                "data": {
                                    "md5hash": "873ae820e558f131084e80df69d6efad",
                                    "title": "Абхазия"
                                }
                            },
                            {
                                "type": "LIST_VERTICAL_ROUND_IMAGE",
                                "data": {
                                    "list": [
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "0%",
                                            "subTitle": "при переводе с конвертацией"
                                        },
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "1% мин. 70 ₽/2 $",
                                            "subTitle": "при переводе в единой валюте"
                                        },
                                        {
                                            "md5hash": "8b894449c5e9d69cc57dc14a6e8027f2",
                                            "title": "Отправка",
                                            "subTitle": "по ФИО получателя"
                                        },
                                        {
                                            "md5hash": "a2f253f0cab9f4dc4508ee4c4ec7795f",
                                            "title": "Получение",
                                            "subTitle": "наличными в ₽ или $"
                                        },
                                        {
                                            "md5hash": "8fce20724f54a0e8ceec048748efab00",
                                            "title": "Лимит",
                                            "subTitle": "до 300 000 ₽ в месяц"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_BUTTONS",
                                "data": {
                                    "list": [
                                        {
                                            "buttonText": "Заказать карту",
                                            "buttonStyle": "blackWhite",
                                            "details": {
                                                "detailsGroupId": "cardsLanding",
                                                "detailViewId": "twoColorsLanding"
                                            }
                                        },
                                        {
                                            "buttonText": "Войти и перевести",
                                            "buttonStyle": "whiteRed",
                                            "action": {
                                                "actionType": "goToMain"
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "WHITE",
                                    "spacingType": "BIG"
                                }
                            }
                        ]
                    },
                    {
                        "detailViewId": "Azerbaydzhan",
                        "dataView": [
                            {
                                "type": "ICON_WITH_TWO_TEXT_LINES",
                                "data": {
                                    "md5hash": "3d35ab0a583e052f1157b1e703bda356",
                                    "title": "Азербайджан"
                                }
                            },
                            {
                                "type": "LIST_VERTICAL_ROUND_IMAGE",
                                "data": {
                                    "list": [
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "0%",
                                            "subTitle": "при переводе с конвертацией"
                                        },
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "1,2% мин. 70 ₽/2,5 $",
                                            "subTitle": "при переводе в единой валюте"
                                        },
                                        {
                                            "md5hash": "8b894449c5e9d69cc57dc14a6e8027f2",
                                            "title": "Отправка",
                                            "subTitle": "по ФИО получателя"
                                        },
                                        {
                                            "md5hash": "a2f253f0cab9f4dc4508ee4c4ec7795f",
                                            "title": "Получение",
                                            "subTitle": "наличными в ₽, $ или азербайджанских манатах"
                                        },
                                        {
                                            "md5hash": "8fce20724f54a0e8ceec048748efab00",
                                            "title": "Лимит",
                                            "subTitle": "до 300 000 ₽ в месяц"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_BUTTONS",
                                "data": {
                                    "list": [
                                        {
                                            "buttonText": "Заказать карту",
                                            "buttonStyle": "blackWhite",
                                            "details": {
                                                "detailsGroupId": "cardsLanding",
                                                "detailViewId": "twoColorsLanding"
                                            }
                                        },
                                        {
                                            "buttonText": "Войти и перевести",
                                            "buttonStyle": "whiteRed",
                                            "action": {
                                                "actionType": "goToMain"
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "WHITE",
                                    "spacingType": "BIG"
                                }
                            }
                        ]
                    },
                    {
                        "detailViewId": "Belarus",
                        "dataView": [
                            {
                                "type": "ICON_WITH_TWO_TEXT_LINES",
                                "data": {
                                    "md5hash": "f48a9c3ccf4ff096590985ed0688bd69",
                                    "title": "Беларусь"
                                }
                            },
                            {
                                "type": "LIST_VERTICAL_ROUND_IMAGE",
                                "data": {
                                    "list": [
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "1%",
                                            "subTitle": "мин. 70 ₽"
                                        },
                                        {
                                            "md5hash": "8b894449c5e9d69cc57dc14a6e8027f2",
                                            "title": "Отправка",
                                            "subTitle": "по ФИО получателя"
                                        },
                                        {
                                            "md5hash": "a2f253f0cab9f4dc4508ee4c4ec7795f",
                                            "title": "Получение",
                                            "subTitle": "наличными в ₽"
                                        },
                                        {
                                            "md5hash": "8fce20724f54a0e8ceec048748efab00",
                                            "title": "Лимит",
                                            "subTitle": "до 300 000 ₽ в месяц"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_BUTTONS",
                                "data": {
                                    "list": [
                                        {
                                            "buttonText": "Заказать карту",
                                            "buttonStyle": "blackWhite",
                                            "details": {
                                                "detailsGroupId": "cardsLanding",
                                                "detailViewId": "twoColorsLanding"
                                            }
                                        },
                                        {
                                            "buttonText": "Войти и перевести",
                                            "buttonStyle": "whiteRed",
                                            "action": {
                                                "actionType": "goToMain"
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "WHITE",
                                    "spacingType": "BIG"
                                }
                            }
                        ]
                    },
                    {
                        "detailViewId": "Georgia",
                        "dataView": [
                            {
                                "type": "ICON_WITH_TWO_TEXT_LINES",
                                "data": {
                                    "md5hash": "cfcbbed7d050392873d726d7a97f199e",
                                    "title": "Грузия"
                                }
                            },
                            {
                                "type": "LIST_VERTICAL_ROUND_IMAGE",
                                "data": {
                                    "list": [
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "0%",
                                            "subTitle": "при переводе с конвертацией"
                                        },
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "1,2% мин. 70 ₽/2,5 $",
                                            "subTitle": "при переводе в единой валюте"
                                        },
                                        {
                                            "md5hash": "8b894449c5e9d69cc57dc14a6e8027f2",
                                            "title": "Отправка",
                                            "subTitle": "по ФИО получателя"
                                        },
                                        {
                                            "md5hash": "a2f253f0cab9f4dc4508ee4c4ec7795f",
                                            "title": "Получение",
                                            "subTitle": "наличными в ₽, $, € или грузинских лари"
                                        },
                                        {
                                            "md5hash": "8fce20724f54a0e8ceec048748efab00",
                                            "title": "Лимит",
                                            "subTitle": "до 300 000 ₽ в месяц"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_BUTTONS",
                                "data": {
                                    "list": [
                                        {
                                            "buttonText": "Заказать карту",
                                            "buttonStyle": "blackWhite",
                                            "details": {
                                                "detailsGroupId": "cardsLanding",
                                                "detailViewId": "twoColorsLanding"
                                            }
                                        },
                                        {
                                            "buttonText": "Войти и перевести",
                                            "buttonStyle": "whiteRed",
                                            "action": {
                                                "actionType": "goToMain"
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "WHITE",
                                    "spacingType": "BIG"
                                }
                            }
                        ]
                    },
                    {
                        "detailViewId": "Israel",
                        "dataView": [
                            {
                                "type": "ICON_WITH_TWO_TEXT_LINES",
                                "data": {
                                    "md5hash": "39da3bbdd0b0569dd563e249105cd2f5",
                                    "title": "Израиль"
                                }
                            },
                            {
                                "type": "LIST_VERTICAL_ROUND_IMAGE",
                                "data": {
                                    "list": [
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "0%",
                                            "subTitle": "при переводе с конвертацией"
                                        },
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "5% мин. 5 $",
                                            "subTitle": "при переводе в единой валюте"
                                        },
                                        {
                                            "md5hash": "8b894449c5e9d69cc57dc14a6e8027f2",
                                            "title": "Отправка",
                                            "subTitle": "по ФИО получателя"
                                        },
                                        {
                                            "md5hash": "a2f253f0cab9f4dc4508ee4c4ec7795f",
                                            "title": "Получение",
                                            "subTitle": "наличными в $"
                                        },
                                        {
                                            "md5hash": "8fce20724f54a0e8ceec048748efab00",
                                            "title": "Лимит",
                                            "subTitle": "до 600 000 ₽ в месяц"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_BUTTONS",
                                "data": {
                                    "list": [
                                        {
                                            "buttonText": "Заказать карту",
                                            "buttonStyle": "blackWhite",
                                            "details": {
                                                "detailsGroupId": "cardsLanding",
                                                "detailViewId": "twoColorsLanding"
                                            }
                                        },
                                        {
                                            "buttonText": "Войти и перевести",
                                            "buttonStyle": "whiteRed",
                                            "action": {
                                                "actionType": "goToMain"
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "WHITE",
                                    "spacingType": "BIG"
                                }
                            }
                        ]
                    },
                    {
                        "detailViewId": "Tadzhikistan",
                        "dataView": [
                            {
                                "type": "ICON_WITH_TWO_TEXT_LINES",
                                "data": {
                                    "md5hash": "cd6b86a0e95e22cfbc8e73bcedd6083f",
                                    "title": "Таджикистан"
                                }
                            },
                            {
                                "type": "LIST_VERTICAL_ROUND_IMAGE",
                                "data": {
                                    "list": [
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "0%",
                                            "subTitle": "при переводе с конвертацией"
                                        },
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "1,5% мин. 70 ₽/2 $",
                                            "subTitle": "при переводе в единой валюте"
                                        },
                                        {
                                            "md5hash": "8b894449c5e9d69cc57dc14a6e8027f2",
                                            "title": "Отправка",
                                            "subTitle": "по ФИО получателя"
                                        },
                                        {
                                            "md5hash": "a2f253f0cab9f4dc4508ee4c4ec7795f",
                                            "title": "Получение",
                                            "subTitle": "наличными в ₽ или $"
                                        },
                                        {
                                            "md5hash": "8fce20724f54a0e8ceec048748efab00",
                                            "title": "Лимит",
                                            "subTitle": "до 300 000 ₽ в месяц"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_BUTTONS",
                                "data": {
                                    "list": [
                                        {
                                            "buttonText": "Заказать карту",
                                            "buttonStyle": "blackWhite",
                                            "details": {
                                                "detailsGroupId": "cardsLanding",
                                                "detailViewId": "twoColorsLanding"
                                            }
                                        },
                                        {
                                            "buttonText": "Войти и перевести",
                                            "buttonStyle": "whiteRed",
                                            "action": {
                                                "actionType": "goToMain"
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "WHITE",
                                    "spacingType": "BIG"
                                }
                            }
                        ]
                    },
                    {
                        "detailViewId": "Kazakhstan",
                        "dataView": [
                            {
                                "type": "ICON_WITH_TWO_TEXT_LINES",
                                "data": {
                                    "md5hash": "7353271bf2ff12101dba791f914d7855",
                                    "title": "Казахстан"
                                }
                            },
                            {
                                "type": "LIST_VERTICAL_ROUND_IMAGE",
                                "data": {
                                    "list": [
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "0%",
                                            "subTitle": "при переводе с конвертацией"
                                        },
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "1% мин. 70 ₽/2 $",
                                            "subTitle": "при переводе в единой валюте"
                                        },
                                        {
                                            "md5hash": "8b894449c5e9d69cc57dc14a6e8027f2",
                                            "title": "Отправка",
                                            "subTitle": "по ФИО получателя"
                                        },
                                        {
                                            "md5hash": "a2f253f0cab9f4dc4508ee4c4ec7795f",
                                            "title": "Получение",
                                            "subTitle": "наличными в ₽, $ или казахских тенге"
                                        },
                                        {
                                            "md5hash": "8fce20724f54a0e8ceec048748efab00",
                                            "title": "Лимит",
                                            "subTitle": "до 300 000 ₽ в месяц"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_BUTTONS",
                                "data": {
                                    "list": [
                                        {
                                            "buttonText": "Заказать карту",
                                            "buttonStyle": "blackWhite",
                                            "details": {
                                                "detailsGroupId": "cardsLanding",
                                                "detailViewId": "twoColorsLanding"
                                            }
                                        },
                                        {
                                            "buttonText": "Войти и перевести",
                                            "buttonStyle": "whiteRed",
                                            "action": {
                                                "actionType": "goToMain"
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "WHITE",
                                    "spacingType": "BIG"
                                }
                            }
                        ]
                    },
                    {
                        "detailViewId": "Kirgizstan",
                        "dataView": [
                            {
                                "type": "ICON_WITH_TWO_TEXT_LINES",
                                "data": {
                                    "md5hash": "c2deb01d90d0234a073890d37e0fb06d",
                                    "title": "Кыргызстан"
                                }
                            },
                            {
                                "type": "LIST_VERTICAL_ROUND_IMAGE",
                                "data": {
                                    "list": [
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "0%",
                                            "subTitle": "при переводе с конвертацией"
                                        },
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "1% мин. 70 ₽/2 $",
                                            "subTitle": "при переводе в единой валюте"
                                        },
                                        {
                                            "md5hash": "8b894449c5e9d69cc57dc14a6e8027f2",
                                            "title": "Отправка",
                                            "subTitle": "по ФИО получателя"
                                        },
                                        {
                                            "md5hash": "a2f253f0cab9f4dc4508ee4c4ec7795f",
                                            "title": "Получение",
                                            "subTitle": "наличными в ₽ или $"
                                        },
                                        {
                                            "md5hash": "8fce20724f54a0e8ceec048748efab00",
                                            "title": "Лимит",
                                            "subTitle": "до 150 000 ₽ в месяц"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_BUTTONS",
                                "data": {
                                    "list": [
                                        {
                                            "buttonText": "Заказать карту",
                                            "buttonStyle": "blackWhite",
                                            "details": {
                                                "detailsGroupId": "cardsLanding",
                                                "detailViewId": "twoColorsLanding"
                                            }
                                        },
                                        {
                                            "buttonText": "Войти и перевести",
                                            "buttonStyle": "whiteRed",
                                            "action": {
                                                "actionType": "goToMain"
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "WHITE",
                                    "spacingType": "BIG"
                                }
                            }
                        ]
                    },
                    {
                        "detailViewId": "Moldova",
                        "dataView": [
                            {
                                "type": "ICON_WITH_TWO_TEXT_LINES",
                                "data": {
                                    "md5hash": "d194c0a995d5e0bfd67b6db71e99f1e5",
                                    "title": "Молдова"
                                }
                            },
                            {
                                "type": "LIST_VERTICAL_ROUND_IMAGE",
                                "data": {
                                    "list": [
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "0%",
                                            "subTitle": "при переводе с конвертацией"
                                        },
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "1% мин. 70 ₽/2 $",
                                            "subTitle": "при переводе в единой валюте"
                                        },
                                        {
                                            "md5hash": "8b894449c5e9d69cc57dc14a6e8027f2",
                                            "title": "Отправка",
                                            "subTitle": "по ФИО получателя"
                                        },
                                        {
                                            "md5hash": "a2f253f0cab9f4dc4508ee4c4ec7795f",
                                            "title": "Получение",
                                            "subTitle": "наличными в ₽ или $"
                                        },
                                        {
                                            "md5hash": "8fce20724f54a0e8ceec048748efab00",
                                            "title": "Лимит",
                                            "subTitle": "до 300 000 ₽ в месяц"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_BUTTONS",
                                "data": {
                                    "list": [
                                        {
                                            "buttonText": "Заказать карту",
                                            "buttonStyle": "blackWhite",
                                            "details": {
                                                "detailsGroupId": "cardsLanding",
                                                "detailViewId": "twoColorsLanding"
                                            }
                                        },
                                        {
                                            "buttonText": "Войти и перевести",
                                            "buttonStyle": "whiteRed",
                                            "action": {
                                                "actionType": "goToMain"
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "WHITE",
                                    "spacingType": "BIG"
                                }
                            }
                        ]
                    },
                    {
                        "detailViewId": "Turkey",
                        "dataView": [
                            {
                                "type": "ICON_WITH_TWO_TEXT_LINES",
                                "data": {
                                    "md5hash": "a6c13609939eb58093394ff12b0cf650",
                                    "title": "Турция"
                                }
                            },
                            {
                                "type": "LIST_VERTICAL_ROUND_IMAGE",
                                "data": {
                                    "list": [
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "0%"
                                        },
                                        {
                                            "md5hash": "8b894449c5e9d69cc57dc14a6e8027f2",
                                            "title": "Отправка",
                                            "subTitle": "по ФИО получателя"
                                        },
                                        {
                                            "md5hash": "a2f253f0cab9f4dc4508ee4c4ec7795f",
                                            "title": "Получение",
                                            "subTitle": "наличными в $"
                                        },
                                        {
                                            "md5hash": "8fce20724f54a0e8ceec048748efab00",
                                            "title": "Лимит",
                                            "subTitle": "до 150 000 ₽ в месяц"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_BUTTONS",
                                "data": {
                                    "list": [
                                        {
                                            "buttonText": "Заказать карту",
                                            "buttonStyle": "blackWhite",
                                            "details": {
                                                "detailsGroupId": "cardsLanding",
                                                "detailViewId": "twoColorsLanding"
                                            }
                                        },
                                        {
                                            "buttonText": "Войти и перевести",
                                            "buttonStyle": "whiteRed",
                                            "action": {
                                                "actionType": "goToMain"
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "WHITE",
                                    "spacingType": "BIG"
                                }
                            }
                        ]
                    },
                    {
                        "detailViewId": "Uzbekistan",
                        "dataView": [
                            {
                                "type": "ICON_WITH_TWO_TEXT_LINES",
                                "data": {
                                    "md5hash": "c63878a33f9caef203972501cbd06359",
                                    "title": "Узбекистан"
                                }
                            },
                            {
                                "type": "LIST_VERTICAL_ROUND_IMAGE",
                                "data": {
                                    "list": [
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "0%",
                                            "subTitle": "при переводе с конвертацией"
                                        },
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "1,5% мин. 70 ₽/2 $",
                                            "subTitle": "при переводе в единой валюте"
                                        },
                                        {
                                            "md5hash": "8b894449c5e9d69cc57dc14a6e8027f2",
                                            "title": "Отправка",
                                            "subTitle": "по ФИО получателя"
                                        },
                                        {
                                            "md5hash": "a2f253f0cab9f4dc4508ee4c4ec7795f",
                                            "title": "Получение",
                                            "subTitle": "наличными в $"
                                        },
                                        {
                                            "md5hash": "8fce20724f54a0e8ceec048748efab00",
                                            "title": "Лимит",
                                            "subTitle": "до 300 000 ₽ в месяц"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_BUTTONS",
                                "data": {
                                    "list": [
                                        {
                                            "buttonText": "Заказать карту",
                                            "buttonStyle": "blackWhite",
                                            "details": {
                                                "detailsGroupId": "cardsLanding",
                                                "detailViewId": "twoColorsLanding"
                                            }
                                        },
                                        {
                                            "buttonText": "Войти и перевести",
                                            "buttonStyle": "whiteRed",
                                            "action": {
                                                "actionType": "goToMain"
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "WHITE",
                                    "spacingType": "BIG"
                                }
                            }
                        ]
                    },
                    {
                        "detailViewId": "Uzhnaya Osetia",
                        "dataView": [
                            {
                                "type": "ICON_WITH_TWO_TEXT_LINES",
                                "data": {
                                    "md5hash": "ebcf044a5f0d6ec8b3531fbe167e304c",
                                    "title": "Южная Осетия"
                                }
                            },
                            {
                                "type": "LIST_VERTICAL_ROUND_IMAGE",
                                "data": {
                                    "list": [
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "0%",
                                            "subTitle": "при переводе с конвертацией"
                                        },
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "2% мин. 70 ₽/2 $",
                                            "subTitle": "при переводе в единой валюте"
                                        },
                                        {
                                            "md5hash": "8b894449c5e9d69cc57dc14a6e8027f2",
                                            "title": "Отправка",
                                            "subTitle": "по ФИО получателя"
                                        },
                                        {
                                            "md5hash": "a2f253f0cab9f4dc4508ee4c4ec7795f",
                                            "title": "Получение",
                                            "subTitle": "наличными в ₽, $ или €"
                                        },
                                        {
                                            "md5hash": "8fce20724f54a0e8ceec048748efab00",
                                            "title": "Лимит",
                                            "subTitle": "до 300 000 ₽ в месяц"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_BUTTONS",
                                "data": {
                                    "list": [
                                        {
                                            "buttonText": "Заказать карту",
                                            "buttonStyle": "blackWhite",
                                            "details": {
                                                "detailsGroupId": "cardsLanding",
                                                "detailViewId": "twoColorsLanding"
                                            }
                                        },
                                        {
                                            "buttonText": "Войти и перевести",
                                            "buttonStyle": "whiteRed",
                                            "action": {
                                                "actionType": "goToMain"
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "WHITE",
                                    "spacingType": "BIG"
                                }
                            }
                        ]
                    },
                    {
                        "detailViewId": "Armeniya",
                        "dataView": [
                            {
                                "type": "ICON_WITH_TWO_TEXT_LINES",
                                "data": {
                                    "md5hash": "6046e5eaff596a41ce9845cca3b0a887",
                                    "title": "Армения"
                                }
                            },
                            {
                                "type": "LIST_VERTICAL_ROUND_IMAGE",
                                "data": {
                                    "list": [
                                        {
                                            "md5hash": "6da1aded1d5143877cdd3d9d84d7d018",
                                            "title": "1%",
                                            "subTitle": "мин. 100 ₽, макс. 5 000₽"
                                        },
                                        {
                                            "md5hash": "8b894449c5e9d69cc57dc14a6e8027f2",
                                            "title": "Отправка",
                                            "subTitle": "по номеру телефона получателя"
                                        },
                                        {
                                            "md5hash": "a2f253f0cab9f4dc4508ee4c4ec7795f",
                                            "title": "Получение",
                                            "subTitle": "на карту или счет получателя в банках-партнерах"
                                        },
                                        {
                                            "md5hash": "8fce20724f54a0e8ceec048748efab00",
                                            "title": "Лимит",
                                            "subTitle": "до 1 000 000 ₽ в месяц"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "LIST_HORIZONTAL_ROUND_IMAGE",
                                "data": {
                                    "title": "Банки партнеры",
                                    "list": [
                                        {
                                            "md5hash": "1498e6b4a776464eb4e7fd845c221f06",
                                            "title": "Эвокабанк"
                                        },
                                        {
                                            "md5hash": "d5861f90100c97706a6952e0dca2e0c2",
                                            "title": "Ардшинбанк"
                                        },
                                        {
                                            "md5hash": "21b6a406c583929effd620f8853c1a39",
                                            "title": "IDBank"
                                        },
                                        {
                                            "md5hash": "27540fc63bd4e0e91165e4af3934f95b",
                                            "title": "АрраратБанк"
                                        },
                                        {
                                            "md5hash": "a9571b421f9a680cc42564240b4b63e9",
                                            "title": "АрмББ"
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "MULTI_BUTTONS",
                                "data": {
                                    "list": [
                                        {
                                            "buttonText": "Заказать карту",
                                            "buttonStyle": "blackWhite",
                                            "details": {
                                                "detailsGroupId": "cardsLanding",
                                                "detailViewId": "twoColorsLanding"
                                            }
                                        },
                                        {
                                            "buttonText": "Войти и перевести",
                                            "buttonStyle": "whiteRed",
                                            "action": {
                                                "actionType": "goToMain"
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "type": "VERTICAL_SPACING",
                                "data": {
                                    "backgroundColor": "WHITE",
                                    "spacingType": "BIG"
                                }
                            }
                        ]
                    }
                ]
            }
        ],
        "serial": "d706714ec041828eadf4b46af8cdb662"
    }
}

"""
    
    static let limits: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": {
        "header": [
          {
            "type": "PAGE_TITLE",
            "data": {
              "title": "Управление",
              "transparency": false
            }
          }
        ],
        "main": [
          {
            "type": "NAILED_CARD_ACTIONS",
            "data": {}
          },
          {
            "type": "LIST_HORIZONTAL_RECTANGLE_LIMITS",
            "data": {
              "list": [
                {
                  "md5hash": "7cc9921ddb97efc14a7de912106ea0d4",
                  "title": "Платежи и переводы",
                  "limitType": "DEBIT_OPERATIONS",
                  "limit": [
                    {
                      "id": "LMTTZ01",
                      "colorHEX": "#1C1C1C",
                      "title": "Осталось сегодня"
                    },
                    {
                      "id": "LMTTZ02",
                      "colorHEX": "#FF3636",
                      "title": "Осталось в этом месяце"
                    }
                  ],
                  "action": {
                    "actionType": "changeLimit"
                  }
                },
                {
                  "md5hash": "bec5d6f65faaea15f56cd46b86a78897",
                  "title": "Снятие наличных",
                  "limitType": "WITHDRAWAL",
                  "limit": [
                    {
                      "id": "LMTTZ03",
                      "colorHEX": "#1C1C1C",
                      "title": "Осталось сегодня"
                    },
                    {
                      "id": "LMTTZ04",
                      "colorHEX": "#FF3636",
                      "title": "Осталось в этом месяце"
                    }
                  ],
                  "action": {
                    "actionType": "changeLimit"
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
                  "imageLink": "dict/getProductCatalogImage?image=/products/banners/ordering_additional_card.png",
                  "link": "https://www.forabank.ru/private/cards/",
                  "details": {
                    "detailsGroupId": "QR_SCANNER",
                    "detailViewId": null
                  }
                },
                {
                  "imageLink": "dict/getBannerCatalogImage?image=/products/banners/Georgia_12_12_2023.png",
                  "link": "",
                  "details": {
                    "detailsGroupId": "CONTACT_TRANSFER",
                    "detailViewId": "GE"
                  }
                },
                {
                  "imageLink": "dict/getProductCatalogImage?image=/products/banners/payWithSticker.png",
                  "link": "",
                  "details": {
                    "detailsGroupId": "LANDING",
                    "detailViewId": "abroadSticker"
                  }
                }
              ]
            }
          },
          {
            "type": "LIST_VERTICAL_ROUND_IMAGE",
            "data": {
              "title": "Прочее",
              "list": [
                {
                  "md5hash": "fdcc2b1f146ed76ce73629f4a35d9b7d",
                  "title": "Управление подписками",
                  "action": {
                    "actionType": "subscriptionControl"
                  }
                }
              ]
            }
          }
        ],
      "serial": "d706714ec041828eadf4b46af8cdb662"
      },
    }
    """
   
    static let limitsWithErrorsInMain: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": {
        "header": [
          {
            "type": "PAGE_TITLE",
            "data": {
              "title": "Управление",
              "transparency": false
            }
          }
        ],
        "main": [
          {
            "type": "NAILED_CARD_ACTIONS",
            "data": {}
          },
          {
            "type": "LIST_HORIZONTAL_RECTANGLE_LIMITS",
            "data": {
              "list": [
                {
                  "md5hash": "7cc9921ddb97efc14a7de912106ea0d4",
                  "title": "Платежи и переводы",
                  "limitType": "DEBIT_OPERATIONS",
                  "limit": [
                    {
                      "id": "LMTTZ01",
                      "colorHEX": "#1C1C1C",
                      "title": "Осталось сегодня"
                    },
                    {
                      "id": "LMTTZ02",
                      "colorHEX": "#FF3636",
                      "title": "Осталось в этом месяце"
                    }
                  ],
                  "action": {
                    "actionType": "changeLimit"
                  }
                },
                {
                  "md5hash": "bec5d6f65faaea15f56cd46b86a78897",
                  "title": "Снятие наличных",
                  "limitType": "WITHDRAWAL",
                  "limit": [
                    {
                      "id": "LMTTZ03",
                      "colorHEX": "#1C1C1C",
                      "title": "Осталось сегодня"
                    },
                    {
                      "id": "LMTTZ04",
                      "colorHEX": "#FF3636",
                      "title": "Осталось в этом месяце"
                    }
                  ],
                  "action": {
                    "actionType": "changeLimit"
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
                  "image": "dict/getProductCatalogImage?image=/products/banners/ordering_additional_card.png",
                  "link": "https://www.forabank.ru/private/cards/",
                  "details": {
                    "detailsGroupId": "QR_SCANNER",
                    "detailViewId": null
                  }
                },
                {
                  "imageLink": "dict/getBannerCatalogImage?image=/products/banners/Georgia_12_12_2023.png",
                  "link": "",
                  "details": {
                    "details": "CONTACT_TRANSFER",
                    "detailViewId": "GE"
                  }
                },
                {
                  "imageLink": "dict/getProductCatalogImage?image=/products/banners/payWithSticker.png",
                  "link": "",
                  "details": {
                    "detailsGroupId": "LANDING",
                    "detai": "abroadSticker"
                  }
                }
              ]
            }
          },
          {
            "type": "LIST_VERTICAL_ROUND_IMAGE",
            "data": {
              "title": "Прочее",
              "list": [
                {
                  "md5hash": "fdcc2b1f146ed76ce73629f4a35d9b7d",
                  "title": "Управление подписками",
                  "action": {
                    "actionType": "subscriptionControl"
                  }
                }
              ]
            }
          }
        ],
      "serial": "d706714ec041828eadf4b46af8cdb662"
      },
    }
    """

    static let limitSettings: Self = """
    {
      "statusCode": 0,
      "errorMessage": null,
      "data": {
        "header": [
          {
            "type": "PAGE_TITLE",
            "data": {
              "title": "Настройка лимитов",
              "transparency": false
            }
          }
        ],
        "main": [
          {
            "type": "BLOCK_HORIZONTAL_RECTANGULAR",
            "data": {
              "list": [
                {
                  "title": "Лимит платежей и переводов",
                  "description": "Переводы себе, другим людям и организациям, оплата услуг в приложении",
                  "limitType": "DEBIT_OPERATIONS",
                  "limit": [
                    {
                      "md5hash": "16f4b68434e5d9bb15f03dedc525e77b",
                      "id": "LMTTZ01",
                      "title": "В день",
                      "text": "Сумма",
                      "maxSum": 999999999
                    },
                    {
                      "md5hash": "16f4b68434e5d9bb15f03dedc525e77b",
                      "id": "LMTTZ02",
                      "title": "В месяц",
                      "text": "Сумма",
                      "maxSum": 999999999
                    }
                  ]
                },
                {
                  "title": "Лимит снятия наличных",
                  "description": "Снятие наличных в банкоматах или операции приравненные к снятию наличных",
                  "limitType": "WITHDRAWAL",
                  "limit": [
                    {
                      "md5hash": "16f4b68434e5d9bb15f03dedc525e77b",
                      "id": "LMTTZ03",
                      "title": "В день",
                      "text": "Сумма",
                      "maxSum": 150000
                    },
                    {
                      "md5hash": "16f4b68434e5d9bb15f03dedc525e77b",
                      "id": "LMTTZ04",
                      "title": "В месяц",
                      "text": "Сумма",
                      "maxSum": 500000
                    }
                  ]
                }
              ]
            }
          },
          {
            "type": "LIST_DROP_DOWN_TEXTS",
            "data": {
              "title": "Часто задаваемые вопросы",
              "list": [
                {
                  "title": "Безопасность",
                  "description": "Лимиты это очень безопасно. Благодаря им Вы можете контролировать свои траты."
                },
                {
                  "title": "Двойная конвертация",
                  "description": "Это двукратный обмен валют. Такое может случиться, если Вы рассчитываетесь своей рублевой картой в стране, чья валюта не является ни рублем, ни долларом или евро."
                },
                {
                  "title": "В какой валюте можно оплатить картой?",
                  "description": "Валюта зависит от страны оплаты."
                },
                {
                  "title": "Какую сумму можно оплатить по моей карте в онлайн-магазинах?",
                  "description": "Ту которая у вас указана в лимите для платежей и переводов."
                },
                {
                  "title": "В каких банкоматах можно снимать деньги с моей карты?",
                  "description": "Вы можете ознакомиться со списком банкоматов на главном экране мобильного приложения в блоке - Отделения и банкоматы."
                }
              ]
            }
          }
        ],
        "serial": "33c455e8b1f3d298dbb1d846885c176e"
      }
    }
    """
    
    static let error: Self = """
{"statusCode":404,"errorMessage":"404: Не найден запрос к серверу","data":null}
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
    
    var multiLineHeaders: [Landing.DataView.Multi.LineHeader] {
        
        compactMap {
            if case let .multi(.lineHeader(multiLineHeader)) = $0 {
                return multiLineHeader
            } else {
                return nil
            }
        }
    }
    
    var multiTexts: [Landing.DataView.Multi.Text] {
        
        compactMap {
            if case let .multi(.text(multiText)) = $0 {
                return multiText
            } else {
                return nil
            }
        }
    }
    
    var multiMarkersTexts: [Landing.DataView.Multi.MarkersText] {
        
        compactMap {
            if case let .multi(.markersText(multiMarkersText)) = $0 {
                return multiMarkersText
            } else {
                return nil
            }
        }
    }
    
    var muiltiTextsWithIconsHorizontals: [Landing.DataView.Multi.TextsWithIconsHorizontal] {
        
        compactMap {
            if case let .multi(.textsWithIconsHorizontalArray(muiltiTextsWithIconsHorizontal)) = $0 {
                return muiltiTextsWithIconsHorizontal
            } else {
                return nil
            }
        }
    }
    
    var listVerticalRoundImages: [Landing.DataView.List.VerticalRoundImage] {
        
        compactMap {
            if case let .list(.verticalRoundImage(listVerticalRoundImage)) = $0 {
                return listVerticalRoundImage
            } else {
                return nil
            }
        }
    }
    
    var listHorizontalRoundImages: [Landing.DataView.List.HorizontalRoundImage] {
        
        compactMap {
            if case let .list(.horizontalRoundImage(listHorizontalRoundImage)) = $0 {
                return listHorizontalRoundImage
            } else {
                return nil
            }
        }
    }
    
    var listHorizontalRectangleImages: [Landing.DataView.List.HorizontalRectangleImage] {
        
        compactMap {
            if case let .list(.horizontalRectangleImage(listHorizontalRectangleImage)) = $0 {
                return listHorizontalRectangleImage
            } else {
                return nil
            }
        }
    }
    
    var listHorizontalRectangleLimits: [Landing.DataView.List.HorizontalRectangleLimits] {
        
        compactMap {
            if case let .list(.horizontalRectangleLimits(listHorizontalRectangleLimits)) = $0 {
                return listHorizontalRectangleLimits
            } else {
                return nil
            }
        }
    }
    
    var multiButtons: [Landing.DataView.Multi.Buttons] {
        
        compactMap {
            if case let .multi(.buttons(multiButtons)) = $0 {
                return multiButtons
            } else {
                return nil
            }
        }
    }
    
    var multiTypeButtons: [Landing.DataView.Multi.TypeButtons] {
        
        compactMap {
            if case let .multi(.typeButtons(typeButtons)) = $0 {
                return typeButtons
            } else {
                return nil
            }
        }
    }
    
    var images: [Landing.ImageBlock] {
        
        compactMap {
            if case let .image(images) = $0 {
                return images
            } else {
                return nil
            }
        }
    }
    
    var imageSvgs: [Landing.ImageSvg] {
        
        compactMap {
            if case let .imageSvg(imageSvgs) = $0 {
                return imageSvgs
            } else {
                return nil
            }
        }
    }
    
    var listDropDownTexts: [Landing.DataView.List.DropDownTexts] {
        
        compactMap {
            if case let .list(.dropDownTexts(texts)) = $0 {
                return texts
            } else {
                return nil
            }
        }
    }
    
    var spacing: [Landing.VerticalSpacing] {
        
        compactMap {
            if case let .verticalSpacing(indents) = $0 {
                return indents
            } else {
                return nil
            }
        }
    }
    
    var blocksHorizontalRectangular: [Landing.BlockHorizontalRectangular] {
        
        compactMap {
            if case let .blockHorizontalRectangular(blockHorizontalRectangular) = $0 {
                return blockHorizontalRectangular
            } else {
                return nil
            }
        }
    }
}
