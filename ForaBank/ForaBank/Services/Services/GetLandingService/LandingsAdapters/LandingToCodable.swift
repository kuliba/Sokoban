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

private extension CodableLanding.VerticalSpacing {
    
    init(
        data: Landing.VerticalSpacing
    ) {
        self.init(
            backgroundColor: .init(data.backgroundColor.rawValue),
            type: .init(data.type.rawValue))
    }
}

private extension CodableLanding.ListDropDownTexts {
    
    init(
        data: Landing.ListDropDownTexts
    ) {
        self.init(
            title: data.title.map { .init($0.rawValue) },
            list: data.list.compactMap { .init(data:$0) }
        )
    }
}

private extension CodableLanding.ListDropDownTexts.Item {
    
    init(
        data: Landing.ListDropDownTexts.Item
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

private extension CodableLanding.MultiTypeButtons {
    
    init(
        data: Landing.MultiTypeButtons
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

private extension CodableLanding.MultiTypeButtons.Action {
    
    init(
        data: Landing.MultiTypeButtons.Action
    ) {
        self.init(
            type: data.type,
            outputData: data.outputData.map { .init(data: $0) }
        )
    }
}

private extension CodableLanding.MultiTypeButtons.Action.OutputData {
    
    init(
        data: Landing.MultiTypeButtons.Action.OutputData
    ) {
        self.init(
            tarif: .init(rawValue: data.tarif.rawValue),
            type: .init(rawValue: data.type.rawValue)
        )
    }
}

#warning("не покрыт тестами - используется или можно удалить?")
private extension CodableLanding.MultiTypeButtons.Detail {
    
    init(
        data: Landing.MultiTypeButtons.Detail
    ) {
        self.init(
            groupId: .init(rawValue: data.groupId.rawValue),
            viewId: .init(rawValue: data.viewId.rawValue)
        )
    }
}
private extension CodableLanding.MultiButtons {
    
    init(
        data: Landing.MultiButtons
    ) {
        self.init(
            list: data.list.map(CodableLanding.MultiButtons.Item.init(data:))
        )
    }
}

private extension CodableLanding.MultiButtons.Item {
    
    init(
        data: Landing.MultiButtons.Item
    ) {
        
        let detail = data.detail.map(CodableLanding.MultiButtons.Item.Detail.init(data:))
        
        let action = data.action.map(CodableLanding.MultiButtons.Item.Action.init(data:))
        
        self.init(
            text: data.text,
            style: data.style,
            detail: detail,
            link: data.link,
            action: action
        )
    }
}

private extension CodableLanding.MultiButtons.Item.Detail {
    
    init(
        data: Landing.MultiButtons.Item.Detail
    ) {
        self.init(
            groupId: .init(rawValue: data.groupId.rawValue),
            viewId: .init(rawValue: data.viewId.rawValue)
        )
    }
}

private extension CodableLanding.MultiButtons.Item.Action {
    
    init(
        data: Landing.MultiButtons.Item.Action
    ) {
        self.init(type: .init(rawValue: data.type.rawValue))
    }
}

private extension CodableLanding.MultiMarkersText {
    
    init(
        data: Landing.MultiMarkersText
    ) {
        self.init(
            backgroundColor: data.backgroundColor,
            style: data.style,
            list: data.list.compactMap { .init($0.rawValue) }
        )
    }
}

private extension CodableLanding.ListVerticalRoundImage {
    
    init(
        data: Landing.ListVerticalRoundImage
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

private extension CodableLanding.ListVerticalRoundImage.ListItem {
    
    init(
        data: Landing.ListVerticalRoundImage.ListItem
    ) {
        
        self.init(
            md5hash: data.md5hash,
            title: data.title,
            subInfo: data.subInfo,
            link: data.link,
            appStore: data.appStore,
            googlePlay: data.googlePlay,
            detail: data.detail.map(CodableLanding.ListVerticalRoundImage.ListItem.Detail.init(data:))
        )
    }
}

private extension CodableLanding.ListVerticalRoundImage.ListItem.Detail {
    
    init(
        data: Landing.ListVerticalRoundImage.ListItem.Detail
    ) {
        self.init(
            groupId: .init(data.groupId.rawValue),
            viewId: .init(data.viewId.rawValue)
        )
    }
}

private extension CodableLanding.MultiText {
    
    init(
        data: Landing.MultiText
    ) {
        self.init(
            text: data.text.compactMap { .init($0.rawValue) }
        )
    }
}

private extension CodableLanding.ListHorizontalRectangleImage {
    
    init(
        data: Landing.ListHorizontalRectangleImage
    ) {
        self.init(
            list: data.list.map { .init(data:$0) }
        )
    }
}

private extension CodableLanding.ListHorizontalRectangleImage.Item {
    
    init(
        data: Landing.ListHorizontalRectangleImage.Item
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

#warning("не покрыт тестами - используется или можно удалить?")
private extension CodableLanding.ListHorizontalRectangleImage.Item.Detail {
    
    init(
        data: Landing.ListHorizontalRectangleImage.Item.Detail
    ) {
        self.init(
            groupId: data.groupId,
            viewId: data.viewId
        )
    }
}

private extension CodableLanding.ListHorizontalRoundImage {
    
    init(
        data: Landing.ListHorizontalRoundImage
    ) {
        self.init(
            title: data.title,
            list: (data.list ?? []).map {
                
                .init(data:$0)
            }
        )
    }
}

private extension CodableLanding.ListHorizontalRoundImage.ListItem {
    
    init(
        data: Landing.ListHorizontalRoundImage.ListItem
    ) {
        self.init(
            md5hash: data.md5hash,
            title: data.title,
            subInfo: data.subInfo,
            details: data.detail.map(CodableLanding.ListHorizontalRoundImage.ListItem.Detail.init(data:))
        )
    }
}

private extension CodableLanding.ListHorizontalRoundImage.ListItem.Detail {
    
    init(
        data: Landing.ListHorizontalRoundImage.ListItem.Detail
    ) {
        self.init(
            groupId: .init(rawValue: data.groupId.rawValue),
            viewId: .init(rawValue: data.viewId.rawValue)
        )
    }
}

private extension CodableLanding.MuiltiTextsWithIconsHorizontal {
    
    init(
        data: Landing.MuiltiTextsWithIconsHorizontal
    ) {
        self.init(
            list: data.list.map {
                
                .init(md5hash: $0.md5hash, title: $0.title)
            }
        )
    }
}

private extension CodableLanding.MultiLineHeader {
    
    init(
        data: Landing.MultiLineHeader
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
