//
//  ParentCellView.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.02.2022.
//

import SwiftUI
import RealmSwift
import Combine

extension PaymentsTaxesSelectCellView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        internal init(items: [PaymentsTaxesSelectCellView.ViewModel.ItemViewModel], selectedItemTitle: String) {
            self.items = items
            self.state = .list(items)
            self.selectedItemTitle = selectedItemTitle
            super.init()
            bind()
        }
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        let items: [ItemViewModel]
        @Published var state: State
        let selectedItemTitle: String
        private var bindings: Set<AnyCancellable> = []
        
        enum State {
            case list([ItemViewModel])
            case selected(SelectedItemViewModel)
        }
        
        func bind() {
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    switch action {
                    case let payload as PaymentsTaxesSelectCellView.ViewModelAction.ItemSelected:
                        
                        guard let item = items.first(where: {$0.id == payload.itemId } ) else {return}
                        let selectedItem = SelectedItemViewModel(with: item, description: selectedItemTitle, action: {})
                        
                        state = .selected(selectedItem)
                         
                    default:
                        break
                    }
                }
                .store(in: &bindings)
            
        }
        
        ///  Массив
        struct ItemViewModel: Identifiable {
            let id = UUID()
            let logo: Image
            let title: String
            let action: (ItemViewModel.ID) -> Void
        }
        ///
        struct SelectedItemViewModel: Identifiable {
            let id: UUID
            let logo: Image
            let decription: String
            let title: String
            let action: () -> Void
            
            init(with item: ItemViewModel, description: String, action:@escaping () -> Void) {
                self.id = item.id
                self.logo = item.logo
                self.title = item.title
                self.decription = description
                self.action = action
            }
        }
        
    }
    enum ViewModelAction {
        struct ItemSelected: Action {
            let itemId: PaymentsTaxesSelectCellView.ViewModel.ItemViewModel.ID
        }
    }
}



struct PaymentsTaxesSelectCellView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack {
            switch viewModel.state {
            case .list(let items):
                ForEach(items) { item in
                    
                    Button {
                        item.action(item.id)
                    } label: {
                        HStack {
                            item.logo
                            Text(item.title)
                            Spacer()
                        }
                    }
                }
                
            case .selected(let selectedItem):
                
                HStack(spacing: 10) {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        selectedItem.logo
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 10)  {
                            Text(selectedItem.title)
                                .font(Font.custom("Inter-Regular", size: 16))
                                .foregroundColor(Color(hex: "#999999"))
                                .padding(.top, 8)
                            
                            Text(selectedItem.decription)
                                .font(Font.custom("Inter-Medium", size: 14))
                                .foregroundColor(Color(hex: "#1C1C1C"))
                        }
                        Spacer()
                        Image("chevron-downnew")
                            .frame(width: 24, height: 24)
                            .padding()
                    }
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(hex: "#EAEBEB"))
                        .padding(.trailing, 19)
                    }
                }
            }
        }
    }
}

struct PaymentsTaxesSelectCellView_Previews: PreviewProvider {
    
    static var selectedViewModel: PaymentsTaxesSelectCellView.ViewModel = {
       var viewModel = PaymentsTaxesSelectCellView.ViewModel(items: [
        .init(logo: Image("fora_white_back_bordered"), title: "qwe", action: { _ in }),
        .init(logo: Image("fora_white_back_bordered"), title: "cbcb", action: { _ in }),
        .init(logo: Image("fora_white_back_bordered"), title: "aw`d", action: { _ in })], selectedItemTitle: "Категория платежа")
        viewModel.state = .selected(.init(with: .init(logo: Image("fora_white_back_bordered"), title: "qwe", action: { _ in }), description: "Категория платежа", action:{}))
        return viewModel
    }()
    
    static var previews: some View {
        Group {
        PaymentsTaxesSelectCellView(viewModel: .init(items: [
            .init(logo: Image("fora_white_back_bordered"), title: "qwe", action: { _ in }),
            .init(logo: Image("fora_white_back_bordered"), title: "cbcb", action: { _ in }),
            .init(logo: Image("fora_white_back_bordered"), title: "aw`d", action: { _ in })], selectedItemTitle: "Категория платежа"))
        
        PaymentsTaxesSelectCellView(viewModel: selectedViewModel)
        }
    }
}

