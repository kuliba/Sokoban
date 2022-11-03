//
//  PaymentsServiceViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.02.2022.
//

import SwiftUI
import Combine

class PaymentsServiceViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let header: HeaderViewModel
    @Published var content: [PaymentsParameterViewModel]
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(header: HeaderViewModel, content: [PaymentsParameterViewModel], link: Link?, model: Model) {
        
        self.header = header
        self.content = content
        self.link = link
        self.model = model
    }
    
    convenience init(category: Payments.Category, parameters: [PaymentsParameterRepresentable], model: Model) {
        
        let header = HeaderViewModel(title: category.name)
        self.init(header: header, content: [], link: nil, model: model)
        
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
                    
#if DEBUG
                    
                    if let mock = model.paymentsMock(for: payload.service) {
                        
                        Task {
                            
                            do {
                                
                                let operation = try await model.paymentsOperation(with: .mock(mock))
                                
                                await MainActor.run {
                                    
                                    let operationViewModel = PaymentsOperationViewModel(operation: operation, model: model)
                                    link = .operation(operationViewModel)
                                    
                                    bind(operationViewModel: operationViewModel)
                                }
                                
                            } catch {
                                
                                await MainActor.run {
                                    
                                    self.action.send(PaymentsServiceViewModelAction.Alert(message: error.localizedDescription))
                                }
                            }
                        }
                        
                    } else {
                        
                        Task {
                            
                            do {
                                
                                let operation = try await model.paymentsOperation(with: payload.service)
                                
                                await MainActor.run {
                                    
                                    let operationViewModel = PaymentsOperationViewModel(operation: operation, model: model)
                                    link = .operation(operationViewModel)
                                    
                                    bind(operationViewModel: operationViewModel)
                                }
                                
                            } catch {
                                
                                await MainActor.run {
                                    
                                    self.action.send(PaymentsServiceViewModelAction.Alert(message: error.localizedDescription))
                                }
                            }
                        }
                    }
                    
#else
                    Task {
                        
                        do {
                            
                            let operation = try await model.paymentsOperation(with: payload.service)
                            
                            await MainActor.run {
                                
                                let operationViewModel = PaymentsOperationViewModel(operation: operation, model: model)
                                link = .operation(operationViewModel)
                                
                                bind(operationViewModel: operationViewModel)
                            }
                            
                        } catch {
                            
                            await MainActor.run {
                                
                                self.action.send(PaymentsServiceViewModelAction.Alert(message: error.localizedDescription))
                            }
                        }
                    }
#endif
                    
                    
                    
                case _ as PaymentsServiceViewModelAction.DissmissLink:
                    link = nil
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(operationViewModel: PaymentsOperationViewModel) {
        
        operationViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsOperationViewModelAction.Dismiss:
                    self.action.send(PaymentsServiceViewModelAction.Dismiss())
                    
                case _ as PaymentsOperationViewModelAction.Spinner.Show:
                    self.action.send(PaymentsServiceViewModelAction.Spinner.Show())
                    
                case _ as PaymentsOperationViewModelAction.Spinner.Hide:
                    self.action.send(PaymentsServiceViewModelAction.Spinner.Hide())
                    
                case let payload as PaymentsOperationViewModelAction.Alert:
                    self.action.send(PaymentsServiceViewModelAction.Alert(message: payload.message))
   
                default:
                    break
                }
                
            }.store(in: &bindings)
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
    
    struct HeaderViewModel {
        
        let title: String
    }
    
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
    
    struct Dismiss: Action {}
    
    enum Spinner {
        
        struct Show: Action {}
        struct Hide: Action {}
    }
    
    struct Alert: Action {
        
        let message: String
    }
}

