//
//  PageTitle.swift
//  
//
//  Created by Dmitry Martynov on 19.08.2023.
//

import SwiftUI

/*
 {
    "type":"PAGE_TITLE",
    "data":{
       "isFixed":false,
       "text":"Переводы за рубеж"
    }
 }
 */

public struct PageTitleModel: Decodable, Equatable {
    
    let type: LandingComponentsType
    let data: PageTitleDataModel
    
    struct PageTitleDataModel: Decodable, Equatable {
        
        let text: String
    }
    
    public func reduce() -> PageTitleViewModel {
        
        return .init(text: data.text)
    }
}

//MARK: - ViewModel
public final class PageTitleViewModel: Hashable {
    
    let text: String
    let id: UUID = UUID()
    
    init(text: String) {
        
        self.text = text
        
    }
    
    public static func == (lhs: PageTitleViewModel,
                           rhs: PageTitleViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//MARK: - View
public struct PageTitleView: View {
    
    let viewModel: PageTitleViewModel
    
    public init(viewModel: PageTitleViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        Text(viewModel.text).font(.bold(.title)())
            .padding(.horizontal)
            .frame(maxWidth: .infinity,  alignment: .leading)
            .background(Color(.white))
        
    }
}

// MARK: - Preview

struct PageTitleView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PageTitleView(viewModel: .init(text: "Переводы за рубеж"))
    }
}
