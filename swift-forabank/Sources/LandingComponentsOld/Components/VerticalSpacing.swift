//
//  VerticalSpacing.swift
//  
//
//  Created by Dmitry Martynov on 28.07.2023.
//

import SwiftUI

/*
{
   "type":"VERTICAL_SPACING",
   "data":{
      "backgroundColor":"WHITE",
      "bigSpacingType":true
   }
}
*/

public struct VerticalSpacingModel: Decodable, Equatable {
    
    let type: LandingComponentsType
    let data: VerticalSpacingDataModel
    
    struct VerticalSpacingDataModel: Decodable, Equatable {
        
        let backgroundColor: ColorProperty
        let bigSpacingType: Bool
    }
    
    static func reduce() -> VerticalSpacingViewModel {
        //TODO:
        return .init(regularTextItems: [], boldTextItems: [])
    }
}

//MARK: - ViewModel
public final class VerticalSpacingViewModel {
    
    let regularTextItems: [String]
    let boldTextItems: [String]
    
    init(regularTextItems: [String], boldTextItems: [String]) {
        
        self.regularTextItems = regularTextItems
        self.boldTextItems = boldTextItems
    }
}

//MARK: - View
public struct VerticalSpacingView: View {
    
    let viewModel: VerticalSpacingViewModel
    
    public init(viewModel: VerticalSpacingViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        VStack {
            
            Text(viewModel.regularTextItems.first ?? "")
            Text(viewModel.boldTextItems.first ?? "").font(.bold(.caption)())
        }
    }
}

