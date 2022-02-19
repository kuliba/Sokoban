//
//  PaymentsOperationViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 16.02.2022.
//

import SwiftUI
import Combine

class PaymentsParameterViewModel: Identifiable, ObservableObject {
    
}

class PaymentsOperationViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    private var bindings = Set<AnyCancellable>()
    private let model: Model
    private let category: Payments.Category
    
    @Published var items: [PaymentsParameterViewModel]
    @Published var header: HeaderViewModel?
    
    internal init(model: Model,
                  category: Payments.Category,
                  items: [PaymentsParameterViewModel],
                  header: HeaderViewModel?) {
        self.model = model
        self.category = category
        self.items = items
        self.header = header
        bind()
    }
    
    internal init(model: Model, category: Payments.Category, service: Payments.Service, isPaymentViewActive: Bool) {
        self.model = model
        self.items = []
        self.category = category
        bind()
        model.action.send(ModelAction.Payment.Begin.Request(source: .service(service), currency: .init(description: "")))
        
    }
    
    func convert( parameters: [Payments.Parameter]) -> [PaymentsParameterViewModel] {
        var result = [PaymentsParameterViewModel]()
        for parameter in parameters {
            switch parameter.type {
            case .select(let options, icon: let iconData, title: let title):
                result.append( PaymentsTaxesSelectCellView.ViewModel(items: [.init(logo: Image(uiImage: UIImage(data: iconData.data) ?? UIImage()), title: options.description, action: { action in
                    print("PaymentsTaxesSelectCellView")
                })], selectedItemTitle: title))
            case .hidden:
                print()
            case .selectSimple(_, icon: let icon, title: let title, selectionTitle: let selectionTitle, description: let description):
                result.append(PaymentsTaxesButtonInfoCellView.ViewModel(icon: Image(uiImage: UIImage(data: icon.data) ?? UIImage()), title: title, subTitle: selectionTitle, action: { action in
                    print("PaymentsTaxesButtonInfoCellView")
                }))
            case .selectSwitch(let options):
                if !options.isEmpty {
                result.append(PaymentsTaxesParameterSwitchViewModel(options: options, selected: options.first!.id))
                }
            case .input(icon: let icon, title: let title, validator: let validator):
                result.append(PaymentsTaxesInputCellView.ViewModel(logo: Image(uiImage: UIImage(data: icon.data) ?? UIImage()), title: title, placeholder: "zxczxc", action: { action in
                    print("PaymentsTaxesInputCellView")
                }))
            case .info(icon: let icon, title: let title):
                result.append(PaymentsTaxesInfoCellViewComponent.ViewModel(icon: Image(uiImage: UIImage(data: icon.data) ?? UIImage()), content: "PaymentsTaxesInfoCellViewComponent", description: title))
            case .name(icon: let icon, title: let title):
                result.append(PaymentsParameterFullNameView.ViewModel(value: title, icon: Image(uiImage: UIImage(data: icon.data) ?? UIImage())))
            case .amount(title: let title, validator: let validator):
                print()
            case .card:
                //result.append(PaymentsTaxesSelectCardView)
                print()
            }
        }
        return result
    }
    
    class HeaderViewModel: ObservableObject {
        
        var title: String
        
        internal init(title: String) {
            
            self.title = title
        }
    }
    
    func bind() {
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case let payload as ModelAction.Payment.Begin.Response:
                    
                    switch payload.result {
                    case .success(let operation):
                        items = convert(parameters: operation.parameters)
                    case .failure(let error):
                        print(error)
                    }
                    
                    
                    
                default: break
                }
 
            }.store(in: &bindings)
        
    }
    
}
