//
//  LandingToCodable.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 13.09.2023.
//

import CodableLanding
import LandingMapping

extension CodableLanding {
    
    init(_ landing: Landing) {
        
        let header: [DataView] = landing.header.compactMap(DataView.init(data:))
        let main: [DataView] = landing.main.compactMap( DataView.init(data:))
        let footer: [DataView] = landing.footer.compactMap(DataView.init(data:))
        let details: [Detail] = landing.details.compactMap(Detail.init(data:))
        
        self.init(header: header, main: main, footer: footer, details: details, serial: landing.serial)
    }
}

private extension CodableLanding.IconWithTwoTextLines {
    
    init(
        data: Landing.IconWithTwoTextLines
    ) {
        self.init(
            md5hash: data.md5hash,
            title: data.title,
            subTitle: data.subTitle
        )
    }
}

private extension CodableLanding.DataView {
    
    init?(
        data: Landing.DataView
    ) {
        switch data {
            
        case let .iconWithTwoTextLines(data):
            self = .iconWithTwoTextLines(.init(data: data))
            
        case let .list(.horizontalRectangleImage(data)):
            self = .list(.horizontalRectangleImage(.init(data: data)))
        
        case let .list(.horizontalRectangleLimits(data)):
            self = .list(.horizontalRectangleLimits(.init(data: data)))

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

        case let .blockHorizontalRectangular(data):
            self = .blockHorizontalRectangular(.init(data: data))
            
        case let .carousel(.base(data)):
            self = .carousel(.base(.init(data: data)))
        case let .carousel(.withTabs(data)):
            self = .carousel(.withTabs(.init(data: data)))
        case let .carousel(.withDots(data)):
            self = .carousel(.withDots(.init(data: data)))
        }
    }
}

private extension CodableLanding.VerticalSpacing {
    
    init(
        data: Landing.VerticalSpacing
    ) {
        self.init(
            backgroundColor: .init(data.backgroundColor.rawValue),
            type: .init(data.type.rawValue))
    }
}

private extension CodableLanding.Spacing {
    
    init(
        data: Landing.Spacing
    ) {
        self.init(
            backgroundColor: data.backgroundColor,
            heightDp: data.heightDp)
    }
}

private extension CodableLanding.List.DropDownTexts {
    
    init(
        data: Landing.DataView.List.DropDownTexts
    ) {
        self.init(
            title: data.title.map { .init($0.rawValue) },
            list: data.list.compactMap { .init(data:$0) }
        )
    }
}

private extension CodableLanding.List.DropDownTexts.Item {
    
    init(
        data: Landing.DataView.List.DropDownTexts.Item
    ) {
        self.init(
            title: data.title,
            description: data.description
        )
    }
}

private extension CodableLanding.ImageSvg {
    
    init(
        data: Landing.ImageSvg
    ) {
        self.init(
            backgroundColor: .init(rawValue: data.backgroundColor.rawValue),
            md5hash: .init(rawValue: data.md5hash.rawValue)
        )
    }
}

private extension CodableLanding.ImageBlock {
    
    init(
        data: Landing.ImageBlock
    ) {
        self.init(
            withPlaceholder: .init(rawValue: data.withPlaceholder.rawValue),
            backgroundColor: .init(rawValue: data.backgroundColor.rawValue),
            link: .init(rawValue: data.link.rawValue)
        )
    }
}

private extension CodableLanding.Multi.TypeButtons {
    
    init(
        data: Landing.DataView.Multi.TypeButtons
    ) {
        self.init(
            md5hash: data.md5hash,
            backgroundColor: data.backgroundColor,
            text: data.text,
            buttonText: data.buttonText,
            buttonStyle: data.buttonStyle,
            textLink: data.textLink,
            action: data.action.map { .init(data: $0) },
            detail: data.detail.map { .init(data: $0) }
        )
    }
}

private extension CodableLanding.Multi.TypeButtons.Action {
    
    init(
        data: Landing.DataView.Multi.TypeButtons.Action
    ) {
        self.init(
            type: data.type,
            outputData: data.outputData.map { .init(data: $0) }
        )
    }
}

private extension CodableLanding.Multi.TypeButtons.Action.OutputData {
    
    init(
        data: Landing.DataView.Multi.TypeButtons.Action.OutputData
    ) {
        self.init(
            tarif: .init(rawValue: data.tarif.rawValue),
            type: .init(rawValue: data.type.rawValue)
        )
    }
}

#warning("не покрыт тестами - используется или можно удалить?")
private extension CodableLanding.Multi.TypeButtons.Detail {
    
    init(
        data: Landing.DataView.Multi.TypeButtons.Detail
    ) {
        self.init(
            groupId: .init(rawValue: data.groupId.rawValue),
            viewId: .init(rawValue: data.viewId.rawValue)
        )
    }
}
private extension CodableLanding.Multi.Buttons {
    
    init(
        data: Landing.DataView.Multi.Buttons
    ) {
        self.init(
            list: data.list.map(CodableLanding.Multi.Buttons.Item.init(data:))
        )
    }
}

private extension CodableLanding.Multi.Buttons.Item {
    
    init(
        data: Landing.DataView.Multi.Buttons.Item
    ) {
        
        let detail = data.detail.map(CodableLanding.Multi.Buttons.Item.Detail.init(data:))
        
        let action = data.action.map(CodableLanding.Multi.Buttons.Item.Action.init(data:))
        
        self.init(
            text: data.text,
            style: data.style,
            detail: detail,
            link: data.link,
            action: action
        )
    }
}

private extension CodableLanding.Multi.Buttons.Item.Detail {
    
    init(
        data: Landing.DataView.Multi.Buttons.Item.Detail
    ) {
        self.init(
            groupId: .init(rawValue: data.groupId.rawValue),
            viewId: .init(rawValue: data.viewId.rawValue)
        )
    }
}

private extension CodableLanding.Multi.Buttons.Item.Action {
    
    init(
        data: Landing.DataView.Multi.Buttons.Item.Action
    ) {
        self.init(type: .init(rawValue: data.type.rawValue))
    }
}

private extension CodableLanding.Multi.MarkersText {
    
    init(
        data: Landing.DataView.Multi.MarkersText
    ) {
        self.init(
            backgroundColor: data.backgroundColor,
            style: data.style,
            list: data.list.compactMap { .init($0.rawValue) }
        )
    }
}

private extension CodableLanding.List.VerticalRoundImage {
    
    init(
        data: Landing.DataView.List.VerticalRoundImage
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

private extension CodableLanding.List.VerticalRoundImage.ListItem {
    
    init(
        data: Landing.DataView.List.VerticalRoundImage.ListItem
    ) {
        
        let action: CodableLanding.List.VerticalRoundImage.ListItem.Action?  = {
            
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
            detail: data.detail.map(CodableLanding.List.VerticalRoundImage.ListItem.Detail.init(data:)),
            action: action
        )
    }
}

private extension CodableLanding.List.VerticalRoundImage.ListItem.Detail {
    
    init(
        data: Landing.DataView.List.VerticalRoundImage.ListItem.Detail
    ) {
        self.init(
            groupId: .init(data.groupId.rawValue),
            viewId: .init(data.viewId.rawValue)
        )
    }
}

private extension CodableLanding.Multi.Text {
    
    init(
        data: Landing.DataView.Multi.Text
    ) {
        self.init(
            text: data.text.compactMap { .init($0.rawValue) }
        )
    }
}

private extension CodableLanding.List.HorizontalRectangleImage {
    
    init(
        data: Landing.DataView.List.HorizontalRectangleImage
    ) {
        self.init(
            list: data.list.map { .init(data:$0) }
        )
    }
}

private extension CodableLanding.List.HorizontalRectangleImage.Item {
    
    init(
        data: Landing.DataView.List.HorizontalRectangleImage.Item
    ) {
        self.init(
            imageLink: data.imageLink,
            link: data.link,
            detail: data.detail.map {
                
                .init(
                    groupId: $0.groupId,
                    viewId: $0.viewId)
            }
        )
    }
}

private extension CodableLanding.List.HorizontalRectangleLimits {
    
    init(
        data: Landing.DataView.List.HorizontalRectangleLimits
    ) {
        self.init(list: data.list.map { .init(data: $0) })
    }
}

private extension CodableLanding.List.HorizontalRectangleLimits.Item {
    
    init(
        data: Landing.DataView.List.HorizontalRectangleLimits.Item
    ) {
        self.init(
            action: .init(type: data.action.type),
            limitType: data.limitType,
            md5hash: data.md5hash,
            title: data.title,
            limits: data.limits.map { .init(data:$0) })
    }
}

private extension CodableLanding.List.HorizontalRectangleLimits.Item.Limit {
    
    init(
        data: Landing.DataView.List.HorizontalRectangleLimits.Item.Limit
    ) {
        self.init(id: data.id, title: data.title, colorHEX: data.colorHEX)
    }
}

private extension CodableLanding.List.HorizontalRoundImage {
    
    init(
        data: Landing.DataView.List.HorizontalRoundImage
    ) {
        self.init(
            title: data.title,
            list: (data.list ?? []).map {
                
                .init(data:$0)
            }
        )
    }
}

private extension CodableLanding.List.HorizontalRoundImage.ListItem {
    
    init(
        data: Landing.DataView.List.HorizontalRoundImage.ListItem
    ) {
        self.init(
            md5hash: data.md5hash,
            title: data.title,
            subInfo: data.subInfo,
            details: data.detail.map(CodableLanding.List.HorizontalRoundImage.ListItem.Detail.init(data:))
        )
    }
}

private extension CodableLanding.List.HorizontalRoundImage.ListItem.Detail {
    
    init(
        data: Landing.DataView.List.HorizontalRoundImage.ListItem.Detail
    ) {
        self.init(
            groupId: .init(rawValue: data.groupId.rawValue),
            viewId: .init(rawValue: data.viewId.rawValue)
        )
    }
}

private extension CodableLanding.Multi.TextsWithIconsHorizontal {
    
    init(
        data: Landing.DataView.Multi.TextsWithIconsHorizontal
    ) {
        self.init(
            list: data.list.map {
                
                .init(md5hash: $0.md5hash, title: $0.title)
            }
        )
    }
}

private extension CodableLanding.Multi.LineHeader {
    
    init(
        data: Landing.DataView.Multi.LineHeader
    ) {
        self.init(
            backgroundColor: data.backgroundColor,
            regularTextList: data.regularTextList,
            boldTextList: data.boldTextList
        )
    }
}

private extension CodableLanding.PageTitle {
    
    init(
        data: Landing.PageTitle
    ) {
        self.init(
            text: data.text,
            subtitle: data.subtitle,
            transparency: data.transparency
        )
    }
}

private extension CodableLanding.Detail {
    
    init(
        data: Landing.Detail
    ) {
        self.init(
            groupId: data.groupId,
            dataGroup: data.dataGroup.map { .init(data: $0) }
        )
    }
}

private extension CodableLanding.Detail.DataGroup {
    
    init(
        data: Landing.Detail.DataGroup
    ) {
        self.init(
            viewId: data.viewId,
            dataView: data.dataView.compactMap(
                CodableLanding.DataView.init(data:)
            )
        )
    }
}

private extension CodableLanding.TextsWithIconHorizontal {
    
    init(
        data: Landing.TextsWithIconHorizontal
    ) {
        
        self.init(
            md5hash: data.md5hash,
            title: data.title,
            contentCenterAndPull: data.contentCenterAndPull
        )
    }
}

private extension CodableLanding.BlockHorizontalRectangular {
    
    init(
        data: Landing.BlockHorizontalRectangular
    ) {
        self.init(list: data.list.map { .init(data:$0) })
    }
}

private extension CodableLanding.BlockHorizontalRectangular.Item {
    
    init(
        data: Landing.BlockHorizontalRectangular.Item
    ) {
        self.init(
            limitType: data.limitType,
            description: data.description,
            title: data.title,
            limits: data.limits.map { .init(data: $0) })
    }
}

private extension CodableLanding.BlockHorizontalRectangular.Item.Limit {
    
    init(
        data: Landing.BlockHorizontalRectangular.Item.Limit
    ) {
        self.init(id: data.id, title: data.title, md5hash: data.md5hash, text: data.text, maxSum: data.maxSum)
    }
}

private extension CodableLanding.CodableCarouselBase {
    
    init(
        data: Landing.DataView.Carousel.CarouselBase
    ) {
        self.init(
            title: data.title,
            size: .init(width: data.size.width, height: data.size.height),
            loopedScrolling: data.loopedScrolling,
            list: data.list.map { .init(data: $0) })
    }
}

private extension CodableLanding.CodableCarouselBase.ListItem {
    
    init(
        data: Landing.DataView.Carousel.CarouselBase.ListItem
    ) {
        self.init(
            imageLink: data.imageLink,
            link: data.link,
            action: data.action.map { .init(data: $0)})
    }
}

private extension CodableLanding.CodableCarouselBase.ListItem.Action {
    
    init(
        data: Landing.DataView.Carousel.CarouselBase.ListItem.Action
    ) {
        self.init(type: data.type, target: data.target)
    }
}

private extension CodableLanding.CodableCarouselWithTabs {
    
    init(
        data: Landing.DataView.Carousel.CarouselWithTabs
    ) {
        self.init(
            title: data.title,
            size: .init(width: data.size.width, height: data.size.height),
            scale: data.scale,
            loopedScrolling: data.loopedScrolling,
            tabs: data.tabs.map { .init(data: $0) })
    }
}

private extension CodableLanding.CodableCarouselWithTabs.TabItem {
    
    init(
        data: Landing.DataView.Carousel.CarouselWithTabs.TabItem
    ) {
        self.init(
            name: data.name,
            list: data.list.map { .init(data: $0) })
    }
}

private extension CodableLanding.CodableCarouselWithTabs.ListItem {
    
    init(
        data: Landing.DataView.Carousel.CarouselWithTabs.ListItem
    ) {
        self.init(
            imageLink: data.imageLink,
            link: data.link,
            action: data.action.map { .init(data: $0)})
    }
}

private extension CodableLanding.CodableCarouselWithTabs.ListItem.Action {
    
    init(
        data: Landing.DataView.Carousel.CarouselWithTabs.ListItem.Action
    ) {
        self.init(type: data.type, target: data.target)
    }
}

private extension CodableLanding.CodableCarouselWithDots {
    
    init(
        data: Landing.DataView.Carousel.CarouselWithDots
    ) {
        self.init(
            title: data.title,
            size: .init(width: data.size.width, height: data.size.height),
            loopedScrolling: data.loopedScrolling,
            list: data.list.map { .init(data: $0) })
    }
}

private extension CodableLanding.CodableCarouselWithDots.ListItem {
    
    init(
        data: Landing.DataView.Carousel.CarouselWithDots.ListItem
    ) {
        self.init(
            imageLink: data.imageLink,
            link: data.link,
            action: data.action.map { .init(data: $0)})
    }
}

private extension CodableLanding.CodableCarouselWithDots.ListItem.Action {
    
    init(
        data: Landing.DataView.Carousel.CarouselWithDots.ListItem.Action
    ) {
        self.init(type: data.type, target: data.target)
    }
}
