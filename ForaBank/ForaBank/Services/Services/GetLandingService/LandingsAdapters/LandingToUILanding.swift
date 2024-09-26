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
            
        case let .iconWithTwoTextLines(x):
            self = .iconWithTwoTextLines(.init(data: x))
            
        case let .list(.horizontalRectangleImage(x)):
            self = .list(.horizontalRectangleImage(.init(data: x)))
            
        case let .list(.horizontalRectangleLimits(x)):
            self = .list(.horizontalRectangleLimits(.init(list: .init(data: x), limitsLoadingStatus: .inflight(.loadingSVCardLimits))))
            
        case let .list(.horizontalRoundImage(x)):
            self = .list(.horizontalRoundImage(.init(data: x)))
            
        case let .list(.verticalRoundImage(x)):
            self = .list(.verticalRoundImage(.init(data: x)))
            
        case let .multi(.lineHeader(x)):
            self = .multi(.lineHeader(.init(data: x)))
            
        case let .multi(.markersText(x)):
            self = .multi(.markersText(.init(data: x)))
            
        case let .multi(.text(x)):
            self = .multi(.texts(.init(data: x)))
            
        case let .multi(.textsWithIconsHorizontalArray(x)):
            self = .multi(.textsWithIconsHorizontal(.init(data: x)))
            
        case let .pageTitle(x):
            self = .pageTitle(.init(data: x))
            
        case let .textsWithIconHorizontal(x):
            self = .textWithIconHorizontal(.init(data: x))
            
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
            
        case let .blockHorizontalRectangular(x):
            self = .blockHorizontalRectangular(.init(data: x))
            
        case let .carousel(.base(x)):
            self = .carousel(.base(.init(data: x)))
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
            size: data.size,
            scale: data.scale,
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

private extension UILanding.Carousel.CarouselBase.ListItem.Action {
    
    init(
        data: Landing.DataView.Carousel.CarouselBase.ListItem.Action
    ) {
        self.init(type: data.type, target: data.target)
    }
}
