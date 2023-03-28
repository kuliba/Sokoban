//
//  PaymentsSelectDropDownList.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 09.02.2023.
//

import Foundation
import SwiftUI

extension PaymentSelectDropDownView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        @Published var selectItem: SelectViewModel
        @Published var options: [OptionViewModel]?
        
        var parameterDropDownList: Payments.ParameterSelectDropDownList? { source as? Payments.ParameterSelectDropDownList }
        
        init(selectItem: SelectViewModel, options: [OptionViewModel]?, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.selectItem = selectItem
            self.options = options
            super.init(source: source)
        }
        
        convenience init?(with parameterSelect: Payments.ParameterSelectDropDownList) {
            
            let defaultOption = parameterSelect.options.first(where: {$0.id == parameterSelect.value})
            
            if let defaultOption = defaultOption {
                
                self.init(selectItem: .init(icon: defaultOption.icon?.image, title: parameterSelect.title, selectTitle: defaultOption.name, button: .init(icon: Image.ic24ChevronRight, action: {}, style: parameterSelect.options.count > 1 ? .active : .inactive)), options: nil, source: parameterSelect)
                
            } else {
                
                return nil
            }
            
            if parameterSelect.options.count > 1 {
                
                self.selectItem.button = .init(icon: Image.ic24ChevronRight, action: { [weak self] in
                    
                    self?.action.send(PaymentSelectDropDownView.ViewModel.ShowOptions())
                }, style: .active)
            }
            
            bind()
        }
        
        struct OptionViewModel: Identifiable {
            
            let id: String
            let icon: Image?
            let title: String
            let action: (OptionViewModel.ID) -> Void
        }
        
        struct SelectViewModel {
            
            let icon: Image?
            let title: String
            let selectTitle: String
            var button: ButtonViewModel
            
            struct ButtonViewModel {
                
                let icon: Image
                let action: () -> Void
                let style: Style
                
                enum Style {
                    
                    case active
                    case inactive
                }
            }
        }
    }
}

extension PaymentSelectDropDownView.ViewModel {
    
    private func bind() {
        
        action
            .compactMap { $0 as? PaymentSelectDropDownView.ViewModel.ShowOptions }
            .receive(on: DispatchQueue.main)
            .sink {[unowned self] action in
                
                if self.options != nil {
                    
                    withAnimation {
                        
                        self.options = nil
                    }
                    
                } else {
                    
                    let options = self.parameterDropDownList?.options.map({OptionViewModel(id: $0.id, icon: $0.icon?.image, title: $0.name, action: { [weak self] id in
                        
                        self?.action.send(PaymentSelectDropDownView.ViewModel.DidSelectOption(id: id))
                    })})
                    
                    withAnimation {
                        
                        self.options = options
                    }
                }
                
            }.store(in: &bindings)
        
        action
            .compactMap { $0 as? PaymentSelectDropDownView.ViewModel.DidSelectOption }
            .receive(on: DispatchQueue.main)
            .sink {[unowned self] payload in
                
                withAnimation {
                    
                    if let parameter = parameterDropDownList,
                       let selectItem = self.options?.first(where: {$0.id == payload.id}) {
                        self.update(value: selectItem.id)
                        
                        self.selectItem = .init(icon: selectItem.icon, title: parameter.title, selectTitle: selectItem.title, button: .init(icon: Image.ic24ChevronRight, action: { self.action.send(PaymentSelectDropDownView.ViewModel.ShowOptions()) }, style: .active))
                        
                        self.options = nil
                    }
                }
                
            }.store(in: &bindings)
    }
}

extension PaymentSelectDropDownView.ViewModel {
    
    struct ShowOptions: Action {}
    
    struct DidSelectOption: Action {
        
        let id: PaymentSelectDropDownView.ViewModel.OptionViewModel.ID
    }
}

struct PaymentSelectDropDownView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(spacing: 4) {
            
            SelectView(viewModel: viewModel)
                .contentShape(Rectangle())
                .onTapGesture {
                    
                    viewModel.selectItem.button.action()
                }
            
            if let options = viewModel.options {
                
                VStack(alignment: .leading) {
                    
                    ForEach(options) { item in
                        
                        OptionView(viewModel: item, isSelected: item.title == viewModel.selectItem.title)
                            .contentShape(Rectangle())
                        
                        Divider()
                            .frame(height: 1)
                            .foregroundColor(.mainColorsGray)
                            .padding(.leading, 40)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
    
    struct OptionView: View {
        
        let viewModel: ViewModel.OptionViewModel
        let isSelected: Bool
        
        var body: some View {
            
            HStack(spacing: 20) {
                
                if let icon = viewModel.icon {
                    
                    icon
                        .resizable()
                        .foregroundColor(.iconGray)
                        .frame(width: 32, height: 32)
                    
                } else {
                    
                    Color.clear
                        .frame(width: 32, height: 32, alignment: .center)
                    
                }
                
                Text(viewModel.title)
                    .foregroundColor(.textWhite)
                    .font(.textH4M16240())
                
                Spacer()
                
                if isSelected == true {
                    
                    Image("Payments Icon Circle Selected")
                        .frame(width: 24, height: 24)
                    
                } else {
                    
                    Image("Payments Icon Circle Empty")
                        .frame(width: 24, height: 24)
                }
            }
            .onTapGesture {
                
                viewModel.action(viewModel.id)
            }
            .frame(height: 46)
        }
        
    }
    
    struct SelectView: View {
        
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            
            HStack(spacing: 20) {
                
                if let icon = viewModel.selectItem.icon {
                    
                    icon
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.iconGray)
                        .frame(width: 32, height: 32)
                        .opacity(viewModel.options != nil ? 0.2 : 1)
                    
                } else {
                    
                    Color.clear
                        .frame(width: 32, height: 32)
                    
                }
                
                VStack(spacing: 8) {
                    
                    Text(viewModel.selectItem.title)
                        .font(.textBodyMR14180())
                        .foregroundColor(.textPlaceholder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let _ = viewModel.options {
                        
                        Text(viewModel.selectItem.selectTitle)
                            .font(.textH4M16240())
                            .foregroundColor(.textPrimary)
                            .frame(alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                    } else {
                        
                        Text(viewModel.selectItem.selectTitle)
                            .font(.textH4M16240())
                            .foregroundColor(.textWhite)
                            .frame(alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer()
                
                switch viewModel.selectItem.button.style {
                case .active:
                    Button(action: viewModel.selectItem.button.action) {
                        
                        viewModel.selectItem.button.icon
                            .frame(width: 24, height: 24)
                            .foregroundColor(.iconGray)
                            .rotationEffect(viewModel.options != nil ? .degrees(-90) : .degrees(90))
                    }
                case .inactive:
                    Button(action: viewModel.selectItem.button.action) {
                        
                        viewModel.selectItem.button.icon
                            .frame(width: 24, height: 24)
                            .foregroundColor(.iconGray)
                            .rotationEffect(.degrees(90))
                            .opacity(0.2)
                    }
                    .allowsHitTesting(false)
                }
            }
        }
    }
}


// MARK: - Preview

struct PaymentSelectDropDownView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentSelectDropDownView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 120))
                .padding()
            
            PaymentSelectDropDownView(viewModel: .sampleMultiple)
                .previewLayout(.fixed(width: 375, height: 400))
                .padding()
        }
        .background(Color.mainColorsBlack)
    }
}

//MARK: - Preview Content

extension PaymentSelectDropDownView.ViewModel {
    
    static let sample = PaymentSelectDropDownView.ViewModel(selectItem: .init(icon: Image.ic24Phone, title: "Перевести", selectTitle: "По номеру телефона", button: .init(icon: Image.ic16ChevronRight, action: {}, style: .inactive)), options: nil)
    
    static let sampleMultiple = PaymentSelectDropDownView.ViewModel(selectItem: .init(icon: Image.ic24Phone, title: "Перевести", selectTitle: "По номеру телефона", button: .init(icon: Image.ic24ChevronRight, action: {}, style: .active)), options: [.init(id: "", icon: nil, title: "По ФИО", action: {_ in }), .init(id: "", icon: Image.ic24Phone, title: "По номеру телефона", action: {_ in })])
}
