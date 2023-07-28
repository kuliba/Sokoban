//
//  PaymentsSuccessViewModelAdapter.swift
//  ForaBank
//
//  Created by Max Gribov on 25.06.2023.
//

import Combine
//TODO: extract AnySchedulerOfDispatchQueue into a separate module
import TextFieldModel

class PaymentsSuccessViewModelAdapter {
    
    typealias SectionsMapper = (Payments.Success, Model) -> [PaymentsSectionViewModel]
    
    private let model: Model
    private let mapper: SectionsMapper
    private let scheduler: AnySchedulerOfDispatchQueue
    private var bindings = Set<AnyCancellable>()
    
    typealias OperationDetailResponseHandler = (Result<OperationDetailData, ModelError>) -> Void
    var operationDetailResponseHandler: OperationDetailResponseHandler?
    
    typealias SubscribtionResponseHandler = (Result<Payments.Success, Error>) -> Void
    var subscribtionResponseHandler: SubscribtionResponseHandler?
    
    init(
        model: Model,
        mapper: @escaping SectionsMapper = PaymentsSectionViewModel.reduce(success:model:),
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        
        self.model = model
        self.mapper = mapper
        self.scheduler = scheduler
        bind()
    }
    
    private func bind() {
        
        // ModelAction.Operation.Detail.Response
        model.action
            .compactMap { $0 as? ModelAction.Operation.Detail.Response }
            .map(\.result)
            .receive(on: scheduler)
            .sink { [unowned self] result in
                
                operationDetailResponseHandler?(result)
                
            }.store(in: &bindings)
        
        // ModelAction.Payment.Subscribtion.Response
        model.action
            .compactMap( { $0 as? ModelAction.Payment.Subscribtion.Response })
            .map(\.result)
            .receive(on: scheduler)
            .sink { [unowned self] result in
                
               subscribtionResponseHandler?(result)
                
            }.store(in: &bindings)
    }
    
    //MARK: - Requests
    
    func requestOperationDetail(with paymentOperationDetailID: Int) {
        
        model.action.send(ModelAction.Operation.Detail.Request(type: .paymentOperationDetailId(paymentOperationDetailID)))
    }
    
    func requestSubscribtion(parameters: [PaymentsParameterRepresentable], action: ModelAction.Payment.Subscribtion.Request.SubscribtionAction) {
        
        model.action.send(ModelAction.Payment.Subscribtion.Request(parameters: parameters, action: action))
    }
    
    //MARK: - View Models Helpers
    
    func makePaymentSuccessViewModel(with success: Payments.Success) -> PaymentsSuccessViewModel {
        
        .init(paymentSuccess: success, model)
    }
    
    func makePrintFormViewModel(type: PrintFormView.ViewModel.Kind) -> PrintFormView.ViewModel {
        
        .init(type: type, model: model)
    }
    
    func makeOpetationDetailInfoViewModel(operationDetailData: OperationDetailData, dissmissAction: @escaping () -> Void) -> OperationDetailInfoViewModel {
        
        .init(model: model, operation: operationDetailData, dismissAction: dissmissAction)
    }
    
    func makeSections(_ success: Payments.Success) -> [PaymentsSectionViewModel]  {
        
        mapper(success, model)
    }
    
    //MARK: - Models Helpers
    
    func product(productId: ProductData.ID) -> ProductData? {
        
        model.product(productId: productId)
    }
    
    func amountFormatted(amount: Double, currencyCode: String, style: Model.AmountFormatStyle) -> String? {
        
        model.amountFormatted(amount: amount, currencyCode: currencyCode, style: style)
    }
    
    func updateProducts() {
        
        model.action.send(ModelAction.Products.Update.Total.All())
    }
    
    //MARK: - Other Helpers
    
    func showInformer(_ informer: InformerData) {
        
        model.action.send(ModelAction.Informer.Show(informer: informer))
    }
}
