//
//  MultiButtons.swift
//  
//
//  Created by Dmitry Martynov on 15.08.2023.
//

import SwiftUI

/*
 {
         "type": "MULTI_BUTTONS",
         "data": {
           "list": [
             {
               "buttonText": "Заказать карту",
               "buttonStyle": "blackWhite",
               "details": {
                 "detailsGroupId": "cardsLanding",
                 "detailViewId": "twoColorsLanding"
               }
             },
             {
               "buttonText": "Войти и перевести",
               "buttonStyle": "whiteRed",
               "action": {
                 "actionType": "goToMain"
               }
             }
           ]
         }
       }
 */

public struct MultiButtonsModel: Decodable, Equatable {
    
    let type: LandingComponentsType
    let data: MultiButtonsData
    
    struct MultiButtonsData: Decodable, Equatable {
        let list: [MultiButtonsDataList]
    }
    
    struct MultiButtonsDataList: Decodable, Equatable {
        let buttonText: String
        let buttonStyle: ButtonStyleProperty
        let details: MultiButtonsDataListDetails?
        let action: MultiButtonsDataListAction?
    }
    
    struct MultiButtonsDataListDetails: Decodable, Equatable {
        let detailsGroupId: String
        let detailViewId: String
    }
    
    struct MultiButtonsDataListAction: Decodable, Equatable {
        let actionType: ActionType
    }
    
    public func reduce() -> MultiButtonsViewModel {
        
        let items = data.list.map {
            
            MultiButtonsViewModel.ItemViewModel
                .init(title: $0.buttonText,
                      style: $0.buttonStyle)
        }
        
        return .init(items: items)
    }
}

// MARK: - ViewModel

public final class MultiButtonsViewModel {
    
    let items: [ItemViewModel]
    let id: UUID = UUID()
    
    init(items: [ItemViewModel]) {
        
        self.items = items
    }
}
    
extension MultiButtonsViewModel: Hashable {

    class ItemViewModel: Identifiable {

        let id = UUID()
        let style: ButtonStyleProperty
        let title: String
        
        lazy var action: () -> Void = { [weak self] in
            
            guard let self = self else { return }
            //self.action.send(TransfersItemAction.Item.Tap(countryCode: self.countryCode))
        }

        init(title: String,
             style: ButtonStyleProperty) {
    
            self.title = title
            self.style = style
        }
    }
    
    public static func == (lhs: MultiButtonsViewModel,
                           rhs: MultiButtonsViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - View

public struct MultiButtonsView: View {
    
    public init(viewModel: MultiButtonsViewModel) {
        self.viewModel = viewModel
    }
    
    let viewModel: MultiButtonsViewModel
    
    public var body: some View {
    
        VStack(spacing: 8) {
                
            ForEach(viewModel.items) { itemViewModel in
                    
                ItemView(viewModel: itemViewModel)
            }
        }.padding(.horizontal)
    }
}

extension MultiButtonsView {
    
    struct ItemView: View {
            
        let viewModel: MultiButtonsViewModel.ItemViewModel
            
        var body: some View {
                
            Button(action: viewModel.action) {
                
                ZStack {
                
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 56)
                        .foregroundColor(Color("mainColorsGrayLightest", bundle: Bundle.module))
                                                              
                    Text(viewModel.title)
                            //.font(.textH3SB18240())
                        .foregroundColor(.black)
                }
            }
        }
    }
}


// MARK: - PreviewContent

extension MultiButtonsViewModel {
    
    static var sampleItems: [ItemViewModel] = [
        .init(title: "Заказать карту", style: .blackWhite),
        .init(title: "Войти и перевести", style: .whiteRed)
    ]
}

// MARK: - Preview

struct MultiButtonsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MultiButtonsView(viewModel: .init(
            
            items: MultiButtonsViewModel.sampleItems))
    }
}

