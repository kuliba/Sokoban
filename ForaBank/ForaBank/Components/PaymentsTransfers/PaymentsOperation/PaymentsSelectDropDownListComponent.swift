//
//  PaymentsSelectDropDownList.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 09.02.2023.
//

import Foundation
import SwiftUI
import Combine

extension PaymentSelectDropDownView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        @Published private(set) var state: State

        private init(state: State, source: PaymentsParameterRepresentable) {
            
            self.state = state
            super.init(source: source)
        }
        
        convenience init?(with parameterSelect: Payments.ParameterSelectDropDownList) {
            
            guard let selectedOption = SelectedOptionViewModel(with: parameterSelect)
            else { return nil }
            
            self.init(state: .selected(selectedOption), source: parameterSelect)
            
            bind()
        }
    }
}

//MARK: - Calculated Properties

extension PaymentSelectDropDownView.ViewModel {
 
    var parameterDropDownList: Payments.ParameterSelectDropDownList? {
        
        source as? Payments.ParameterSelectDropDownList
    }
}

//MARK: - Bindings

extension PaymentSelectDropDownView.ViewModel {
    
    private func bind() {
        
        action
            .compactMap { $0 as? PaymentsParameterViewModelAction.DropDown.Toggle }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                guard let parameterDropDownList,
                      let selectedOption = parameterDropDownList.options.first(where: { $0.id == value.current }) else {
                    return
                }
                
                withAnimation {
                    
                    switch state {
                    case .selected:
                        state = .list(.init(with: parameterDropDownList, and: selectedOption))
                        
                    case .list:
                        state = .selected(.init(with: parameterDropDownList, and: selectedOption))
                    }
                }
                
            }.store(in: &bindings)
        
        action
            .compactMap { $0 as? PaymentsParameterViewModelAction.DropDown.DidSelectOption }
            .map(\.id)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] id in
                
                guard let parameterDropDownList,
                      let selectedOption = parameterDropDownList.options.first(where: { $0.id == id }) else {
                    return
                }
                
                self.update(value: id)
                
                withAnimation {
                    
                    state = .selected(.init(with: parameterDropDownList, and: selectedOption))
                }
                
            }.store(in: &bindings)
    }
}

//MARK: - Types

extension PaymentSelectDropDownView.ViewModel {
    
    enum State: Equatable {
        
        case selected(SelectedOptionViewModel)
        case list(OptionsListViewModel)
    }
    
    struct SelectedOptionViewModel: Equatable {
        
        let title: String
        let name: String
        let icon: IconViewModel
    }
    
    struct OptionsListViewModel: Equatable {
        
        let title: String
        let name: String
        let icon: IconViewModel
        let options: [OptionViewModel]
        let selected: OptionViewModel.ID
    }
    
    struct OptionViewModel: Identifiable, Equatable {
        
        let id: String
        let name: String
        let icon: IconViewModel
    }
    
    enum IconViewModel: Equatable {
        
        case image(Image)
        case placeholder
    }
}

//MARK: - Convenience Inits

private extension PaymentSelectDropDownView.ViewModel.SelectedOptionViewModel {
    
    init?(with parameterDropDownList: Payments.ParameterSelectDropDownList) {
        
        guard let defaultOption = parameterDropDownList.options.first(where: { $0.id == parameterDropDownList.value })
        else { return nil }
        
        self.init(with: parameterDropDownList, and: defaultOption)
    }
    
    init(with parameterSelect: Payments.ParameterSelectDropDownList, and option: Payments.ParameterSelectDropDownList.Option) {
        
        self.init(
            title: parameterSelect.title,
            name: option.name,
            icon: .init(with: option.icon)
        )
    }
}

private extension PaymentSelectDropDownView.ViewModel.OptionsListViewModel {
    
    init(with parameterSelect: Payments.ParameterSelectDropDownList, and option: Payments.ParameterSelectDropDownList.Option) {
        
        self.init(
            title: parameterSelect.title,
            name: option.name,
            icon: .init(with: option.icon),
            options: parameterSelect.options.map({ .init(id: $0.id, name: $0.name, icon: .init(with: $0.icon))}),
            selected: option.id
        )
    }
}

private extension PaymentSelectDropDownView.ViewModel.IconViewModel {
    
    init(with optionIcon: Payments.ParameterSelectDropDownList.Option.Icon?) {
        
        switch optionIcon {
        case let .image(imageData):
            switch imageData.image {
            case let .some(image):
                self = .image(image)
            case .none:
                self = .placeholder
            }
            
        case let .name(imageName):
            self = .image(Image(imageName))
            
        case .none:
            self = .placeholder
        }
    }
}

//MARK: - Actions

extension PaymentsParameterViewModelAction {
    
    enum DropDown {
        
        struct Toggle: Action {}
        
        struct DidSelectOption: Action {
            
            let id: PaymentSelectDropDownView.ViewModel.OptionViewModel.ID
        }
    }
}

//MARK: - View

struct PaymentSelectDropDownView: View {
    
    @ObservedObject var viewModel: ViewModel
    @Namespace var namespace
    
    var body: some View {
        
        VStack(spacing: 0) {
           
            switch viewModel.state {
            case let .selected(selectedOptionViewModel):
                SelectedOptionView(viewModel: selectedOptionViewModel, namespace: namespace) {
                    
                    viewModel.action.send(PaymentsParameterViewModelAction.DropDown.Toggle())
                }
                
            case let .list(optionsListViewModel):
                OptionsListView(viewModel: optionsListViewModel, namespace: namespace) {
                    
                    viewModel.action.send(PaymentsParameterViewModelAction.DropDown.Toggle())
                    
                } select: { selectedOptionId in
                    
                    viewModel.action.send(PaymentsParameterViewModelAction.DropDown.DidSelectOption(id: selectedOptionId))
                }
            }
        }
        .animation(.easeInOut, value: viewModel.state)
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
    
    //MARK: - Internal Views
    
    struct SelectedOptionView: View {
        
        let viewModel: PaymentSelectDropDownView.ViewModel.SelectedOptionViewModel
        let namespace: Namespace.ID
        let tapAction: () -> Void

        var body: some View {
            
            HStack(spacing: 16) {
                
                IconView(viewModel: viewModel.icon)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14180())
                        .foregroundColor(.textPlaceholder)
                    
                    Text(viewModel.name)
                        .font(.textH4M16240())
                        .foregroundColor(.textWhite)
                }
                
                Spacer()
                
                Image.ic24ChevronDown
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(.iconGray)
                    .frame(width: 24, height: 24)
                
            }
            .matchedGeometryEffect(id: MatchedID.selectedOption, in: namespace)
            .frame(minHeight: 46)
            .contentShape(Rectangle())
            .onTapGesture { tapAction() }
        }
    }
    
    struct OptionsListView: View {
        
        let viewModel: PaymentSelectDropDownView.ViewModel.OptionsListViewModel
        let namespace: Namespace.ID
        let toggle: () -> Void
        let select: (PaymentSelectDropDownView.ViewModel.OptionViewModel.ID) -> Void
        
        var body: some View {
            
            VStack(spacing: 4) {
                
                HStack(spacing: 16) {
                    
                    IconView(viewModel: viewModel.icon, iconColor: .blurGray20)
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text(viewModel.title)
                            .font(.textBodyMR14180())
                            .foregroundColor(.textPlaceholder)
                        
                        Text(viewModel.name)
                            .font(.textH4M16240())
                            .foregroundColor(.textPrimary)
                    }
                    
                    Spacer()
                    
                    Image.ic24ChevronUp
                        .renderingMode(.template)
                        .resizable()
                        .foregroundColor(.iconGray)
                        .frame(width: 24, height: 24)
                }
                .matchedGeometryEffect(id: MatchedID.selectedOption, in: namespace)
                .frame(minHeight: 46)
                .contentShape(Rectangle())
                .onTapGesture { toggle() }
                
                ForEach(viewModel.options) { optionViewModel in
                    
                    OptionView(viewModel: optionViewModel, isSelected: optionViewModel.id == viewModel.selected) {
                        
                        select(optionViewModel.id)
                    }
                    .frame(minHeight: 46)
                    
                    if optionViewModel.id != viewModel.options.last?.id {
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.mainColorsGray)
                            .opacity(0.2)
                            .padding(.leading, 40)
                    }
                }
            }
        }
    }
    
    struct OptionView: View {
        
        let viewModel: ViewModel.OptionViewModel
        let isSelected: Bool
        let selectAction: () -> Void
        
        var body: some View {
            
            VStack(spacing: 12) {
                
                HStack(spacing: 16) {
                    
                    IconView(viewModel: viewModel.icon)
                        .frame(width: 24, height: 24)
                    
                    Text(viewModel.name)
                        .foregroundColor(.textWhite)
                        .font(.textH4M16240())
                    
                    Spacer()
                    
                    RadioIconView(isSelected: isSelected)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { selectAction() }
        }
    }
    
    struct IconView: View {
        
        let viewModel: PaymentSelectDropDownView.ViewModel.IconViewModel
        var iconColor: Color = .iconGray
        
        var body: some View {
            
            Group {
                
                switch viewModel {
                case let .image(image):
                    image
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(iconColor)
                    
                case .placeholder:
                    Color.clear
                }
            }
        }
    }
    
    struct RadioIconView: View {
        
        let isSelected: Bool
        
        var body: some View {
            
            Image(radioIconName)
                .renderingMode(.template)
                .foregroundColor(radioIconColor)
        }
        
        //TODO: load placeholder icon from StyleGuide
        private var radioIconName: String { isSelected ? "Payments Icon Circle Selected" : "Payments Icon Circle Empty" }
        private var radioIconColor: Color { isSelected ? .buttonPrimary : .mainColorsGray }
    }
    
    enum MatchedID: Hashable {
            
        case selectedOption
    }
}


// MARK: - Preview

struct PaymentSelectDropDownView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsGroupView(viewModel: PaymentSelectDropDownView.ViewModel.selectedGroup)
        }
    }
}

//MARK: - Preview Content

extension PaymentSelectDropDownView.ViewModel {
    
    static let selectedGroup = PaymentsGroupViewModel(items: [
        
        PaymentSelectDropDownView.ViewModel.sample
    ])
    
    static let sample = PaymentSelectDropDownView.ViewModel(
        with: .init(
            .init(id: "some_parameter_id",
                  value: "0"),
            title: "Тип оплаты",
            options: [
                .init(id: "0", name: "По номеру телефона", icon: .name("ic24Phone")),
                .init(id: "1", name: "По реквизитам", icon: nil)
            ]))!
}
