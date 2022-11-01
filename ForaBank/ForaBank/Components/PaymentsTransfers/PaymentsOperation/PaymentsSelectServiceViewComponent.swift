//
//  PaymentsSelectServiceViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 08.02.2022.
//

import SwiftUI

//MARK: - ViewModel

extension PaymentsSelectServiceView {
    
    class ViewModel: PaymentsParameterViewModel {

        @Published var items: [ItemViewModel]
        
        init(items: [ItemViewModel], source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.items = items
            super.init(source: source)
        }
        
        init(with parameter: Payments.ParameterSelectService, action: @escaping (Payments.Service) -> Void) {
            
            self.items = parameter.options.map { ItemViewModel(with: $0, action: { itemId in action(itemId) })}
            super.init(source: parameter)
        }
                
        struct ItemViewModel: Identifiable {
           
            let id: Payments.ParameterSelectService.Option.ID
            let icon: Image
            let title: String
            let subTitle: String
            let service: Payments.Service
            let action: (Payments.Service) -> Void
            
            static let iconPlaceholder = Image("Payments Icon Placeholder")
            
            init(id: Payments.ParameterSelectService.Option.ID, icon: Image, title: String, subTitle: String, service: Payments.Service, action: @escaping (Payments.Service) -> Void) {
                
                self.id = id
                self.icon = icon
                self.title = title
                self.subTitle = subTitle
                self.service = service
                self.action = action
            }
            
            init(with option: Payments.ParameterSelectService.Option, action: @escaping (Payments.Service) -> Void) {
                
                self.init(id: option.id, icon: option.icon.image ?? Self.iconPlaceholder, title: option.title, subTitle: option.description, service: option.service, action: action)
            }
        }
    }
}

//MARK: - View

struct PaymentsSelectServiceView: View {
    
    let viewModel: PaymentsSelectServiceView.ViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ForEach(viewModel.items) { itemViewModel in
                
                ItemView(viewModel: itemViewModel)
                    .frame(height: 56)
            }
        }
    }
    
    struct ItemView: View {
        
        let viewModel: PaymentsSelectServiceView.ViewModel.ItemViewModel
        
        var body: some View {
            
            Button {
                
                viewModel.action(viewModel.service)
                
            } label: {
                
                HStack(spacing: 20) {
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 40, height: 40)

                    VStack(alignment: .leading, spacing: 8)  {
                        
                        Text(viewModel.title)
                            .font(Font.custom("Inter-Medium", size: 16))
                            .foregroundColor(Color(hex: "#1C1C1C"))
                        
                        Text(viewModel.subTitle)
                            .font(Font.custom("Inter-Regular", size: 12))
                            .foregroundColor(Color(hex: "#999999"))
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

//MARK: - Preview

struct PaymentsSelectServiceView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsSelectServiceView(viewModel: .samplePlaceholder)
            .previewLayout(.fixed(width: 375, height: 56 * 4))
            .padding(.horizontal, 20)
    }
}

//MARK: - Preview Content

extension PaymentsSelectServiceView.ViewModel {
    
    static let samplePlaceholder = PaymentsSelectServiceView.ViewModel(with: .init(category: .taxes, options: [.init(service: .fns, title: "ФНС", description: "Налоги", icon: ImageData(with: UIImage(named: "Payments Service Sample")!)!)]), action: { _ in })
}
