//
//  QRNavigationComposerMicroServicesComposer.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.10.2024.
//

import CombineSchedulers
import ForaTools
import Foundation
import SberQR

final class QRNavigationComposerMicroServicesComposer {
    
    private let httpClient: HTTPClient
    private let logger: LoggerAgentProtocol
    private let model: Model
    private let createSberQRPayment: CreateSberQRPayment
    private let getSberQRData: GetSberQRData
    private let makeSegmented: MakeSegmented
    private let makeServicePicker: MicroServices.MakeServicePicker
    private let scanner: any QRScannerViewModel
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        httpClient: any HTTPClient,
        logger: any LoggerAgentProtocol,
        model: Model,
        createSberQRPayment: @escaping CreateSberQRPayment,
        getSberQRData: @escaping GetSberQRData,
        // static RootViewModelFactory.makeSegmentedPaymentProviderPickerFlowModel(httpClient:log:model:pageSize:flag:scheduler:)
        makeSegmented: @escaping MakeSegmented,
        // static RootViewModelFactory.makeProviderServicePickerFlowModel(httpClient:log:model:pageSize:flag:scheduler:)
        makeServicePicker: @escaping MicroServices.MakeServicePicker,
        scanner: any QRScannerViewModel,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.httpClient = httpClient
        self.logger = logger
        self.model = model
        self.createSberQRPayment = createSberQRPayment
        self.getSberQRData = getSberQRData
        self.makeSegmented = makeSegmented
        self.makeServicePicker = makeServicePicker
        self.scanner = scanner
        self.scheduler = scheduler
    }
    
    typealias MicroServices = QRNavigationComposerMicroServices
    
    typealias CreateSberQRPayment = (MicroServices.MakeSberPaymentCompletePayload, @escaping (Result<CreateSberQRPaymentResponse, QRNavigation.ErrorMessage>) -> Void) -> Void
    
    typealias MakeSegmented = (MultiElementArray<SegmentedOperatorProvider>, QRCode, QRMapping) -> SegmentedPaymentProviderPickerFlowModel
    
    typealias GetSberQRDataCompletion = (Result<GetSberQRDataResponse, Error>) -> Void
    typealias GetSberQRData = (URL, @escaping GetSberQRDataCompletion) -> Void
}

extension QRNavigationComposerMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            makeInternetTV: makeInternetTV,
            makeOperatorSearch: makeOperatorSearch,
            makePayments: makePayments,
            makeProviderPicker: makeProviderPicker,
            makeQRFailure: makeQRFailure,
            makeQRFailureWithQR: makeQRFailureWithQR,
            makeSberPaymentComplete: makeSberPaymentComplete,
            makeSberQR: makeSberQR,
            makeServicePicker: makeServicePicker
        )
    }
}

private extension QRNavigationComposerMicroServicesComposer {
    
    func makeInternetTV(
        payload: MicroServices.MakeInternetTVPayload,
        completion: @escaping (InternetTVDetailsViewModel) -> Void
    ) {
        completion(.init(model: model, qrCode: payload.0, mapping: payload.1))
    }
    
    func makeOperatorSearch(
        payload: MicroServices.MakeOperatorSearchPayload,
        completion: @escaping (QRNavigation.OperatorSearch) -> Void
    ) {
#warning("need to wrap as ClosePaymentsViewModelWrapper wraps PaymentsViewModel")
        
        let navigationBarViewModel = NavigationBarView.ViewModel(
            title: "Все регионы",
            titleButton: .init(
                icon: .ic24ChevronDown,
                action: { [weak self] in
                    
                    self?.model.action.send(QRSearchOperatorViewModelAction.OpenCityView())
                }
            ),
            leftItems: [
                NavigationBarView.ViewModel.BackButtonItemViewModel(
                    icon: .ic24ChevronLeft,
                    action: payload.dismiss
                )
            ]
        )
        
        let operatorsViewModel = QRSearchOperatorViewModel(
            searchBar: .nameOrTaxCode(),
            navigationBar: navigationBarViewModel, model: self.model,
            operators: payload.multiple.elements.map(\.origin),
            addCompanyAction: payload.chat,
            requisitesAction: payload.detailPayment,
            qrCode: payload.qrCode
        )
        
        completion(operatorsViewModel)
    }
    
    func makePayments(
        payload: MicroServices.MakePaymentsPayload,
        completion: @escaping (ClosePaymentsViewModelWrapper) -> Void
    ) {
        switch payload {
        case let .operationSource(source):
            completion(.init(model: model, source: source, scheduler: scheduler))
            
        case let .qrCode(qrCode):
            completion(.init(model: model, source: .requisites(qrCode: qrCode), scheduler: scheduler))
            
        case let .source(source):
            switch source.type {
            case .c2b:
                completion(.init(model: model, source: .c2b(source.url), scheduler: scheduler))
                
            case .c2bSubscribe:
                completion(.init(model: model, source: .c2bSubscribe(source.url), scheduler: scheduler))
            }
        }
    }
    
    func makeProviderPicker(
        payload: MicroServices.MakeProviderPickerPayload,
        completion: @escaping (SegmentedPaymentProviderPickerFlowModel) -> Void
    ) {
        completion(makeSegmented(payload.mixed, payload.qrCode, payload.qrMapping))
    }
    
    func makeQRFailure(
        payload: MicroServices.MakeQRFailurePayload,
        completion: @escaping (QRFailedViewModel) -> Void
    ) {
        completion(.init(model: model, addCompanyAction: payload.chat, requisitsAction: payload.detailPayment))
    }
    
    func makeQRFailureWithQR(
        payload: MicroServices.MakeQRFailureWithQRPayload,
        completion: @escaping (QRFailedViewModel) -> Void
    ) {
        completion(.init(model: model, addCompanyAction: payload.chat, requisitsAction: { payload.detailPayment(payload.qrCode) }))
    }
    
    func makeSberPaymentComplete(
        payload: MicroServices.MakeSberPaymentCompletePayload,
        completion: @escaping (QRNavigation.PaymentCompleteResult) -> Void
    ) {
        createSberQRPayment(payload) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(success):
                completion(.success(.init(paymentSuccess: success.success, self.model)))
            }
        }
    }
    
    func makeSberQR(
        payload: MicroServices.MakeSberQRPayload,
        completion: @escaping MicroServices.MakeSberQRCompletion
    ) {
        let composer = QRScanResultMapperComposer(model: model)
        let mapper = composer.compose()
        
        getSberQRData(payload.url) { [weak self] in
            
            guard let self else { return }
            
            let factory = RootViewModelFactory(
                model: model,
                httpClient: httpClient,
                logger: logger,
                mapScanResult: mapper.mapScanResult,
                resolveQR: self.qrResolve,
                scanner: scanner,
                schedulers: .init()
            )
            let make = factory.makeSberQRConfirmPaymentViewModel(response:pay:)
            
            do {
                let sberQR = try make($0.get(), payload.pay)
                completion(.success(sberQR))
            } catch {
                completion(.failure(.techError))
            }
        }
    }
}

extension QRNavigation.ErrorMessage {
    
    static var techError: Self {
        
        return .init(title: "Ошибка", message: "Возникла техническая ошибка")
    }
}

private extension QRNavigationComposerMicroServicesComposer {
    
    func qrResolve(
        string: String
    ) -> QRViewModel.ScanResult {
        
        let resolver = QRResolver(isSberQR: model.isSberQR)
        
        return resolver.resolve(string: string)
    }
}
