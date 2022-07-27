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

        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        
        enum Kind {
            
            case operation(paymentOperationDetailId: Int, printFormType: PrintFormType)
            case product(productId: ProductData.ID, startDate: Date, endDate: Date)
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
        
        init(state: State, model: Model = .emptyMock) {
            
            self.state = state
            self.model = model
        }
        
        init(type: Kind, model: Model) {
            
            self.state = .loading
            self.model = model
            
            bind()
            
            switch type {
            case let .operation(paymentOperationDetailId, printFormType):
                model.action.send(ModelAction.PrintForm.Request(paymentOperationDetailId: paymentOperationDetailId, printFormType: printFormType))
                
            case let .product(productId, startDate, endDate):
                model.action.send(ModelAction.Products.StatementPrintForm.Request(productId: productId, startDate: startDate, endDate: endDate))
            }
        }
        
        convenience init(pdfDocument: PDFDocument) {
            
            let activityViewModel = ActivityView.ViewModel(activityItems: [pdfDocument.dataRepresentation() as Any])
            let state: State = .loading
            self.init(state: state)
            let button = ButtonSimpleView.ViewModel(title: "Сохранить или отправить", style: .red, action: {[weak self] in self?.action.send(PrintFormViewModelAction.ShowActivity(activityViewModel: activityViewModel))})
            self.state = .document(pdfDocument, button)
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
                                let button = ButtonSimpleView.ViewModel(title: "Сохранить или отправить", style: .red, action: {[weak self] in self?.action.send(PrintFormViewModelAction.ShowActivity(activityViewModel: activityViewModel))})
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
                        
                    case let payload as ModelAction.Products.StatementPrintForm.Response:
                        switch payload.result {
                        case .success(let data):
                            if let document = PDFDocument(data: data) {
                                
                                let activityViewModel = ActivityView.ViewModel(activityItems: [document.dataRepresentation() as Any])
                                let button = ButtonSimpleView.ViewModel(title: "Сохранить или отправить", style: .red, action: {[weak self] in self?.action.send(PrintFormViewModelAction.ShowActivity(activityViewModel: activityViewModel))})
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

enum PrintFormViewModelAction {

    struct ShowActivity: Action {
        
        let activityViewModel: ActivityView.ViewModel
    }
}

struct PrintFormView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
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
            Text("Failed")
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
    
    static let sample = PrintFormView.ViewModel(state: .document(.sample, .init(title: "Сохранить или отправить", style: .red, action: {})))
}
