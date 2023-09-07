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
        
        return try JSONDecoder().decode(DecodableLanding.self, from: data)
    }
    
    private static func decodeLandingToLanding(
        _ decodeLanding: DecodableLanding
    ) -> Landing {
        
        let serial: String = decodeLanding.data.serial
        let header: [Landing.DataView] = decodeLanding.data.header.compactMap(Landing.DataView.init(data:))
        let main: [Landing.DataView] = decodeLanding.data.main.compactMap(Landing.DataView.init(data:))
        let footer: [Landing.DataView] = decodeLanding.data.footer.compactMap (Landing.DataView.init(data:))
        let details: [Landing.Detail] = decodeLanding.data.details.compactMap (Landing.Detail.init(data:))
        
        let landing: Landing = .init(
            header: header,
            main: main,
            footer: footer,
            details: details,
            serial: serial
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
            
        case let .list(.listHorizontalRectangleImage(x)):
            self = .list(.horizontalRectangleImage(.init(data: x)))
            
        case let .list(.listHorizontalRoundImage(x)):
            self = .list(.horizontalRoundImage(.init(data: x)))
            
        case let .list(.listVerticalRoundImage(x)):
            self = .list(.verticalRoundImage(.init(data: x)))
            
        case let .multi(.multiLineHeader(x)):
            self = .multi(.lineHeader(.init(data: x)))
            
        case let .multi(.multiMarkersText(x)):
            self = .multi(.markersText(.init(data: x)))
            
        case let .multi(.multiText(x)):
            self = .multi(.text(.init(data: x)))
            
        case let .multi(.multiTextsWithIconsHorizontalArray(x)):
            self = .multi(.textsWithIconsHorizontalArray(.init(data: x)))
            
        case let .pageTitle(x):
            self = .pageTitle(.init(data: x))
            
        case let .textsWithIconHorizontal(x):
            self = .textsWithIconHorizontal(.init(data: x))
        }
    }
}

private extension Landing.MultiMarkersText {
    
    init(
        data: DecodableLanding.Data.MultiMarkersText
    ) {
        let list: [Landing.MultiMarkersText.Text?] = data.list.compactMap {
            
            if let text = $0 {
                
                return .init(text)
            }
            return nil
        }
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
            list: data.list.compactMap { $0.map { .init(data: $0) }}
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
            detail: .init(data: data.detail))
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
            $0.map { Landing.MultiText.Text.init($0) }
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
            data.detail.map {
                        .init(groupId: $0.groupId, viewId: $0.viewId)
                    }
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
        self.detail = .init(data: data.detail)
    }
}

private extension Landing.ListHorizontalRoundImage.ListItem.Detail {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRoundImage.ListItem.Detail
    ) {
        self.groupId = data.groupId
        self.viewId = data.viewId
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
        self.text = data.text
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
