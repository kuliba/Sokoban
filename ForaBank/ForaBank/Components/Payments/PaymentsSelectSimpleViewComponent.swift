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
    
    class ViewModel: PaymentsParameterViewModel {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        let icon: Image
        let title: String
        
        @Published var content: String
        @Published var description: String?
        @Published var selectedOptionId: Payments.ParameterSelectSimple.Option.ID?
        
        override var isValid: Bool { value.current != nil }
        
        //TODO: real placeholder required
        private static let iconPlaceholder = Image("Payments Icon Placeholder")
        private var bindings: Set<AnyCancellable> = []
        
        internal init(icon: Image,
                      title: String,
                      content: String,
                      description: String?,
                      selectedOptionId: Payments.ParameterSelectSimple.Option.ID? = nil) {
            
            self.icon = icon
            self.title = title
            self.content = content
            self.description = description
            self.selectedOptionId = selectedOptionId
            super.init(source: Payments.ParameterMock())
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
            
            $selectedOptionId
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] selectedOptionId in
                    
                    if let parameterSelect = source as? Payments.ParameterSelectSimple, let selectedOptionId = selectedOptionId, let selectedOption = parameterSelect.options.first(where: { $0.id == selectedOptionId })  {
                        
                        self.content = selectedOption.name
                        self.description = parameterSelect.description
                        
                    } else {
                        
                        self.content = "Выберите услугу"
                        self.description = nil
                    }
                }
                .store(in: &bindings)
            
            $value
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] value in
                    
                    selectedOptionId = value.current
                }
                .store(in: &bindings)
        }
    }
    
    enum ViewModelAction {
        
        struct SelectOptionExternal: Action {}
    }
}

//MARK: - View

struct PaymentsSelectSimpleView: View {
    
    @ObservedObject var viewModel: PaymentsSelectSimpleView.ViewModel
    
    var body: some View {
        
        if viewModel.isEditable == true {
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text(viewModel.title)
                    .font(Font.custom("Inter-Regular", size: 12))
                    .foregroundColor(Color(hex: "#999999"))
                    .padding(.leading, 48)
                
                HStack(spacing: 16) {
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 32, height: 32)
                    
                    Text(viewModel.content)
                        .font(Font.custom("Inter-Medium", size: 14))
                        .foregroundColor(Color(hex: "#1C1C1C"))
                    
                    Spacer()
                    
                    Image("chevron-downnew")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                
                if let description = viewModel.description {
                    
                    Text(description)
                        .font(Font.custom("Inter-Medium", size: 14))
                        .foregroundColor(Color(hex: "#999999"))
                        .padding(.leading, 48)
                        .padding(.trailing, 28)
                }
                
                Divider()
                    .frame(height: 1)
                    .background(Color(hex: "#EAEBEB"))
                    .padding(.top, 12)
                    .padding(.leading, 48)
                
            }
            .onTapGesture {
                
                viewModel.action.send(ViewModelAction.SelectOptionExternal())
            }
            
        } else {
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text(viewModel.title)
                    .font(Font.custom("Inter-Regular", size: 12))
                    .foregroundColor(Color(hex: "#999999"))
                    .padding(.leading, 48)
                
                HStack(spacing: 16) {
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 32, height: 32)
                    
                    Text(viewModel.content)
                        .font(Font.custom("Inter-Medium", size: 14))
                        .foregroundColor(Color(hex: "#1C1C1C"))
                    
                    Spacer()
                }
                
                if let description = viewModel.description {
                    
                    Text(description)
                        .font(Font.custom("Inter-Medium", size: 14))
                        .foregroundColor(Color(hex: "#999999"))
                        .padding(.leading, 48)
                        .padding(.trailing, 28)
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
    
    
    static let sampleSelected = try! PaymentsSelectSimpleView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "0"), icon: .init(with: UIImage(named: "Payments List Sample")!)!, title: "Тип услуги", selectionTitle: "Выберите услугу", description: "Государственная пошлина за выдачу паспорта удостоверяющего личность гражданина РФ за пределами территории РФ гражданину РФ", options: [.init(id: "0", name: "В возрасте до 14 лет (новый образец)")]))
    
    static let sampleSelectedNotEditable = try! PaymentsSelectSimpleView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "0"), icon: .init(with: UIImage(named: "Payments List Sample")!)!, title: "Тип услуги", selectionTitle: "Выберите услугу", description: "Государственная пошлина за выдачу паспорта удостоверяющего личность гражданина РФ за пределами территории РФ гражданину РФ", options: [.init(id: "0", name: "В возрасте до 14 лет (новый образец)")], editable: false))
}

