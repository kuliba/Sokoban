//
//  PaymentsServiceViewModel.swift
//  Vortex
//
//  Created by Константин Савялов on 15.02.2022.
//

import SwiftUI
import Combine

class PaymentsServiceViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var navigationBar: NavigationBarView.ViewModel
    @Published var content: [PaymentsParameterViewModel]
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    
    var rootActions: PaymentsViewModel.RootActions?
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(navigationBar: NavigationBarView.ViewModel, content: [PaymentsParameterViewModel], link: Link?, model: Model) {
        
        self.navigationBar = navigationBar
        self.content = content
        self.link = link
        self.model = model
    }
    
    convenience init(category: Payments.Category, parameters: [PaymentsParameterRepresentable], model: Model, closeAction: @escaping () -> Void) {
        
        let navigationBar = NavigationBarView.ViewModel(title: category.name, leftItems: [NavigationBarView.ViewModel.BackButtonItemViewModel(action: closeAction)])
        self.init(navigationBar: navigationBar, content: [], link: nil, model: model)
        
        content = Self.reduce(parameters: parameters, action: { [weak self] in
            
            { service in self?.action.send(PaymentsServiceViewModelAction.ServiceSelected(service: service)) }
        })
        
        LoggerAgent.shared.log(category: .ui, message: "Service selection started for category: \(category)")
        
        bind()
    }

    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as PaymentsServiceViewModelAction.ServiceSelected:
                    rootActions?.spinner.show()
                    
                    Task {

                      do {
                          
                          let operation = try await requestOperation(for: payload.service)
                          
                          await MainActor.run {
                              
                              self.rootActions?.spinner.hide()
                              
                              let operationViewModel = PaymentsOperationViewModel(operation: operation, model: model){ [weak self] in
                                  self?.action.send(PaymentsServiceViewModelAction.DissmissLink())
                              }
                              operationViewModel.rootActions = rootActions
                              link = .operation(operationViewModel)
                          }
                          
                      } catch {
                          
                          await MainActor.run {
                              
                              self.rootActions?.spinner.hide()
                              self.rootActions?.alert(error.localizedDescription)
                          }
                      }
                    }
                    
                case _ as PaymentsServiceViewModelAction.DissmissLink:
                    link = nil
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

//MARK: - Helpers

extension PaymentsServiceViewModel {
    
    func requestOperation(for service: Payments.Service) async throws -> Payments.Operation {
        
      #if DEBUG
      if let mock = model.paymentsMock(for: service) {
          
          return try await model.paymentsOperation(with: .mock(mock))
          
      } else {
          
          return try await model.paymentsOperation(with: service)
      }
      #else
      return try await model.paymentsOperation(with: service)
      #endif
    }
}

//MARK: - Reducers

extension PaymentsServiceViewModel {
    
    static func reduce(parameters: [PaymentsParameterRepresentable], action: @escaping () -> (Payments.Service) -> Void) -> [PaymentsParameterViewModel] {
        
        var result = [PaymentsParameterViewModel]()
        
        for parameter in parameters {
            
            switch parameter {
            case let serviceSelectParameter as Payments.ParameterSelectService:
                let serviceSelectParameterViewModel = PaymentsSelectServiceView.ViewModel(with: serviceSelectParameter, action: action())
                result.append(serviceSelectParameterViewModel)

            default:
                continue
            }
        }
        
        return result
    }
}

//MARK: - Types

extension PaymentsServiceViewModel {
    
    enum Link {
        
        case operation(PaymentsOperationViewModel)
    }
}

//MARK: - Action

enum PaymentsServiceViewModelAction {
    
    struct ServiceSelected: Action {
        
        let service: Payments.Service
    }
    
    struct DissmissLink: Action {}
}

