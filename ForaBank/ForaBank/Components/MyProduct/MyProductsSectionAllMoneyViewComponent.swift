//
//  MyProductsSectionAllMoneyViewComponent.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 08.03.2022.
//

import Foundation
import SwiftUI

//MARK: - ViewModel

extension MyProductsSectionAllMoneyView {
    
    class ViewModel: ObservableObject, Identifiable {
        
        let id: UUID
        let title: String
        @Published var items: [AssetBalanceView.ViewModel]
        @Published var isCollapsed: Bool
        let isActive: IsActive
        
        internal init(id: UUID = UUID(), title: String, items: [AssetBalanceView.ViewModel], isCollapsed: Bool, isActive: IsActive) {
            
            self.id = id
            self.title = title
            self.items = items
            self.isCollapsed = isCollapsed
            self.isActive = isActive
        }
        
        enum IsActive {
            
            case activated
            case deactivated
        }
    }
}

//MARK: - View

struct MyProductsSectionAllMoneyView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            switch viewModel.isActive {
                
            case .activated:

                Button {
                    
                    withAnimation {
                        
                        viewModel.isCollapsed.toggle()
                    }
                    
                } label: {
                    
                    HStack(alignment: .center, spacing: 4) {
                        
                        Text(viewModel.title)
                            .font(.textH2SB20282())
                            .foregroundColor(.textSecondary)
                        
                        if viewModel.isCollapsed {
                            
                            Image.ic24ChevronDown
                                .foregroundColor(.iconGray)
                            
                        } else {
                            
                            Image.ic24ChevronUp
                                .foregroundColor(.iconGray)
                        }
                        
                        Spacer()
                    }
                }
                
                
                if viewModel.isCollapsed == false {
                    
                    VStack(spacing: 24) {
                        
                        ForEach(viewModel.items) { itemViewModel in
                            
                            AssetBalanceView(viewModel: itemViewModel)
                                .contentShape(Rectangle())
                                .gesture(DragGesture().onChanged({ (value) in

                                    viewModel.items[getIndex(cellViewModel: itemViewModel)].offset = value.translation.width
                                })

                                            .onEnded({ (value) in
                                    withAnimation(.default){
                                        viewModel.items[getIndex(cellViewModel: itemViewModel)].offset = 0
                                    }
                                }))
                                .animation(.default)
                        }
                    }
                }
                
            case .deactivated:
                HStack(alignment: .center, spacing: 4) {
                    
                    Text(viewModel.title)
                        .font(.textH2SB20282())
                        .foregroundColor(.textDisabled)
                    
                    Image.ic24ChevronDown
                        .foregroundColor(.iconGray)
                    
                    Spacer()
                }
            }
        }
    }
    
    func getIndex(cellViewModel: AssetBalanceView.ViewModel) -> Int {
        
        var index = 0
        
        for i in 0..<viewModel.items.count{
            
            if cellViewModel.id == viewModel.items[i].id {

                index = i
            }
        }
        
        return index
    }
}
//MARK: - Preview

struct MyProductsSectionAllMoneyView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MyProductsSectionAllMoneyView(viewModel: .sample1)
    }
}

//MARK: - Preview Content

extension MyProductsSectionAllMoneyView.ViewModel {
    
    static let sample1 = MyProductsSectionAllMoneyView.ViewModel(title: "Карты",
                                                                 items: [
                                                                    .sample1,
                                                                    .sample2,
                                                                    .sample3,
                                                                    .sample4],
                                                                 isCollapsed: false,
                                                                 isActive: .activated)
    
    static let sample2 = MyProductsSectionAllMoneyView.ViewModel(title: "Вклады",
                                                                 items: [
                                                                    .sample1,
                                                                    .sample2],
                                                                 isCollapsed: false,
                                                                 isActive: .deactivated)
    
    static let sample3 = MyProductsSectionAllMoneyView.ViewModel(title: "Кредиты",
                                                                 items: [],
                                                                 isCollapsed: false,
                                                                 isActive: .deactivated)
}
