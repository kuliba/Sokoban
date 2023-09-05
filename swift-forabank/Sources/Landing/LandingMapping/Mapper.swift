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
        let header: [Landing.DataView] = decodeLanding.data.header.map { Landing.DataView.init(data: $0)}
        let main: [Landing.DataView] = decodeLanding.data.main.map { Landing.DataView.init(data: $0)}
        let footer: [Landing.DataView?] = decodeLanding.data.footer.map { Landing.DataView.init(data: $0)}
        let details: [Landing.Detail] = decodeLanding.data.details.map { Landing.Detail.init(data: $0) }
        
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
    
    init(
        data: DecodableLanding.Data.DataView
    ) {
        
        switch data {
            
        case let .iconWithTwoTextLines(x):
            self = .iconWithTwoTextLines(.init(data: x))
            
        case let .listHorizontalRoundImage(x):
            self = .listHorizontalRoundImage(.init(data: x))
            
        case let .multiLineHeader(x):
            self = .multiLineHeader(.init(data: x))
            
        case .empty:
            self = .empty
            
        case let .multiTextsWithIconsHorizontalArray(x):
            self = .multiTextsWithIconsHorizontalArray(.init(data: x))
            
        case let .textsWithIconHorizontal(x):
            self = .textsWithIconHorizontal(.init(data: x))
            
        case let .pageTitle(x):
            self = .pageTitle(.init(data: x))
            
        case let .listHorizontalRectangleImage(x):
            self = .listHorizontalRectangleImage(.init(data: x))
        }
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
                    groupId: details.detailsGroupId,
                    viewId: details.detailViewId)
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
            groupId: data.detailsGroupId,
            viewId: data.detailViewId)
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
        self.details = .init(data: data.details)
    }
}

private extension Landing.ListHorizontalRoundImage.ListItem.Details {
    
    init(
        data: DecodableLanding.Data.ListHorizontalRoundImage.Details
    ) {
        self.detailsGroupId = data.detailsGroupId
        self.detailViewId = data.detailViewId
    }
}

private extension Landing.MuiltiTextsWithIconsHorizontal {
    
    init(
        data: [DecodableLanding.Data.MuiltiTextsWithIconsHorizontal]
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
        self.groupId = data.detailsGroupId
        self.dataGroup = data.dataGroup.map{ Landing.Detail.DataGroup(data: $0) }
    }
}

private extension Landing.Detail.DataGroup {
    
    init(
        data: DecodableLanding.Data.Detail.DataGroup
    ) {
        self.viewId = data.detailViewId
        self.dataView = data.dataView.map{ Landing.DataView.init(data: $0) }
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
