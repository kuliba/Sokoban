//
//  MosParkingDataMapper.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.06.2023.
//

import PickerWithPreviewComponent

enum MosParkingDataMapper {
    
    static func map(
        data: [MosParkingData]
    ) throws -> (
        state: PickerWithPreviewComponent.ComponentState,
        options: [SubscriptionType: [OptionWithMapImage]],
        refillID: String
    ) {
        guard !data.isEmpty else {
            throw Error.emptyData
        }
        
        let refill = "Пополнение"
        
        guard let refillID = data.first(where: { $0.groupName == refill })?.value
        else {
            throw Error.missingRefillID
        }
        
        guard let selected = data.first(where: { $0.default ?? false })
        else {
            throw Error.missingDefault
        }
        
        let data: [(SubscriptionType, MosParkingData)] = data
            .compactMap { element -> (SubscriptionType, MosParkingData)? in
                
                guard let type = SubscriptionType.make(from: element.groupName)
                else { return nil }
                
                return (type, element)
            }
        
        let options = try Dictionary(grouping: data, by: \.0)
            .mapValues { $0.map(\.1) }
            .mapValues {
                try $0.map(OptionWithMapImage.make(with:))
            }
        
        let state = try ComponentState.make(
            from: selected,
            options: options
        )
        
        return (state, options, refillID)
    }
    
    enum Error: Swift.Error {
        
        case emptyData
        case nonSelectableSubscriptionType
        case missingDefault
        case missingValue
        case missingRefillID
    }
}

private extension ComponentState {
    
    static func make(
        from selected: MosParkingData,
        options: [SubscriptionType : [OptionWithMapImage]]
    ) throws -> Self {
        
        guard let type = SubscriptionType.make(from: selected.groupName)
        else {
            throw MosParkingDataMapper.Error.nonSelectableSubscriptionType
        }
        
        let selection = ComponentState.SelectionWithOptions(
            selection: try .make(with: selected),
            options: options[type, default: []]
        )
        
        switch type {
        case .monthly:
            return .monthly(selection)
        case .yearly:
            return .yearly(selection)
        }
    }
}

private extension SubscriptionType {
    
    static func make(from string: String) -> Self? {
        
        switch string {
        case "Месячная": return .monthly
        case "Годовая":  return .yearly
        default:         return nil
        }
    }
}

private extension OptionWithMapImage {
    
    static func make(
        with data: MosParkingData
    ) throws -> Self {
        
        guard
            let id = Int(data.value),
            let title = data.text
        else {
            throw MosParkingDataMapper.Error.missingValue
        }
        
        let mapImage: MapImage = {
            
            if let image = data.svgImage?.image {
                return .image(image)
            } else {
                return .placeholder
            }
        }()
        
        return .init(
            id: id,
            value: data.value,
            mapImage: mapImage,
            title: title
        )
    }
}
