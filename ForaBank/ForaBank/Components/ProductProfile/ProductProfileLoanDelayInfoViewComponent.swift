//
//  ProductProfileLoanDelayInfoView.swift
//  ForaBank
//
//  Created by Дмитрий on 30.03.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension ProductProfileLoanDelayInfoView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        private var bindings = Set<AnyCancellable>()
        
        var title = "Просрочка"
        var subTitle = "Перед погашением уточняйте сумму просроченной задолженности в банке."
        var buttonTitle = "Связаться с банком"
        
        init() {
            
            bind()
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [weak self] action in
                    switch action {
                    case _ as ProductProfileLoanDelayInfoView.ViewModelAction.Dismiss:
                        
                        if let phoneCallURL = URL(string: "telprompt://\("88001009889")") {

                            let application:UIApplication = UIApplication.shared
                            if (application.canOpenURL(phoneCallURL)) {
                                application.open(phoneCallURL, options: [:], completionHandler: nil)
                            }
                        }
                        
                    default:
                        break

                    }
                    
                }.store(in: &bindings)
        }
        
    }
    
    enum ViewModelAction {
        
        struct Dismiss: Action {}
    }
}

//MARK: - View

struct ProductProfileLoanDelayInfoView: View {
    
    let viewModel: ProductProfileLoanDelayInfoView.ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 45) {
            
            VStack(alignment: .leading, spacing: 20) {
                
                Text(viewModel.title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.mainColorsBlack)
                
                Text(viewModel.subTitle)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.mainColorsBlack)
                    .padding(.trailing, 20)
                
            }
            
            Button(viewModel.buttonTitle) {
                
                viewModel.action.send(ProductProfileLoanDelayInfoView.ViewModelAction.Dismiss())
                
            }
            .frame(height: 47, alignment: .center)
            .frame(minWidth: 200, maxWidth: .infinity)
            .background(Color.buttonPrimary)
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .cornerRadius(8)
            
        }
        .transition(.scale)
        .edgesIgnoringSafeArea(.bottom)
        .padding(20)
        .background(Color.white)
    }
}

//MARK: - Preview

struct ProductProfileLoanDelayInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ProductProfileLoanDelayInfoView(viewModel: .init())
            .previewLayout(.fixed(width: 360, height: 250))
    }
}
