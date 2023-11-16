//
//  LandingResponse.swift
//  
//
//  Created by Dmitry Martynov on 27.07.2023.
//

import LandingComponentsOld
    
public struct LandingDataResponse: Decodable, Equatable  {
    
    public let serial: String
    public let main: LandingDataMainResponse
    public let details: [LandingDataDetailResponse]?
}

public struct LandingDataMainResponse: Decodable, Equatable {
    
    public let components: [LandingComponentsTypeWithModel]
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.unkeyedContainer()
        self.components = try LandingDataResponse.decodeComponents(container: container)
    }
}

public struct LandingDataDetailResponse: Decodable, Equatable {
    
    public let detailsGroupId: String
    public let dataGroup: [LandingDataDelailGroupItem]
}

public struct LandingDataDelailGroupItem: Decodable, Equatable {
    
    public let detailViewId: String
    public let components: [LandingComponentsTypeWithModel]
    
    enum CodingKeys : String, CodingKey {
        
        case detailViewId
        case components = "dataView"
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let componentsContainer = try values.nestedUnkeyedContainer(forKey: .components)
        
        self.detailViewId = try values.decode(String.self, forKey: .detailViewId)
        self.components = try LandingDataResponse.decodeComponents(container: componentsContainer)
    }
}
 
public struct LandingDataMainComponentTypeResponse: Decodable {
    
    public let type: LandingComponentsType
    
    enum CodingKeys : String, CodingKey {
        
        case type
    }
}

extension LandingDataResponse {
    
    static func decodeComponents(container: UnkeyedDecodingContainer) throws -> [LandingComponentsTypeWithModel] {
        
        var typesContainer = container
        var valuesContainer = container
        
        var componentsType = [LandingComponentsTypeWithModel]()
        
        while !typesContainer.isAtEnd {
            
            guard let type = try? typesContainer.decode(LandingDataMainComponentTypeResponse.self).type
            else {
                let _ = try valuesContainer.decode(LandingDataMainComponentTypeResponse.self)
                continue
            }
            
            switch type {
            case .multiLineHeader:
                let data = try valuesContainer.decode(MultiLineHeaderModel.self)
                componentsType.append(.multiLineHeader(data))
                
            case .listHorizontalRoundImage:
                let data = try valuesContainer.decode(ListHorizontalRoundImageModel.self)
                componentsType.append(.listHorizontalRoundImage(data))
                
            case .iconWithTwoTextLines:
                let data = try valuesContainer.decode(IconWithTwoTextLinesModel.self)
                componentsType.append(.iconWithTwoTextLines(data))
                
            case .verticalSpacing:
                let data = try valuesContainer.decode(VerticalSpacingModel.self)
                componentsType.append(.verticalSpacing(data))
            
            case .textWithIconHorizontal:
                let data = try valuesContainer.decode(TextWithIconHorizontalModel.self)
                componentsType.append(.textWithIconHorizontal(data))
            
            case .listHorizontalRectangleImage:
                let data = try valuesContainer.decode(ListHorizontalRectangleImageModel.self)
                componentsType.append(.listHorizontalRectangleImage(data))
            
            case .listVerticalRoundImage:
                let data = try valuesContainer.decode(ListVerticalRoundImageModel.self)
                componentsType.append(.listVerticalRoundImage(data))
            
            case .multiButtons:
                let data = try valuesContainer.decode(MultiButtonsModel.self)
                componentsType.append(.multiButtons(data))
           
            case .listDropDownTexts:
                let data = try valuesContainer.decode(ListDropDownTextsModel.self)
                componentsType.append(.listDropDownTexts(data))
            
            case .multiText:
                let data = try valuesContainer.decode(MultiTextModel.self)
                componentsType.append(.multiText(data))
            
            case .pageTitle:
                let data = try valuesContainer.decode(PageTitleModel.self)
                componentsType.append(.pageTitle(data))
            
            case .image:
                let data = try valuesContainer.decode(ImageModel.self)
                componentsType.append(.image(data))
           
            case .multiMarkersText: //TODO: 
                continue
            
            case .multiTextsWithIconsHorizontal: //TODO: 
                continue
            }
        }
        return componentsType
    }
}

