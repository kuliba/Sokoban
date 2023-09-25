//
//  Mapper.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import Foundation

public struct LandingMapper {
    
    public typealias Result = Swift.Result<Landing, MapperError>
    
    public static func map(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> Result {
        
        guard response.statusCode == 200 else {
            return .failure(.notOkStatus)
            
        }
        return dataToLanding(data)
    }
    
    public enum MapperError: Error {
        
        case notOkStatus
        case mapError
    }
    
    private static func dataToLanding(_ data: Data) -> Result {
        
        if let decoded = try? decode(data) {
            let landing = Self.decodeLandingToLanding(decoded)
            return .success(landing)
        }
        return .failure(.mapError)
    }
    
    private static func decode(_ data: Data) throws -> DecodableLanding {
        
        let str = String(decoding: data, as: UTF8.self)
        let correctedString = str.replacingOccurrences(of: ".\n", with: ".\\n")
        let dataCorrected: Data = correctedString.data(using: .utf8) ?? .init()

        return try JSONDecoder().decode(DecodableLanding.self, from: dataCorrected)
    }
    
    private static func decodeLandingToLanding(
        _ decodeLanding: DecodableLanding
    ) -> Landing {
        
        let errorMessage: String? = decodeLanding.errorMessage
        let code: Int = decodeLanding.statusCode
        let serial: String? = decodeLanding.data?.serial
        let header: [Landing.DataView] = decodeLanding.data?.header?.compactMap(Landing.DataView.init(data:)) ?? []
        let main: [Landing.DataView] = decodeLanding.data?.main.compactMap(Landing.DataView.init(data:)) ?? []
        let footer: [Landing.DataView] = decodeLanding.data?.footer?.compactMap (Landing.DataView.init(data:)) ?? []
        let details: [Landing.Detail] = decodeLanding.data?.details?.compactMap (Landing.Detail.init(data:)) ?? []
        
        let landing: Landing = .init(
            header: header,
            main: main,
            footer: footer,
            details: details,
            serial: serial,
            statusCode: code,
            errorMessage: errorMessage
        )
        
        return landing
    }
}

// MARK: - private inits

private extension Landing.IconWithTwoTextLines {
    
    init(
        data: DecodableLanding.Data.IconWithTwoTextLines
    ) {
        
        self.md5hash = data.md5hash
        self.title = data.title
        self.subTitle = data.subTitle
    }
}

private extension Landing.DataView {
    
    init?(
        data: DecodableLanding.Data.DataView
    ) {
        
        switch data {
            
        case .noValid:
            return nil
            
        case let .iconWithTwoTextLines(x):
            self = .iconWithTwoTextLines(.init(data: x))
            
        case let .list(.horizontalRectangleImage(x)):
            self = .list(.horizontalRectangleImage(.init(data: x)))
            
        case let .list(.horizontalRoundImage(x)):
            self = .list(.horizontalRoundImage(.init(data: x)))
            
        case let .list(.verticalRoundImage(x)):
            self = .list(.verticalRoundImage(.init(data: x)))
            
        case let .multi(.lineHeader(x)):
            self = .multi(.lineHeader(.init(data: x)))
            
        case let .multi(.markersText(x)):
            self = .multi(.markersText(.init(data: x)))
            
        case let .multi(.text(x)):
            self = .multi(.text(.init(data: x)))
            
        case let .multi(.textsWithIconsHorizontalArray(x)):
            self = .multi(.textsWithIconsHorizontalArray(.init(data: x)))
            
        case let .pageTitle(x):
            self = .pageTitle(.init(data: x))
            
        case let .textsWithIconHorizontal(x):
            self = .textsWithIconHorizontal(.init(data: x))
            
        case let .multi(.buttons(x)):
            self = .multi(.buttons(.init(data: x)))
            
        case let .multi(.typeButtons(x)):
            self = .multi(.typeButtons(.init(data: x)))
            
        case let .image(x):
            self = .image(.init(data: x))
            
        case let .imageSvg(x):
            self = .imageSvg(.init(data: x))
            
        case let .list(.dropDownTexts(x)):
            self = .list(.dropDownTexts(.init(data: x)))
            
        case let .verticalSpacing(x):
            self = .verticalSpacing(.init(data: x))
        }
    }
}

private extension Landing.VerticalSpacing {
    
    init(
        data: DecodableLanding.Data.VerticalSpacing
    ) {
        
        self.init(
            backgroundColor: .init(data.backgroundColor),
            type: .init(data.type))
    }
}

private extension Landing.ListDropDownTexts {
    
    init(
        data: DecodableLanding.Data.ListDropDownTexts
    ) {
        
        self.init(
            title: data.title.map{.init($0)},
            list: data.list.compactMap {
                .init(data:$0)
            }
        )
    }
}

private extension Landing.ListDropDownTexts.Item {
    
    init(
        data: DecodableLanding.Data.ListDropDownTexts.Item
    ) {
        self.init(
            title: data.title,
            description: data.description
        )
    }
}

private extension Landing.ImageSvg {
    
    init(
        data: DecodableLanding.Data.ImageSvg
    ) {
        self.init(
            backgroundColor: .init(rawValue: data.backgroundColor),
            md5hash: .init(rawValue: data.md5hash)
        )
    }
}

private extension Landing.ImageBlock {
    
    init(
        data: DecodableLanding.Data.ImageBlock
    ) {
        self.init(
            withPlaceholder: .init(rawValue: data.withPlaceholder),
            backgroundColor: .init(rawValue: data.backgroundColor),
            link: .init(rawValue: data.link)
        )
    }
}

private extension Landing.MultiTypeButtons {
    
    init(
        data: DecodableLanding.Data.MultiTypeButtons
    ) {
        self.init(
            md5hash: data.md5hash,
            backgroundColor: data.backgroundColor,
            text: data.text,
            buttonText: data.buttonText,
            buttonStyle: data.buttonStyle,
            textLink: data.textLink,
            action: data.action.map{.init(data: $0)},
            detail: data.detail.map{.init(data: $0)})
    }
}

private extension Landing.MultiTypeButtons.Action {
    
    init(
        data: DecodableLanding.Data.MultiTypeButtons.Action
    ) {
        self.init(
            type: data.type,
            outputData: data.outputData.map {
                .init(data: $0)
            })
    }
}

private extension Landing.MultiTypeButtons.Action.OutputData {
    
    init(
        data: DecodableLanding.Data.MultiTypeButtons.Action.OutputData
    ) {
        self.init(
            tarif: .init(rawValue: data.tarif),
            type: .init(rawValue: data.type))
    }
}

private extension Landing.MultiTypeButtons.Detail {
    
    init(
        data: DecodableLanding.Data.MultiTypeButtons.Detail
    ) {
        self.init(groupId: .init(rawValue: data.groupId), viewId: .init(rawValue: data.viewId))
    }
}
private extension Landing.MultiButtons {
    
    init(
        data: DecodableLanding.Data.MultiButtons
    ) {
        self.init(
            list: data.list.map(Landing.MultiButtons.Item.init(data:)))
    }
}

private extension Landing.MultiButtons.Item {
    
    init(
        data: DecodableLanding.Data.MultiButtons.Item
    ) {
        
        let detail: Landing.MultiButtons.Item.Detail? = data.detail.map(Landing.MultiButtons.Item.Detail.init(data:))
        
        let action: Landing.MultiButtons.Item.Action? = data.action.map(Landing.MultiButtons.Item.Action.init(data:))
        
        self.init(
            text: data.text,
            style: data.style,
            detail: detail,
            link: data.link,
            action: action
        )
    }
}

private extension Landing.MultiButtons.Item.Detail {
    
    init(
        data: DecodableLanding.Data.MultiButtons.Item.Detail
    ) {
        let groupId: Landing.MultiButtons.Item.Detail.GroupId = .init(rawValue: data.groupId)
        let viewId: Landing.MultiButtons.Item.Detail.ViewId = .init(rawValue: data.viewId)
        
        self.init(groupId: groupId, viewId: viewId)
    }
}

private extension Landing.MultiButtons.Item.Action {
    
    init(
        data: DecodableLanding.Data.MultiButtons.Item.Action
    ) {
        self.init(type: .init(rawValue: data.type))
    }
}

private extension Landing.MultiMarkersText {
    
    init(
        data: DecodableLanding.Data.MultiMarkersText
    ) {
        let list: [Landing.MultiMarkersText.Text] = data.list?.compactMap {
                return Landing.MultiMarkersText.Text.init($0)
        } ?? []
        
        self.init(
            backgroundColor: data.backgroundColor,
            style: data.style,
            list: list)
    }
}

private extension Landing.ListVerticalRoundImage {
    
    init(
        data: DecodableLanding.Data.ListVerticalRoundImage
    ) {
        self.init(
            title: data.title,
            displayedCount: data.displayedCount,
            dropButtonOpenTitle: data.dropButtonOpenTitle,
            dropButtonCloseTitle: data.dropButtonCloseTitle,
            list: data.list.compactMap {
                if let data = $0 {
                    
                    return .init(data: data)
                }
                return nil
            }
        )
    }
}

private extension Landing.ListVerticalRoundImage.ListItem {
    
    init(
        data: DecodableLanding.Data.ListVerticalRoundImage.ListItem
    ) {
        self.init(
            md5hash: data.md5hash,
            title: data.title,
            subInfo: data.subInfo,
            link: data.link,
            appStore: data.appStore,
            googlePlay: data.googlePlay,
            detail: data.detail.map(Landing.ListVerticalRoundImage.ListItem.Detail.init(data:))
        )
    }
}

private extension Landing.ListVerticalRoundImage.ListItem.Detail {
    
    init(
        data: DecodableLanding.Data.ListVerticalRoundImage.ListItem.Detail
    ) {
        self.init(
            groupId: .init(data.groupId),
            viewId: .init(data.viewId)
        )
    }
}

private extension Landing.MultiText {
    
    init(
        data: DecodableLanding.Data.MultiText
    ) {
        let text: [Landing.MultiText.Text] = data.list.compactMap {
            
            if let text = $0 {
                return Landing.MultiText.Text.init(text)
            }
            return nil
        }
        self.init(text: text)
    }
}

private extension Landing.ListHorizontalRectangleImage {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRectangleImage
    ) {
        
        self.list = data.list.map { Landing.ListHorizontalRectangleImage.Item.init(data:$0)
        }
    }
}

private extension Landing.ListHorizontalRectangleImage.Item {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRectangleImage.Item
    ) {
        
        let detail: Landing.ListHorizontalRectangleImage.Item.Detail? = {
            
            if let details = data.detail {
                return .init(
                    groupId: details.groupId,
                    viewId: details.viewId)
            }
            return nil
        }()
        
        self.init(imageLink: data.imageLink, link: data.link, detail: detail)
    }
}

private extension Landing.ListHorizontalRectangleImage.Item.Detail {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRectangleImage.Item.Detail
    ) {
        
        self.init(
            groupId: data.groupId,
            viewId: data.viewId)
    }
}

private extension Landing.ListHorizontalRoundImage {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRoundImage
    ) {
        
        self.list =  {
            data.list?.map { Landing.ListHorizontalRoundImage.ListItem.init(data:$0)
                
            }
        }()
        
        self.title = data.title
    }
}

private extension Landing.ListHorizontalRoundImage.ListItem {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRoundImage.ListItem
    ) {
        self.md5hash = data.md5hash
        self.title = data.title
        self.subInfo = data.subInfo
        self.detail = data.detail.map(Landing.ListHorizontalRoundImage.ListItem.Detail.init(data:))
    }
}

private extension Landing.ListHorizontalRoundImage.ListItem.Detail {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRoundImage.ListItem.Detail
    ) {
        self.groupId = .init(rawValue: data.groupId)
        self.viewId = .init(rawValue: data.viewId)
    }
}

private extension Landing.MuiltiTextsWithIconsHorizontal {
    
    init(
        data: [DecodableLanding.Data.MultiTextsWithIconsHorizontal]
    ) {
        
        let listItem: [Landing.MuiltiTextsWithIconsHorizontal.Item] = data.map {
            
            .init(md5hash: $0.md5hash, title: $0.title)
        }
        self.init(list: listItem)
    }
}

private extension Landing.MultiLineHeader {
    
    init(
        data: DecodableLanding.Data.MultiLineHeader
    ) {
        self.backgroundColor = data.backgroundColor
        self.regularTextList = data.regularTextList
        self.boldTextList = data.boldTextList
    }
}

private extension Landing.PageTitle {
    
    init(
        data: DecodableLanding.Data.PageTitle
    ) {
        self.text = data.title
        self.transparency = data.transparency
        self.subtitle = data.subTitle
    }
}

private extension Landing.Detail {
    
    init(
        data: DecodableLanding.Data.Detail
    ) {
        self.groupId = data.groupId
        self.dataGroup = data.dataGroup.map{ Landing.Detail.DataGroup(data: $0) }
    }
}

private extension Landing.Detail.DataGroup {
    
    init(
        data: DecodableLanding.Data.Detail.DataGroup
    ) {
        self.viewId = data.viewId
        self.dataView = data.dataView.compactMap( Landing.DataView.init(data:))
    }
}

private extension Landing.TextsWithIconHorizontal {
    
    init(
        data: DecodableLanding.Data.TextsWithIconHorizontal
    ) {
        self.md5hash = data.md5hash
        self.title = data.title
        self.contentCenterAndPull = data.contentCenterAndPull
    }
}
