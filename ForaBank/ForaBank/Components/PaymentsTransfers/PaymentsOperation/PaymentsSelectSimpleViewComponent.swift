//
//  PaymentsSelectSimpleViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsSelectSimpleView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
                
        let icon: Image
        let title: String
        
        @Published var content: String
        @Published var description: String?
        //FIXME: remove, use value
        @Published var selectedOptionId: Option.ID?
        
        override var isValid: Bool { value.current != nil }
        
        //TODO: real placeholder required
        private static let iconPlaceholder = Image("Payments Icon Placeholder")
        
        init(icon: Image, title: String, content: String, description: String?, selectedOptionId: Option.ID? = nil, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.icon = icon
            self.title = title
            self.content = content
            self.description = description
            self.selectedOptionId = selectedOptionId
            super.init(source: source)
        }
        
        init(with parameterSelect: Payments.ParameterSelectSimple) {
            
            self.icon = parameterSelect.icon.image ?? Self.iconPlaceholder
            self.title = parameterSelect.title
            self.content = parameterSelect.selectionTitle
            self.description = parameterSelect.description
            self.selectedOptionId = parameterSelect.parameter.value
            super.init(source: parameterSelect)
            
            bind()
        }
        
        func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] action in
                    
                    switch action {
                    case _ as PaymentsParameterViewModelAction.SelectSimple.DidTapped:
                        guard let popUpViewModel = popUpViewModel else {
                            return
                        }
                        self.action.send(PaymentsParameterViewModelAction.SelectSimple.PopUpSelector.Show(viewModel: popUpViewModel))
                        
                    default:
                        break
                    }
            
                }.store(in: &bindings)
            
            $value
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] value in
                    
                    selectedOptionId = value.current
                }
                .store(in: &bindings)
            
            $selectedOptionId
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] selectedOptionId in
                    
                    if let parameterSelect = source as? Payments.ParameterSelectSimple,
                        let selectedOptionId = selectedOptionId,
                        let selectedOption = parameterSelect.options.first(where: { $0.id == selectedOptionId })  {
                        
                        self.content = selectedOption.name
                        self.description = parameterSelect.description
                        
                    } else {
                        
                        self.content = "Выберите услугу"
                        self.description = nil
                    }
                }
                .store(in: &bindings)
        }
        
        var popUpViewModel: PaymentsPopUpSelectView.ViewModel? {
            
            guard let parameterSelect = source as? Payments.ParameterSelectSimple else {
                return nil
            }

            return PaymentsPopUpSelectView.ViewModel(title: title, description: description, options: parameterSelect.options, selected: value.current) { [weak self] optionId in
                
                self?.update(value: optionId)
                self?.action.send(PaymentsParameterViewModelAction.SelectSimple.PopUpSelector.Close())
            }
        }
    }
}

//MARK: - Action

extension PaymentsParameterViewModelAction {

    enum SelectSimple {
    
        struct DidTapped: Action {}
        
        enum PopUpSelector {
            
            struct Show: Action {
                
                let viewModel: PaymentsPopUpSelectView.ViewModel
            }
            
            struct Close: Action {}
        }
    }
}

//MARK: - View

struct PaymentsSelectSimpleView: View {
    
    @ObservedObject var viewModel: PaymentsSelectSimpleView.ViewModel
    
    var body: some View {
        
        if viewModel.isEditable == true {
            
            HStack(alignment: .top, spacing: 16) {
               
                viewModel.icon
                    .resizable()
                    .frame(width: 32, height: 32)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 4) {
                   
                    Text(viewModel.title)
                        .font(.textBodySR12160())
                        .foregroundColor(.textPlaceholder)
                    
                    HStack(alignment:. top, spacing: 16) {
        
                        Text(viewModel.content)
                            .font(.textBodyMM14200())
                            .foregroundColor(.textSecondary)
                        
                        Spacer()
                        
                        Image.ic24ChevronDown
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    
                    if let description = viewModel.description {
                        
                        Text(description)
                            .font(.textBodyMM14200())
                            .foregroundColor(.textPlaceholder)
                            .padding(.trailing, 28)
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.bordersDivider)
                        .padding(.top, 8)
                }
            }
            .onTapGesture {
                
                viewModel.action.send(PaymentsParameterViewModelAction.SelectSimple.DidTapped())
            }
            
        } else {
            
            HStack(alignment: .top, spacing: 16) {
               
                viewModel.icon
                    .resizable()
                    .frame(width: 32, height: 32)
                    .padding(.top, 10)
                
                VStack(alignment: .leading, spacing: 4) {
                   
                    Text(viewModel.title)
                        .font(.textBodySR12160())
                        .foregroundColor(.textPlaceholder)
                    
                    Text(viewModel.content)
                        .font(.textBodyMM14200())
                        .foregroundColor(.textSecondary)
                    
                    if let description = viewModel.description {
                        
                        Text(description)
                            .font(.textBodyMM14200())
                            .foregroundColor(.textPlaceholder)
                            .padding(.trailing, 28)
                    }
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.bordersDivider)
                        .padding(.top, 8)
                }
            }
        }
    }
}

//MARK: - Preview

struct PaymentsSelectSimpleView_Previews: PreviewProvider {
    
    static var previews: some View {
        
    Group {
            PaymentsSelectSimpleView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 100))
            
            PaymentsSelectSimpleView(viewModel: .sampleSelected)
                .previewLayout(.fixed(width: 375, height: 200))
        
            PaymentsSelectSimpleView(viewModel: .sampleSelectedNotEditable)
                .previewLayout(.fixed(width: 375, height: 200))
        }
    }
}

//MARK: - Preview Content

extension PaymentsSelectSimpleView.ViewModel {
    
    static let sample = try! PaymentsSelectSimpleView.ViewModel(with: .init(.init(id: UUID().uuidString, value: nil), icon: .init(with: UIImage(named: "Payments List Sample")!)!, title: "Тип услуги", selectionTitle: "Выберите услугу", description: nil, options: []))
    
    
    static let sampleSelected = try! PaymentsSelectSimpleView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "0"), icon: .init(with: UIImage(named: "Payments List Sample")!)!, title: "Тип услуги", selectionTitle: "Выберите услугу", description: "Государственная пошлина за выдачу паспорта удостоверяющего личность гражданина РФ за пределами территории РФ гражданину РФ", options: [.init(id: "0", name: "В возрасте до 14 лет (новый образец) В возрасте до 14 лет (новый образец) В возрасте до 14 лет (новый образец)")]))
    
    static let sampleSelectedNotEditable = try! PaymentsSelectSimpleView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "0"), icon: .init(with: UIImage(named: "Payments List Sample")!)!, title: "Тип услуги", selectionTitle: "Выберите услугу", description: "Государственная пошлина за выдачу паспорта удостоверяющего личность гражданина РФ за пределами территории РФ гражданину РФ", options: [.init(id: "0", name: "В возрасте до 14 лет (новый образец)")], isEditable: false))
}

