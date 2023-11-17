//
//  MultiLineHeader.swift
//  
//
//  Created by Dmitry Martynov on 25.07.2023.
//

import SwiftUI

//MARK: - Model
/*
{
 "type": "MULTI_LINE_HEADER",
 "data": {
             "backgroundColor": "GREY",
             "boldTextList": [
                    "МИР",
                    "«Все включено»"
             ],
             "regularTextList": [
                    "ccc"
             ]
         }
}
*/

public struct MultiLineHeaderModel: Decodable, Equatable {
    
    let type: LandingComponentsType
    let data: MultiLineHeaderDataModel
    
    struct MultiLineHeaderDataModel: Decodable, Equatable {
        
        let regularTextList: [String]?
        let boldTextList: [String]?
        let backgroundColor: ColorProperty
    }
    
    public func reduce() -> MultiLineHeaderViewModel {
        
        return .init(regularTextItems: data.regularTextList,
                     boldTextItems: data.boldTextList)
    }
}

//MARK: - ViewModel
public final class MultiLineHeaderViewModel: Hashable {
    
    let regularTextItems: [String]?
    let boldTextItems: [String]?
    let id: UUID = UUID()
    
    init(regularTextItems: [String]?, boldTextItems: [String]?) {
        
        self.regularTextItems = regularTextItems
        self.boldTextItems = boldTextItems
    }
    
    public static func == (lhs: MultiLineHeaderViewModel,
                           rhs: MultiLineHeaderViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//MARK: - View
public struct MultiLineHeaderView: View {
    
    let viewModel: MultiLineHeaderViewModel
    
    public init(viewModel: MultiLineHeaderViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        VStack(alignment: .leading) {
            
            if let regularTextItems = viewModel.regularTextItems {
                
                ForEach(regularTextItems, id: \.self) { text in
                    Text(text).font(.title)
                }
            }
            
            if let boldTextItems = viewModel.boldTextItems {
                
                ForEach(boldTextItems, id: \.self) { text in
                    Text(text).font(.bold(.title)())
                }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity,  alignment: .leading)
        .background(Color(.white))
        
    }
}

// MARK: - Preview

struct MultiLineHeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MultiLineHeaderView(viewModel: .init(regularTextItems: ["Переводы"],
                                             boldTextItems: ["за рубеж"]))
    }
}
