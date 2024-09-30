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
            
        case let .blockHorizontalRectangular(data):
            self = .blockHorizontalRectangular(.init(data: data))
            
        case let .iconWithTwoTextLines(data):
            self = .iconWithTwoTextLines(.init(data: data))
            
        case let .list(.horizontalRectangleImage(data)):
            self = .list(.horizontalRectangleImage(.init(data: data)))
            
        case let .list(.horizontalRoundImage(data)):
            self = .list(.horizontalRoundImage(.init(data: data)))
            
        case let .list(.verticalRoundImage(data)):
            self = .list(.verticalRoundImage(.init(data: data)))
            
        case let .multi(.lineHeader(data)):
            self = .multi(.lineHeader(.init(data: data)))
            
        case let .multi(.markersText(data)):
            self = .multi(.markersText(.init(data: data)))
            
        case let .multi(.text(data)):
            self = .multi(.text(.init(data: data)))
            
        case let .multi(.textsWithIconsHorizontalArray(data)):
            self = .multi(.textsWithIconsHorizontalArray(.init(data: data)))
            
        case let .pageTitle(data):
            self = .pageTitle(.init(data: data))
            
        case let .textsWithIconHorizontal(data):
            self = .textsWithIconHorizontal(.init(data: data))
            
        case let .multi(.buttons(data)):
            self = .multi(.buttons(.init(data: data)))
            
        case let .multi(.typeButtons(data)):
            self = .multi(.typeButtons(.init(data: data)))
            
        case let .image(data):
            self = .image(.init(data: data))
            
        case let .imageSvg(data):
            self = .imageSvg(.init(data: data))
            
        case let .list(.dropDownTexts(data)):
            self = .list(.dropDownTexts(.init(data: data)))
            
        case let .verticalSpacing(data):
            self = .verticalSpacing(.init(data: data))
        case let .spacing(data):
            self = .spacing(.init(data: data))

        case let .list(.horizontalRectangleLimits(data)):
            self = .list(.horizontalRectangleLimits(.init(data: data)))
        case let .carousel(.base(data)):
            self = .carousel(.base(.init(data: data)))
        case let .carousel(.withTabs(data)):
            self = .carousel(.withTabs(.init(data: data)))
        case let .carousel(.withDots(data)):
            self = .carousel(.withDots(.init(data: data)))
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

private extension Landing.Spacing {
    
    init(
        data: DecodableLanding.Data.Spacing
    ) {
        
        self.init(
            backgroundColor: data.backgroundColor,
            sizeDp: data.sizeDp)
    }
}

private extension Landing.DataView.List.DropDownTexts {
    
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

private extension Landing.DataView.List.DropDownTexts.Item {
    
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

private extension Landing.DataView.Multi.TypeButtons {
    
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

private extension Landing.DataView.Multi.TypeButtons.Action {
    
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

private extension Landing.DataView.Multi.TypeButtons.Action.OutputData {
    
    init(
        data: DecodableLanding.Data.MultiTypeButtons.Action.OutputData
    ) {
        self.init(
            tarif: .init(rawValue: data.tarif),
            type: .init(rawValue: data.type))
    }
}

private extension Landing.DataView.Multi.TypeButtons.Detail {
    
    init(
        data: DecodableLanding.Data.MultiTypeButtons.Detail
    ) {
        self.init(groupId: .init(rawValue: data.groupId), viewId: .init(rawValue: data.viewId))
    }
}
private extension Landing.DataView.Multi.Buttons {
    
    init(
        data: DecodableLanding.Data.MultiButtons
    ) {
        self.init(
            list: data.list.map(Landing.DataView.Multi.Buttons.Item.init(data:)))
    }
}

private extension Landing.DataView.Multi.Buttons.Item {
    
    init(
        data: DecodableLanding.Data.MultiButtons.Item
    ) {
        
        let detail: Landing.DataView.Multi.Buttons.Item.Detail? = data.detail.map(Landing.DataView.Multi.Buttons.Item.Detail.init(data:))
        
        let action: Landing.DataView.Multi.Buttons.Item.Action? = data.action.map(Landing.DataView.Multi.Buttons.Item.Action.init(data:))
        
        self.init(
            text: data.text,
            style: data.style,
            detail: detail,
            link: data.link,
            action: action
        )
    }
}

private extension Landing.DataView.Multi.Buttons.Item.Detail {
    
    init(
        data: DecodableLanding.Data.MultiButtons.Item.Detail
    ) {
        let groupId: Landing.DataView.Multi.Buttons.Item.Detail.GroupId = .init(rawValue: data.groupId)
        let viewId: Landing.DataView.Multi.Buttons.Item.Detail.ViewId = .init(rawValue: data.viewId)
        
        self.init(groupId: groupId, viewId: viewId)
    }
}

private extension Landing.DataView.Multi.Buttons.Item.Action {
    
    init(
        data: DecodableLanding.Data.MultiButtons.Item.Action
    ) {
        self.init(type: .init(rawValue: data.type))
    }
}

private extension Landing.DataView.Multi.MarkersText {
    
    init(
        data: DecodableLanding.Data.MultiMarkersText
    ) {
        let list: [Landing.DataView.Multi.MarkersText.Text] = data.list?.compactMap {
            return Landing.DataView.Multi.MarkersText.Text.init($0)
        } ?? []
        
        self.init(
            backgroundColor: data.backgroundColor,
            style: data.style,
            list: list)
    }
}

private extension Landing.DataView.List.VerticalRoundImage {
    
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

private extension Landing.DataView.List.VerticalRoundImage.ListItem {
    
    init(
        data: DecodableLanding.Data.ListVerticalRoundImage.ListItem
    ) {
        let action: Landing.DataView.List.VerticalRoundImage.ListItem.Action?  = {
            
            guard let type = data.action?.type else { return nil }
            return .init(type: type)
        }()
        
        self.init(
            md5hash: data.md5hash,
            title: data.title,
            subInfo: data.subInfo,
            link: data.link,
            appStore: data.appStore,
            googlePlay: data.googlePlay,
            detail: data.detail.map(Landing.DataView.List.VerticalRoundImage.ListItem.Detail.init(data:)), 
            action: action
        )
    }
}

private extension Landing.DataView.List.VerticalRoundImage.ListItem.Detail {
    
    init(
        data: DecodableLanding.Data.ListVerticalRoundImage.ListItem.Detail
    ) {
        self.init(
            groupId: .init(data.groupId),
            viewId: .init(data.viewId)
        )
    }
}

private extension Landing.DataView.Multi.Text {
    
    init(
        data: DecodableLanding.Data.MultiText
    ) {
        let text: [Landing.DataView.Multi.Text.Text] = data.list.compactMap {
            
            if let text = $0 {
                return Landing.DataView.Multi.Text.Text.init(text)
            }
            return nil
        }
        self.init(text: text)
    }
}

private extension Landing.DataView.List.HorizontalRectangleImage {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRectangleImage
    ) {
        
        self.list = data.list.map { Landing.DataView.List.HorizontalRectangleImage.Item.init(data:$0)
        }
    }
}

private extension Landing.DataView.List.HorizontalRectangleImage.Item {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRectangleImage.Item
    ) {
        
        let detail: Landing.DataView.List.HorizontalRectangleImage.Item.Detail? = {
            
            if let details = data.detail {
                return .init(
                    groupId: details.groupId,
                    viewId: details.viewId ?? "")
            }
            return nil
        }()
        
        self.init(imageLink: data.imageLink, link: data.link, detail: detail)
    }
}

private extension Landing.DataView.List.HorizontalRectangleImage.Item.Detail {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRectangleImage.Item.Detail
    ) {
        
        self.init(
            groupId: data.groupId,
            viewId: data.viewId ?? "")
    }
}

private extension Landing.DataView.List.HorizontalRectangleLimits {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRectangleLimits
    ) {
        
        self.list = data.list.map { Landing.DataView.List.HorizontalRectangleLimits.Item.init(data:$0)
        }
    }
}

private extension Landing.DataView.List.HorizontalRectangleLimits.Item {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRectangleLimits.Item
    ) {
        self.init(action: .init(type: data.action.type), limitType: data.limitType, md5hash: data.md5hash, title: data.title, limits: data.limits.map { .init(data:$0) })
    }
}

private extension Landing.DataView.List.HorizontalRectangleLimits.Item.Limit {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRectangleLimits.Item.Limit
    ) {
        self.init(id: data.id, title: data.title, colorHEX: data.colorHEX)
    }
}

private extension Landing.BlockHorizontalRectangular {
    
    init(
        data: DecodableLanding.Data.BlockHorizontalRectangular
    ) {
        self.list = data.list.map { Landing.BlockHorizontalRectangular.Item.init(data:$0)
        }
    }
}

private extension Landing.BlockHorizontalRectangular.Item {
    
    init(
        data: DecodableLanding.Data.BlockHorizontalRectangular.Item
    ) {
        self.init(
            limitType: data.limitType,
            description: data.description ?? "",
            title: data.title ?? "",
            limits: data.limits.map { .init(data: $0) })
    }
}

private extension Landing.BlockHorizontalRectangular.Item.Limit {
    
    init(
        data: DecodableLanding.Data.BlockHorizontalRectangular.Item.Limit
    ) {
        self.init(
            id: data.id,
            title: data.title ?? "",
            md5hash: data.md5hash ?? "",
            text: data.text ?? "",
            maxSum: data.maxSum ?? 0)
    }
}

private extension Landing.DataView.List.HorizontalRoundImage {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRoundImage
    ) {
        
        self.list =  {
            data.list?.map { Landing.DataView.List.HorizontalRoundImage.ListItem.init(data:$0)
                
            }
        }()
        
        self.title = data.title
    }
}

private extension Landing.DataView.List.HorizontalRoundImage.ListItem {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRoundImage.ListItem
    ) {
        self.md5hash = data.md5hash
        self.title = data.title
        self.subInfo = data.subInfo
        self.detail = data.detail.map(Landing.DataView.List.HorizontalRoundImage.ListItem.Detail.init(data:))
    }
}

private extension Landing.DataView.List.HorizontalRoundImage.ListItem.Detail {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRoundImage.ListItem.Detail
    ) {
        self.groupId = .init(rawValue: data.groupId)
        self.viewId = .init(rawValue: data.viewId)
    }
}

private extension Landing.DataView.Multi.TextsWithIconsHorizontal {
    
    init(
        data: [DecodableLanding.Data.MultiTextsWithIconsHorizontal]
    ) {
        
        let listItem: [Landing.DataView.Multi.TextsWithIconsHorizontal.Item] = data.map {
            
            .init(md5hash: $0.md5hash, title: $0.title)
        }
        self.init(list: listItem)
    }
}

private extension Landing.DataView.Multi.LineHeader {
    
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

private extension Landing.DataView.Carousel.CarouselBase {
    
    init(
        data: DecodableLanding.Data.CarouselBaseDecodable
    ) {
        self.init(
            title: data.title,
            size: .init(size: data.size),
            scale: data.scale,
            loopedScrolling: data.loopedScrolling,
            list: data.list.map { .init(data: $0) })
    }
}

private extension Landing.DataView.Carousel.CarouselBase.ListItem {
    
    init(
        data: DecodableLanding.Data.CarouselBaseDecodable.ListItem
    ) {
        self.init(
            imageLink: data.imageLink,
            link: data.link,
            action: data.action.map { .init(data: $0)})
    }
}

private extension Landing.DataView.Carousel.CarouselBase.ListItem.Action {
    
    init(
        data: DecodableLanding.Data.CarouselBaseDecodable.ListItem.Action
    ) {
        self.init(type: data.type, target: data.target)
    }
}

private extension Landing.DataView.Carousel.CarouselWithTabs {
    
    init(
        data: DecodableLanding.Data.CarouselWithTabsDecodable
    ) {
        self.init(
            title: data.title,
            size: .init(size: data.size),
            scale: data.scale,
            loopedScrolling: data.loopedScrolling,
            tabs: data.tabs.map { .init(data: $0) })
    }
}

private extension Landing.DataView.Carousel.CarouselWithTabs.TabItem {
    
    init(
        data: DecodableLanding.Data.CarouselWithTabsDecodable.TabItem
    ) {
        self.init(
            name: data.name,
            list: data.list.map { .init(data: $0) } )
    }
}

private extension Landing.DataView.Carousel.CarouselWithTabs.ListItem {
    
    init(
        data: DecodableLanding.Data.CarouselWithTabsDecodable.ListItem
    ) {
        self.init(
            imageLink: data.imageLink,
            link: data.link,
            action: data.action.map { .init(data: $0)})
    }
}

private extension Landing.DataView.Carousel.CarouselWithTabs.ListItem.Action {
    
    init(
        data: DecodableLanding.Data.CarouselWithTabsDecodable.ListItem.Action
    ) {
        self.init(type: data.type, target: data.target)
    }
}

private extension Landing.DataView.Carousel.CarouselWithDots {
    
    init(
        data: DecodableLanding.Data.CarouselWithDotsDecodable
    ) {
        self.init(
            title: data.title,
            size: .init(size: data.size),
            scale: data.scale,
            loopedScrolling: data.loopedScrolling,
            list: data.list.map { .init(data: $0) })
    }
}

private extension Landing.DataView.Carousel.CarouselWithDots.ListItem {
    
    init(
        data: DecodableLanding.Data.CarouselWithDotsDecodable.ListItem
    ) {
        self.init(
            imageLink: data.imageLink,
            link: data.link,
            action: data.action.map { .init(data: $0)})
    }
}

private extension Landing.DataView.Carousel.CarouselWithDots.ListItem.Action {
    
    init(
        data: DecodableLanding.Data.CarouselWithDotsDecodable.ListItem.Action
    ) {
        self.init(type: data.type, target: data.target)
    }
}
