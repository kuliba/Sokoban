//
//  LandingToUILanding.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 12.09.2023.
//

import Foundation
import CodableLanding
import LandingMapping
import LandingUIComponent

extension UILanding {
    
    init(_ landing: Landing) {
        
        let header: [Component] = landing.header.compactMap(Component.init(data:))
        let main: [Component] = landing.main.compactMap(Component.init(data:))
        let footer: [Component] = landing.footer.compactMap(Component.init(data:))
        let details: [Detail] = landing.details.compactMap(Detail.init(data:))
        
        self.init(header: header, main: main, footer: footer, details: details)
    }
}

private extension UILanding.IconWithTwoTextLines {
    
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

private extension UILanding.Component {
    
    init?(
        data: Landing.DataView
    ) {
        switch data {
            
        case let .iconWithTwoTextLines(data):
            self = .iconWithTwoTextLines(.init(data: data))
            
        case let .list(.horizontalRectangleImage(data)):
            self = .list(.horizontalRectangleImage(.init(data: data)))
            
        case let .list(.horizontalRectangleLimits(data)):
            self = .list(.horizontalRectangleLimits(.init(list: .init(data: data), limitsLoadingStatus: .inflight(.loadingSVCardLimits))))
            
        case let .list(.horizontalRoundImage(data)):
            self = .list(.horizontalRoundImage(.init(data: data)))
            
        case let .list(.verticalRoundImage(data)):
            self = .list(.verticalRoundImage(.init(data: data)))
            
        case let .multi(.lineHeader(data)):
            self = .multi(.lineHeader(.init(data: data)))
            
        case let .multi(.markersText(data)):
            self = .multi(.markersText(.init(data: data)))
            
        case let .multi(.text(data)):
            self = .multi(.texts(.init(data: data)))
            
        case let .multi(.textsWithIconsHorizontalArray(data)):
            self = .multi(.textsWithIconsHorizontal(.init(data: data)))
            
        case let .pageTitle(data):
            self = .pageTitle(.init(data: data))
            
        case let .textsWithIconHorizontal(data):
            self = .textWithIconHorizontal(.init(data: data))
            
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

private extension UILanding.VerticalSpacing {
    
    init(
        data: Landing.VerticalSpacing
    ) {
        self.init(
            backgroundColor: .init(rawValue: data.backgroundColor.rawValue) ?? .black,
            spacingType: .init(rawValue: data.type.rawValue) ?? .small
        )
    }
}

private extension UILanding.Spacing {
    
    init(
        data: Landing.Spacing
    ) {
        self.init(
            backgroundColor: .init(rawValue: data.backgroundColor) ?? .black,
            heightDp: data.heightDp
        )
    }
}

private extension UILanding.List.DropDownTexts {
    
    init(
        data: Landing.DataView.List.DropDownTexts
    ) {
        self.init(
            title: data.title.map{.init($0.rawValue)},
            list: data.list.compactMap { .init(data: $0) }
        )
    }
}

private extension UILanding.List.DropDownTexts.Item {
    
    init(
        data: Landing.DataView.List.DropDownTexts.Item
    ) {
        self.init(
            title: data.title,
            description: data.description
        )
    }
}

private extension UILanding.ImageSvg {
    
    init(
        data: Landing.ImageSvg
    ) {
        self.init(
            backgroundColor: .init(rawValue: data.backgroundColor.rawValue),
            md5hash: .init(rawValue: data.md5hash.rawValue)
        )
    }
}

private extension UILanding.Multi.Texts {
    
    init(
        data: Landing.DataView.Multi.Text
    ) {
        self.init(
            texts: data.text.map { .init($0.rawValue) }
        )
    }
}

private extension UILanding.Multi.TextsWithIconsHorizontal {
    
    init(
        data: Landing.DataView.Multi.TextsWithIconsHorizontal
    ) {
        self.init(
            lists: data.list.map {
                .init(md5hash: $0.md5hash, title: $0.title)
            }
        )
    }
}

private extension UILanding.TextsWithIconHorizontal {
    
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

private extension UILanding.ImageBlock {
    
    init(
        data: Landing.ImageBlock
    ) {
        self.init(
            placeholder: .init(rawValue: data.withPlaceholder.rawValue),
            backgroundColor: .init(rawValue: data.backgroundColor.rawValue),
            link: .init(rawValue: data.link.rawValue)
        )
    }
}

private extension UILanding.Multi.TypeButtons {
    
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
            action: data.action.map {.init(data: $0) },
            detail: data.detail.map {.init(data: $0) }
        )
    }
}

private extension UILanding.Multi.TypeButtons.Action {
    
    init(
        data: Landing.DataView.Multi.TypeButtons.Action
    ) {
        self.init(
            type: data.type,
            outputData: data.outputData.map { .init(data: $0) }
        )
    }
}

private extension UILanding.Multi.TypeButtons.Action.OutputData {
    
    init(
        data: Landing.DataView.Multi.TypeButtons.Action.OutputData
    ) {
        self.init(
            tarif: .init(rawValue: data.tarif.rawValue),
            type: .init(rawValue: data.type.rawValue))
    }
}

private extension UILanding.Multi.TypeButtons.Detail {
    
    init(
        data: Landing.DataView.Multi.TypeButtons.Detail
    ) {
        self.init(
            groupId: .init(rawValue: data.groupId.rawValue),
            viewId: .init(rawValue: data.viewId.rawValue)
        )
    }
}
private extension UILanding.Multi.Buttons {
    
    init(
        data: Landing.DataView.Multi.Buttons
    ) {
        
        self.init(
            list: data.list.map(UILanding.Multi.Buttons.Item.init(data:))
        )
    }
}

private extension UILanding.Multi.Buttons.Item {
    
    init(
        data: Landing.DataView.Multi.Buttons.Item
    ) {
        
        let detail = data.detail.map(UILanding.Multi.Buttons.Item.Detail.init(data:))
        
        let action = data.action.map(UILanding.Multi.Buttons.Item.Action.init(data:))
        
        self.init(
            text: data.text,
            style: data.style,
            detail: detail,
            link: data.link,
            action: action
        )
    }
}

private extension UILanding.Multi.Buttons.Item.Detail {
    
    init(
        data: Landing.DataView.Multi.Buttons.Item.Detail
    ) {
        self.init(
            groupId: .init(rawValue: data.groupId.rawValue),
            viewId: .init(rawValue: data.viewId.rawValue)
        )
    }
}

private extension UILanding.Multi.Buttons.Item.Action {
    
    init(
        data: Landing.DataView.Multi.Buttons.Item.Action
    ) {
        self.init(
            type: .init(rawValue: data.type.rawValue)
        )
    }
}

private extension UILanding.Multi.MarkersText {
    
    init(
        data: Landing.DataView.Multi.MarkersText
    ) {
        self.init(
            backgroundColor: data.backgroundColor,
            style: data.style,
            list: data.list.map { .init($0.rawValue) }
        )
    }
}

private extension UILanding.List.VerticalRoundImage {
    
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

private extension UILanding.List.VerticalRoundImage.ListItem {
    
    init(
        data: Landing.DataView.List.VerticalRoundImage.ListItem
    ) {
       
        let action: UILanding.List.VerticalRoundImage.ListItem.Action?  = {
            
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
            detail: data.detail.map(UILanding.List.VerticalRoundImage.ListItem.Detail.init(data:)),
            action: action
        )
    }
}

private extension UILanding.List.VerticalRoundImage.ListItem.Detail {
    
    init(
        data: Landing.DataView.List.VerticalRoundImage.ListItem.Detail
    ) {
        self.init(
            groupId: .init(data.groupId.rawValue),
            viewId: .init(data.viewId.rawValue)
        )
    }
}

private extension UILanding.List.HorizontalRectangleImage {
    
    init(
        data: Landing.DataView.List.HorizontalRectangleImage
    ) {
        self.init(
            list: data.list.map { .init(data:$0) }
        )
    }
}

private extension UILanding.List.HorizontalRectangleImage.Item {
    
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

private extension UILanding.List.HorizontalRectangleImage.Item.Detail {
    
    init(
        data: Landing.DataView.List.HorizontalRectangleImage.Item.Detail
    ) {
        self.init(
            groupId: data.groupId,
            viewId: data.viewId)
    }
}

private extension UILanding.List.HorizontalRectangleLimits {
    
    init(
        data: Landing.DataView.List.HorizontalRectangleLimits
    ) {
        self.init(list: data.list.map { .init(data: $0) })
    }
}

private extension UILanding.List.HorizontalRectangleLimits.Item {
    
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

private extension UILanding.List.HorizontalRectangleLimits.Item.Limit {
    
    init(
        data: Landing.DataView.List.HorizontalRectangleLimits.Item.Limit
    ) {
        self.init(id: data.id, title: data.title, color: .init(hex: data.colorHEX))
    }
}

private extension UILanding.List.HorizontalRoundImage {
    
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

private extension UILanding.List.HorizontalRoundImage.ListItem {
    
    init(
        data: Landing.DataView.List.HorizontalRoundImage.ListItem
    ) {
        self.init(
            imageMd5Hash: data.md5hash,
            title: data.title,
            subInfo: data.subInfo,
            detail: data.detail.map(UILanding.List.HorizontalRoundImage.ListItem.Detail.init(data:)))
    }
}

private extension UILanding.List.HorizontalRoundImage.ListItem.Detail {
    
    init(
        data: Landing.DataView.List.HorizontalRoundImage.ListItem.Detail
    ) {
        self.init(
            groupId: data.groupId.rawValue,
            viewId: data.viewId.rawValue
        )
    }
}


private extension UILanding.Multi.LineHeader {
    
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

private extension UILanding.PageTitle {
    
    init(
        data: Landing.PageTitle
    ) {
        self.init(
            text: data.text,
            subTitle: data.subtitle,
            transparency: data.transparency
        )
    }
}

private extension UILanding.Detail {
    
    init(
        data: Landing.Detail
    ) {
        self.init(
            groupID: .init(rawValue: data.groupId),
            dataGroup: data.dataGroup.map { .init(data: $0) }
        )
    }
}

private extension UILanding.Detail.DataGroup {
    
    init(
        data: Landing.Detail.DataGroup
    ) {
        self.init(
            viewID: .init(rawValue: data.viewId),
            dataView: data.dataView.compactMap( UILanding.Component.init(data:))
        )
    }
}

private extension UILanding.BlockHorizontalRectangular {
    
    init(
        data: Landing.BlockHorizontalRectangular
    ) {
        self.init(list: data.list.map { .init(data:$0) })
    }
}

private extension UILanding.BlockHorizontalRectangular.Item {
    
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

private extension UILanding.BlockHorizontalRectangular.Item.Limit {
    
    init(
        data: Landing.BlockHorizontalRectangular.Item.Limit
    ) {
        self.init(id: data.id, title: data.title, md5hash: data.md5hash, text: data.text, maxSum: data.maxSum)
    }
}

private extension UILanding.Carousel.CarouselBase {
    
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

private extension UILanding.Carousel.CarouselBase.ListItem {
    
    init(
        data: Landing.DataView.Carousel.CarouselBase.ListItem
    ) {
        self.init(
            imageLink: data.imageLink,
            link: data.link,
            action: data.action.map { .init(data: $0)})
    }
}

private extension ItemAction {
    
    init(
        data: Landing.DataView.Carousel.CarouselBase.ListItem.Action
    ) {
        self.init(type: data.type, target: data.target)
    }
}

private extension UILanding.Carousel.CarouselWithTabs {
    
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

private extension UILanding.Carousel.CarouselWithTabs.TabItem {
    
    init(
        data: Landing.DataView.Carousel.CarouselWithTabs.TabItem
    ) {
        self.init(
            name: data.name,
            list: data.list.map { .init(data: $0) })
    }
}

private extension UILanding.Carousel.CarouselWithTabs.ListItem {
    
    init(
        data: Landing.DataView.Carousel.CarouselWithTabs.ListItem
    ) {
        self.init(
            imageLink: data.imageLink,
            link: data.link,
            action: data.action.map { .init(data: $0)})
    }
}

private extension ItemAction {
    
    init(
        data: Landing.DataView.Carousel.CarouselWithTabs.ListItem.Action
    ) {
        self.init(type: data.type, target: data.target)
    }
}

private extension UILanding.Carousel.CarouselWithDots {
    
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

private extension UILanding.Carousel.CarouselWithDots.ListItem {
    
    init(
        data: Landing.DataView.Carousel.CarouselWithDots.ListItem
    ) {
        self.init(
            imageLink: data.imageLink,
            link: data.link,
            action: data.action.map { .init(data: $0)})
    }
}

private extension ItemAction {
    
    init(
        data: Landing.DataView.Carousel.CarouselWithDots.ListItem.Action
    ) {
        self.init(type: data.type, target: data.target)
    }
}
