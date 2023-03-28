//
//  PaymentsContactGroupView.swift
//  ForaBank
//
//  Created by Max Gribov on 22.02.2023.
//

import SwiftUI

struct PaymentsContactGroupView: View {
    
    @ObservedObject var viewModel: PaymentsContactGroupViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            if viewModel.isCollapsed == false {
                
                ForEach(viewModel.items) { itemViewModel in

                    if itemViewModel.id == viewModel.items.first?.id {
                        
                        HStack {
                            
                            itemView(for: itemViewModel)
                                .frame(minHeight: 72)
                            
                            ChevronButtonView(isDown: $viewModel.isCollapsed) {
                                
                                withAnimation {
                                    viewModel.isCollapsed.toggle()
                                }
                                
                            }.padding(.trailing, 4)
                        }

                    } else {
                        
                        itemView(for: itemViewModel)
                            .frame(minHeight: 72)
                    }
                }
                
            } else {
                
                HStack {
                    
                    PaymentsInfoView(viewModel: viewModel.collapsedItem, isCompact: false)
                        .frame(minHeight: 72)
                        .onTapGesture {
                            
                            withAnimation {
                                viewModel.isCollapsed.toggle()
                            }
                        }
                    
                    ChevronButtonView(isDown: $viewModel.isCollapsed) {
                        
                        withAnimation {
                            viewModel.isCollapsed.toggle()
                        }
                        
                    }.padding(.trailing, 4)
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.mainColorsGrayLightest))
        .padding(.horizontal, 13)
    }
}

extension PaymentsContactGroupView {
    
    @ViewBuilder
    func itemView(for viewModel: PaymentsParameterViewModel) -> some View {
        
        switch viewModel {
        case let inputViewModel as PaymentsInputView.ViewModel:
            PaymentsInputView(viewModel: inputViewModel)
       
        default:
            EmptyView()
        }
    }
    
    struct ChevronButtonView: View {
        
        @Binding var isDown: Bool
        let action: () -> Void
        
        var body: some View {
            
            Button(action: action) {
                
                Image.ic24ChevronDown
                    .foregroundColor(.iconGray)
                    .rotationEffect(.degrees(isDown ? 0 : 180))
                
            }.frame(width: 44, height: 44)
        }
    }
}

struct PaymentsContactGroupView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsContactGroupView(viewModel: .sampleExpanded)
            .previewLayout(.fixed(width: 375, height: 270))
        
        PaymentsContactGroupView(viewModel: .sampleCollapsed)
            .previewLayout(.fixed(width: 375, height: 100))
    }
}

//MARK: - Preview Content

extension PaymentsContactGroupViewModel {
    
    static let sampleExpanded = PaymentsContactGroupViewModel(
        items: [
            PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "Иванов"), icon: .init(named: "ic24User"), title: "Фамилия получателя*", validator: .init(rules: [])), model: .emptyMock),
            PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "Иван"), title: "Имя получателя*", validator: .init(rules: [])), model: .emptyMock),
            PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: nil), title: "Отчество (если есть)", validator: .init(rules: [])), model: .emptyMock)
        ],
        isCollapsed: false)
    
    static let sampleCollapsed = PaymentsContactGroupViewModel(
        items: [
            PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "Иванов"), icon: .init(named: "ic24User"), title: "Фамилия получателя*", validator: .init(rules: [])), model: .emptyMock),
            PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "Иван"), title: "Имя получателя*", validator: .init(rules: [])), model: .emptyMock),
            PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "Иванович"), title: "Отчество (если есть)", validator: .init(rules: [])), model: .emptyMock)
        ],
        isCollapsed: true)
}
