//
//  MultiText.swift
//  
//
//  Created by Dmitry Martynov on 15.08.2023.
//

import SwiftUI

/*
 {
         "type": "MULTI_TEXT",
         "data": {
           "list": [
             "Фора-банк является зарегистрированным поставщиком платежных услуг. Наша деятельность находится под контролем Налогово-таможенной службы (HMRC) в соответствии с Положением об отмывании денег №12667079 и регулируется Управлением по финансовому регулированию и надзору РФ"
           ]
         }
       }
 */

public struct MultiTextModel: Decodable, Equatable {
    
    let type: LandingComponentsType
    let data: MultiTextData
    
    struct MultiTextData: Decodable, Equatable {
        let list: [String]
    }
    
    public func reduce() -> MultiTextViewModel {
        
        return .init(items: data.list)
    }
}

// MARK: - ViewModel

public final class MultiTextViewModel {
    
    let items: [String]
    let id: UUID = UUID()
    
    init(items: [String]) {
        
        self.items = items
    }
}
    
extension MultiTextViewModel: Hashable {

    public static func == (lhs: MultiTextViewModel,
                           rhs: MultiTextViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - View

public struct MultiTextView: View {
    
    public init(viewModel: MultiTextViewModel) {
        self.viewModel = viewModel
    }
    
    let viewModel: MultiTextViewModel
    
    public var body: some View {
    
        VStack(spacing: 8) {
                
            ForEach(viewModel.items, id: \.self) { itemText in
                    
                Text(itemText)
                    //.font(.textBodySR12160())
                    .foregroundColor(.gray)//.mainColorsGray)
            }
        }.padding(.horizontal)
    }
}

// MARK: - PreviewContent

extension MultiTextViewModel {
    
    static var sampleItems: [String] = [
        "Фора-банк является зарегистрированным поставщиком платежных услуг. Наша деятельность находится под контролем Налогово-таможенной службы (HMRC) в соответствии с Положением об отмывании денег №12667079 и регулируется Управлением по финансовому регулированию и надзору РФ"
    ]
}

// MARK: - Preview

struct MultiTextView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MultiTextView(viewModel: .init(
            
            items: MultiTextViewModel.sampleItems))
    }
}
