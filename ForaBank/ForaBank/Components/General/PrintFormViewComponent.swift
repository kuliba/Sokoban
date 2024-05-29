//
//  PrintFormViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 04.07.2022.
//

import SwiftUI
import PDFKit
import Combine

extension PrintFormView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var state: State
        @Published var sheet: Sheet?
        @Published var alert: Alert.ViewModel?
        let dismissAction: (() -> Void)?
        private let decodeResponse: (Data) -> String? = { data in
            
            try? JSONDecoder().decode(ResponseMapper.ServerResponse<Data>.self, from: data).errorMessage
        }
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        enum Kind {
            
            case operation(paymentOperationDetailId: Int, printFormType: PrintFormType)
            case product(productId: ProductData.ID, startDate: Date, endDate: Date)
            case contract(productId: ProductData.ID)
            case closeAccount(id: ProductData.ID, paymentOperationDetailId: Int)
            case closeAccountEmpty(id: ProductData.ID)
        }
        
        enum State {
            
            case document(PDFDocument, ButtonSimpleView.ViewModel)
            case loading
            case failed
        }
        
        struct Sheet: Identifiable, Equatable {

            let id = UUID()
            let type: Kind
            
            enum Kind {
                case activity(ActivityView.ViewModel)
            }
            
            static func == (lhs: PrintFormView.ViewModel.Sheet, rhs: PrintFormView.ViewModel.Sheet) -> Bool {
                lhs.id == rhs.id
            }
        }
        
        init(state: State, model: Model = .emptyMock, dismissAction: (() -> Void)? = nil) {
            
            self.state = state
            self.model = model
            self.dismissAction = dismissAction
        }
        
        init(type: Kind, model: Model, dismissAction: (() -> Void)? = nil) {
            
            self.state = .loading
            self.model = model
            self.dismissAction = dismissAction
            
            bind()
            
            switch type {
            case let .operation(paymentOperationDetailId, printFormType):
                model.action.send(ModelAction.PrintForm.Request(paymentOperationDetailId: paymentOperationDetailId, printFormType: printFormType))
                
            case let .product(productId, startDate, endDate):
                model.action.send(ModelAction.Products.StatementPrintForm.Request(productId: productId, startDate: startDate, endDate: endDate))
                
            case let .contract(productId):
                model.action.send(ModelAction.Products.ContractPrintForm.Request(depositId: productId))
                
            case let .closeAccount(id: productId, paymentOperationDetailId: paymentOperationDetailId):
                model.action.send(ModelAction.Account.CloseAccount.PrintForm.Request(id: productId, paymentOperationDetailId: paymentOperationDetailId))
                
            case let .closeAccountEmpty(id: productId):
                model.action.send(ModelAction.Account.CloseAccount.PrintForm.Request(id: productId, paymentOperationDetailId: nil))
            }
        }
        
        convenience init(pdfDocument: PDFDocument, dismissAction: (() -> Void)? = nil) {
            
            let activityViewModel = ActivityView.ViewModel(activityItems: [pdfDocument.dataRepresentation() as Any])
            let state: State = .loading
            self.init(state: state, dismissAction: dismissAction)
            let button = ButtonSimpleView.ViewModel(
                title: "Сохранить или отправить",
                style: .red,
                action: { [weak self] in
                    
                    self?.action.send(PrintFormViewModelAction.ShowActivity(activityViewModel: activityViewModel))
                    
                })
            self.state = .document(pdfDocument, button)
        }
        
        private func handlePDFResult(_ pdfResult: ModelAction.Products.StatementPrintForm.Response.PDFResult) {
            
            switch pdfResult {
            case let .success(document):
                let activityViewModel = ActivityView.ViewModel(activityItems: [document.dataRepresentation() as Any])
                let button = ButtonSimpleView.ViewModel(
                    title: "Сохранить или отправить",
                    style: .red,
                    action: { [weak self] in
                        
                        self?.action.send(PrintFormViewModelAction.ShowActivity(activityViewModel: activityViewModel))
                    })
                
                withAnimation {
                    self.state = .document(document, button)
                }
                
            case let .failure(.serverError(message)):
                withAnimation {
                    self.state = .failed
                }
                
                self.alert = .init(
                    title: "Информация",
                    message: message,
                    primary: .init(
                        type: .cancel,
                        title: "ОК",
                        action: { [weak self] in
                            self?.dismissAction?()
                        }))
                
            case .failure(.failure):
                withAnimation {
                    self.state = .failed
                }
            }
        }
        
        func bind() {
            
            model.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as ModelAction.PrintForm.Response:
                        switch payload.result {
                        case .success(let data):
                            if let document = PDFDocument(data: data) {
                                
                                let activityViewModel = ActivityView.ViewModel(activityItems: [document.dataRepresentation() as Any])
                                let button = ButtonSimpleView.ViewModel(
                                    title: "Сохранить или отправить",
                                    style: .red,
                                    action: { [weak self] in
                                        
                                        self?.action.send(PrintFormViewModelAction.ShowActivity(activityViewModel: activityViewModel))
                                        
                                    })
                                withAnimation {
                                    self.state = .document(document, button)
                                }
                                
                            } else {
                                
                                withAnimation {
                                    self.state = .failed
                                }
                            }
                            
                        case .failure(let error):
                            withAnimation {
                                self.state = .failed
                            }
                            //TODO: show alert with error message
                        }
                        
                    case let payload as ModelAction.Products.ContractPrintForm.Response:
                        switch payload.result {
                        case .success(let data):
                            if let document = PDFDocument(data: data) {
                                
                                let activityViewModel = ActivityView.ViewModel(activityItems: [document.dataRepresentation() as Any])
                                let button = ButtonSimpleView.ViewModel(
                                    title: "Сохранить или отправить",
                                    style: .red,
                                    action: { [weak self] in
                                        
                                        self?.action.send(PrintFormViewModelAction.ShowActivity(activityViewModel: activityViewModel))
                                        
                                    })
                                withAnimation {
                                    self.state = .document(document, button)
                                }
                                
                            } else {
                                
                                withAnimation {
                                    
                                    self.state = .failed
                                    self.dismissAction?()
                                }
                            }
                            
                        case .failure(let error):
                            withAnimation {
                                
                                self.state = .failed

                            }
                        }
                        
                    case let payload as ModelAction.Products.StatementPrintForm.Response:
                        
                        handlePDFResult(payload.pdfResult(decodeResponse))
                                                
                    case let payload as ModelAction.Account.CloseAccount.PrintForm.Response:
                        
                        switch payload.result {
                        case let .success(data):
                            
                            if let document = PDFDocument(data: data) {
                                
                                let activityViewModel = ActivityView.ViewModel(activityItems: [document.dataRepresentation() as Any])
                                let button = ButtonSimpleView.ViewModel(
                                    title: "Сохранить или отправить",
                                    style: .red,
                                    action: { [weak self] in
                                        
                                    self?.action.send(PrintFormViewModelAction.ShowActivity(activityViewModel: activityViewModel))
                                })
                                
                                withAnimation {
                                    self.state = .document(document, button)
                                }
                                
                            } else {
                                
                                withAnimation {
                                    self.state = .failed
                                }
                            }
                            
                        case .failure:
                            
                            withAnimation {
                                self.state = .failed
                            }
                        }
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as PrintFormViewModelAction.ShowActivity:
                        sheet = .init(type: .activity(payload.activityViewModel))
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

private extension ModelAction.Products.StatementPrintForm.Response {
    
    func pdfResult(
        _ decode: @escaping (Data) -> String?
    ) -> PDFResult {
        
        switch result {
        case let .success(data):
            if let document = PDFDocument(data: data) {
                return .success(document)
            } else {
                if let message = decode(data) {
                    return .failure(.serverError(message))
                } else {
                    return .failure(.failure)
                }
            }
            
        case .failure:
            return .failure(.failure)
        }
    }
        
    typealias PDFResult = Result<PDFDocument, ServiceFailure>
}

private enum ServiceFailure: Error {
    
    case failure
    case serverError(String)
}

enum PrintFormViewModelAction {

    struct ShowActivity: Action {
        
        let activityViewModel: ActivityView.ViewModel
    }
}

struct PrintFormView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        Group {
            
            switch viewModel.state {
            case .document(let document, let button):
                VStack {
                    
                    PDFDocumentView(document: document)
                    ButtonSimpleView(viewModel: button)
                        .frame(height: 48)
                        .padding()
                }
                .sheet(item: $viewModel.sheet) { item in
                    
                    switch item.type {
                    case .activity(let activityViewModel):
                        ActivityView(viewModel: activityViewModel)
                    }
                }
                
            case .loading:
                SpinnerRefreshView(icon: .init("Logo Fora Bank"))
                
            case .failed:
                Text("Не удалось загрузить документ")
                    .alert(item: $viewModel.alert, content: Alert.init(with:))
            }
        }
    }
}

struct PrintFormViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        PrintFormView(viewModel: .sample)
    }
}

//MARK: - Sample Data

extension PrintFormView.ViewModel {
    
    static let sample = PrintFormView.ViewModel(
        state: .document(
            .sample,
            .init(
                title: "Сохранить или отправить",
                style: .red,
                action: {}
            )
        ),
        dismissAction: {}
    )
}
