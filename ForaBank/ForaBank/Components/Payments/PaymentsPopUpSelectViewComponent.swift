//
//  PaymentsPopUpSelectViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsPopUpSelectView {
    
    class ViewModel: PaymentsParameterViewModel {
                
        var title: String
        let description: String?
        var items: [ItemViewModel]
        @Published var selected: Payments.ParameterSelectSimple.Option.ID?
        let action: (Payments.ParameterSelectSimple.Option.ID) -> Void
        
        private var bindings: Set<AnyCancellable> = []
        
        internal init(title: String, description: String, items: [ItemViewModel], selected: Payments.ParameterSelectSimple.Option.ID?, action: @escaping (Payments.ParameterSelectSimple.Option.ID) -> Void, parameter: Payments.ParameterMock = .init()) {
            
            self.title = title
            self.description = description
            self.items = items
            self.selected = selected
            self.action = action
            super.init(source: parameter)
            self.bind()
        }
        
        init(with parameterSelect: Payments.ParameterSelectSimple,
             selectedID: Payments.ParameterSelectSimple.Option.ID? = nil,
             action: @escaping (Payments.ParameterSelectSimple.Option.ID) -> Void) {
            
            self.title = parameterSelect.title
            self.description = parameterSelect.description
            self.selected = selectedID
            self.items = []
            self.action = action
            super.init(source: parameterSelect)
            self.items = parameterSelect.options.map { ItemViewModel(id: $0.id, name: $0.name, isSelected: false, action: {[weak self] itemId in
                self?.selected = itemId
            }) }
            self.bind()
        }
        
        func bind() {
            
            $selected
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] selected in
                    
                    for item in items {
                        
                        item.isSelected = item.id == selected ? true : false
                    }
                    
                }.store(in: &bindings)
            
            $selected
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] selected in
                    
                    guard let selected = selected else { return }
                    action(selected)
                    
                }.store(in: &bindings)
        }
        
        class ItemViewModel: Identifiable, ObservableObject {
            
            let id: Payments.ParameterSelectSimple.Option.ID
            let name: String
            let action: (Payments.ParameterSelectSimple.Option.ID?) -> Void
            @Published var isSelected: Bool
            
            init(id: Payments.ParameterSelectSimple.Option.ID, name: String, isSelected: Bool, action: @escaping (Payments.ParameterSelectSimple.Option.ID?) -> Void) {
                
                self.id = id
                self.name = name
                self.isSelected = isSelected
                self.action = action
            }
        }
    }
}

//MARK: - View

struct PaymentsPopUpSelectView: View {
    
    var viewModel: PaymentsPopUpSelectView.ViewModel
    
    var body: some View {
                
        ZStack {
            
            Color.clear
            
            VStack {
                
                Spacer()
                
                VStack(spacing: 0) {
                    
                    Capsule()
                        .frame(width: 32, height: 4)
                        .foregroundColor(Color(hex: "#EAEBEB"))
                        .padding(.top,8)
                        .padding(.bottom, 16)
           
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text(viewModel.title)
                            .foregroundColor(Color(hex: "#1C1C1C"))
                            .font(Font.custom("Inter-SemiBold", size: 18))
                        
                        if let description = viewModel.description {
                            
                            Text(description)
                                .foregroundColor(Color(hex: "#999999"))
                                .font(Font.custom("Inter-Regular", size: 14))
                        }
                        
                        VStack(spacing: 24) {
                            
                            ForEach(viewModel.items) { item in
                                
                                ItemView(viewModel: item)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .background(RoundedCorner(radius: 16,
                                          corners: [.topLeft, .topRight])
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.1),
                                        radius: 1, x: 0, y: -2))
                
            }
        }
        .transition(.scale)
    }
    
    struct ItemView: View {
        
        @ObservedObject var viewModel: ViewModel.ItemViewModel
        
        var body: some View {
            
            VStack {
                
                HStack(alignment: .top, spacing: 24) {
                    
                    if viewModel.isSelected == true {
                        
                        Image("Payments Icon Circle Selected")
                            .frame(width: 24, height: 24)
                        
                    } else {
                        
                        Image("Payments Icon Circle Empty")
                            .frame(width: 24, height: 24)
                    }
                    
                    Text(viewModel.name)
                        .foregroundColor(Color(hex: "#1C1C1C"))
                        .font(Font.custom("Inter-Regular", size: 14))
                        .padding(.top, 3)
                    
                    Spacer()
                }
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color(hex: "#EAEBEB"))
                    .padding(.leading, 44)
            }
            .onTapGesture {
                
                viewModel.action(viewModel.id)
            }
        }
    }
    
}

//MARK: - Preview

struct PaymentsPopUpSelectView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsPopUpSelectView(viewModel: sample)
            .previewLayout(.fixed(width: 375, height: 500))
    }
}

//MARK: - Preview Content

extension PaymentsPopUpSelectView_Previews {
    
    static let sample = PaymentsPopUpSelectView.ViewModel(
        title: "Выберите значение",
        description: "Государственная пошлина за выдачу паспорта удостоверяющего личность гражданина РФ за пределами территории РФ гражданину РФ",
        items: [.init(id: "0", name: "В возрасте от 14 лет", isSelected: true, action: {_ in }),
                .init(id: "1", name: "В возрасте до 14 лет", isSelected: false, action: {_ in }),
                .init(id: "2", name: "В возрасте до 14 лет (новый образец)", isSelected: false, action: {_ in }),
                .init(id: "3", name: "Содержащего электронный носитель информации (паспорта нового поколения)", isSelected: false, action: {_ in }),
                .init(id: "4", name: "За внесение изменений в паспорт", isSelected: false, action: {_ in })], selected: "0", action: { _ in })
}
