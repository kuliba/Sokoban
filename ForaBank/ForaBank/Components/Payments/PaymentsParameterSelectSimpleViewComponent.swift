//
//  PaymentsParameterSelectSimpleViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsParameterSelectSimpleView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        let icon: Image
        let title: String
        
        @Published var content: String
        @Published var description: String?
        @Published var selectedOptionId: Payments.ParameterSelectSimple.Option.ID?
        
        let action: () -> Void
        
        //TODO: real placeholder required
        private static let iconPlaceholder = Image("Payments Icon Placeholder")
        private var bindings: Set<AnyCancellable> = []
        
        internal init(icon: Image,
                      title: String,
                      content: String,
                      description: String?,
                      selectedOptionId: Payments.ParameterSelectSimple.Option.ID? = nil,
                      action: @escaping () -> Void) {
            
            self.icon = icon
            self.title = title
            self.content = content
            self.description = description
            self.selectedOptionId = selectedOptionId
            self.action = action
            super.init(source: Payments.ParameterMock())
        }
        
        init(with parameterSelect: Payments.ParameterSelectSimple, action: @escaping () -> Void) throws {
            
            self.icon = parameterSelect.icon.image ?? Self.iconPlaceholder
            self.title = parameterSelect.title
            self.content = parameterSelect.selectionTitle
            self.description = parameterSelect.description
            self.selectedOptionId = parameterSelect.parameter.value
            self.action = action
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
        
        enum ViewModelAction {
            
            struct ItemSelected: Action {
                
                let itemId: Option.ID
            }
        }
    }
    
}

//MARK: - View

struct PaymentsParameterSelectSimpleView: View {
    
    @ObservedObject var viewModel: PaymentsParameterSelectSimpleView.ViewModel
    
    var body: some View {
        
        HStack(alignment: .top) {
            
            viewModel.icon
                .resizable()
                .frame(width: 24, height: 24)
                .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 4) {
                
                HStack(alignment: .top) {
                    
                    VStack(alignment: .leading, spacing: 0)  {
                        
                        Text(viewModel.title)
                            .font(Font.custom("Inter-Regular", size: 12))
                            .foregroundColor(Color(hex: "#999999"))
                            .padding(.bottom, 4)
                        Text(viewModel.content)
                            .font(Font.custom("Inter-Medium", size: 14))
                            .foregroundColor(Color(hex: "#1C1C1C"))
                        if let description = viewModel.description {
                        Text(description)
                            .font(Font.custom("Inter-Medium", size: 14))
                            .foregroundColor(Color(hex: "#999999"))
                        }
                    } .padding()
                    Spacer()
                    Image("chevron-downnew")
                        .padding()
                        .padding(.top, 10)
                }
                Divider()
                    .background(Color(hex: "#EAEBEB"))
                    .padding(.top, 1)
            }
        }.onTapGesture {
            viewModel.action()
        }
    }
}

//MARK: - Preview

struct PaymentsParameterSelectSimpleView_Previews: PreviewProvider {
    
    static var previews: some View {
        
    Group {
            PaymentsParameterSelectSimpleView(viewModel:.sample)
                .previewLayout(.fixed(width: 375, height: 80))
            
            PaymentsParameterSelectSimpleView(viewModel:.selectedSimple_1)
                .previewLayout(.fixed(width: 375, height: 200))
        }
    }
}

//MARK: - Preview Content

extension PaymentsParameterSelectSimpleView.ViewModel {
    
    static let sample = PaymentsParameterSelectSimpleView.ViewModel(icon: Image("Payments List Sample"), title: "Тип услуги", content: "Выберите услугу", description: nil, action: { } )
    
    static let selectedSimple_1 = PaymentsParameterSelectSimpleView.ViewModel(
        icon: Image("Payments List Sample"),
        title: "Тип услуги",
        content: "В возрасте до 14 лет (новый образец)",
        description: "Государственная пошлина за выдачу паспорта удостоверяющего личность гражданина РФ за пределами территории РФ гражданину РФ",
        selectedOptionId: "0", action: { } )
    
}

