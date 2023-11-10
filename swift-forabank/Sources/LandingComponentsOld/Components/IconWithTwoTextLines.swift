//
//  IconWithTwoTextLines.swift
//  
//
//  Created by Dmitry Martynov on 28.07.2023.
//

import SwiftUI

//MARK: - Model

/* {
     "type":"ICON_WITH_TWO_TEXT_LINES",
     "data":{
             "md5hash":"6046e5eaff596a41ce9845cca3b0a887",
             "title":"Армения",
             "subTitle":"Армения"
     }
   } */
 

public struct IconWithTwoTextLinesModel: Decodable, Equatable {
    
    let type: LandingComponentsType
    let data: IconWithTwoTextLinesDataModel
    
    struct IconWithTwoTextLinesDataModel: Decodable, Equatable {
        
        let md5hash: String
        let title: String?
        let subTitle: String?
    }
    
    static func reduce() -> IconWithTwoTextLinesViewModel {
        //TODO:
        return .init(regularTextItems: [], boldTextItems: [])
    }
}

//MARK: - ViewModel
public final class IconWithTwoTextLinesViewModel {
    
    let regularTextItems: [String]
    let boldTextItems: [String]
    
    init(regularTextItems: [String], boldTextItems: [String]) {
        
        self.regularTextItems = regularTextItems
        self.boldTextItems = boldTextItems
    }
}

//MARK: - View
public struct IconWithTwoTextLinesView: View {
    
    let viewModel: IconWithTwoTextLinesViewModel
    
    public init(viewModel: IconWithTwoTextLinesViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        VStack {
            
            Text(viewModel.regularTextItems.first ?? "")
            Text(viewModel.boldTextItems.first ?? "").font(.bold(.caption)())
        }
    }
}

