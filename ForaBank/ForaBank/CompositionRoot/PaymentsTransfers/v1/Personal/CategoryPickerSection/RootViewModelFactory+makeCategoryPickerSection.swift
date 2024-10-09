//
//  RootViewModelFactory+makeCategoryPickerSection.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.10.2024.
//

import CombineSchedulers
import ForaTools
import Foundation
import GenericRemoteService
import PayHub
import SberQR

extension RootViewModelFactory {
    
    static func makeCategoryPickerSection(
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol,
        model: Model,
        nanoServices: PaymentsTransfersPersonalNanoServices,
        pageSize: Int,
        placeholderCount: Int,
        mainScheduler: AnySchedulerOf<DispatchQueue>,
        backgroundScheduler: AnySchedulerOf<DispatchQueue>
    ) -> CategoryPickerSection.Binder {
        
        func loadOperators(
            payload: UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload,
            completion: @escaping ([PaymentServiceOperator]) -> Void
        ) {
            backgroundScheduler.schedule {
                
                model.loadOperators(payload, completion)
            }
        }
        
        func loadOperatorsForCategory(
            category: ServiceCategory,
            completion: @escaping (Result<[PaymentServiceOperator], Error>) -> Void
        ) {
            backgroundScheduler.schedule {
                
                model.loadOperators(.init(
                    afterOperatorID: nil,
                    for: category.type,
                    searchText: "",
                    pageSize: pageSize
                )) {
                    completion(.success($0))
                }
            }
        }
        
        func makeList(
            categories: [ServiceCategory]
        ) -> CategoryListModelStub {
            
            return .init(categories: categories)
        }
        
        func makeMobile() -> ClosePaymentsViewModelWrapper {
            
            return .init(
                model: model,
                service: .mobileConnection,
                scheduler: mainScheduler
            )
        }
        
        func makeQR() -> QRModel {
            
            RootViewModelFactory.makeMakeQRScannerModel(
                model: model,
                qrResolverFeatureFlag: .init(.active),
                utilitiesPaymentsFlag: .init(.active(.live)),
                scheduler: mainScheduler
            )()
        }
        
        let makeStandard = makeStandard(
            loadLatestForCategory: nanoServices.loadLatestForCategory,
            loadOperators: loadOperators,
            loadOperatorsForCategory: loadOperatorsForCategory,
            model: model,
            pageSize: pageSize,
            mainScheduler: mainScheduler
        )
        
        func makeTax() -> ClosePaymentsViewModelWrapper {
            
            return .init(
                model: model,
                category: .taxes,
                scheduler: mainScheduler
            )
        }
        
        func makeTransport() -> TransportPaymentsViewModel? {
            
            model.makeTransportPaymentsViewModel(type: .transport)
        }
        
        let selectedCategoryComposer = SelectedCategoryNavigationMicroServicesComposer<[ServiceCategory], CategoryListModelStub>(
            model: model,
            nanoServices: .init(
                makeList: makeList,
                makeMobile: makeMobile,
                makeQR: makeQR,
                makeQRNavigation: makeQRNavigation,
                makeStandard: makeStandard,
                makeTax: makeTax,
                makeTransport: makeTransport
            ),
            scheduler: mainScheduler
        )
        let microServices = selectedCategoryComposer.compose()
        
        let categoryPickerComposer = CategoryPickerSection.BinderComposer(
            load: nanoServices.loadCategories,
            microServices: microServices,
            placeholderCount: placeholderCount,
            scheduler: mainScheduler
        )
        
        return categoryPickerComposer.compose(
            prefix: [],
            suffix: (0..<placeholderCount).map { _ in .placeholder(.init()) }
        )
        
        func createSberQRPayment(
            payload: (URL, SberQRConfirmPaymentState),
            completion: @escaping (Result<CreateSberQRPaymentResponse, QRNavigation.ErrorMessage>) -> Void
        ){
            let composer = LoggingRemoteNanoServiceComposer(
                httpClient: httpClient,
                logger: logger
            )
            let createSberQRPaymentService = composer.compose(
                createRequest: RequestFactory.createCreateSberQRPaymentRequest,
                mapResponse: SberQR.ResponseMapper.mapCreateSberQRPaymentResponse
            )
            
            guard let payload = payload.1.makePayload(with: payload.0)
            else { return completion(.failure(.techError)) }
            
            createSberQRPaymentService(payload) {
                
                completion($0.mapError { _ in .techError })
                _ = createSberQRPaymentService
            }
        }
        
        func getSberQRData(
            url: URL,
            completion: @escaping (Result<GetSberQRDataResponse, any Error>) -> Void
        ) {
            let composer = LoggingRemoteNanoServiceComposer(
                httpClient: httpClient,
                logger: logger
            )
            let getSberQRDataService = composer.compose(
                createRequest: RequestFactory.createGetSberQRRequest,
                mapResponse: SberQR.ResponseMapper.mapGetSberQRDataResponse,
                mapError: { $0 }
            )
            
            getSberQRDataService(url) {
                
                completion($0.mapError { $0 })
                _ = getSberQRDataService
            }
        }
        
        func makeSegmented(
            multi: MultiElementArray<SegmentedOperatorProvider>,
            qrCode: QRCode,
            qrMapping: QRMapping
        ) -> SegmentedPaymentProviderPickerFlowModel {
            
            let make = RootViewModelFactory.makeSegmentedPaymentProviderPickerFlowModel(
                httpClient: httpClient,
                log: logger.log,
                model: model,
                pageSize: pageSize,
                flag: .live,
                scheduler: mainScheduler
            )
            
            return make(multi, qrCode, qrMapping)
        }
        
        func makeServicePicker(
            payload: PaymentProviderServicePickerPayload,
            completion: @escaping (AnywayServicePickerFlowModel) -> Void
        ) {
            let servicePickerComposer = makeAnywayServicePickerFlowModelComposer(
                httpClient: httpClient,
                log: logger.log,
                model: model,
                flag: .live,
                scheduler: mainScheduler
            )
            
            completion(servicePickerComposer.compose(payload: payload))
        }
        
        func makeQRNavigation(
            qrResult: QRModelResult,
            notify: @escaping QRNavigationComposer.Notify,
            completion: @escaping (QRNavigation) -> Void
        ) {
            let microServicesComposer = QRNavigationComposerMicroServicesComposer(
                logger: logger,
                model: model,
                createSberQRPayment: createSberQRPayment,
                getSberQRData: getSberQRData,
                makeSegmented: makeSegmented,
                makeServicePicker: makeServicePicker,
                scheduler: mainScheduler
            )
            let microServices = microServicesComposer.compose()
            let composer = QRNavigationComposer(microServices: microServices)
            
            composer.compose(
                payload: .qrResult(qrResult),
                notify: notify,
                completion: completion)
        }
    }
    
    typealias MakeStandard = CategoryPickerSectionMicroServicesComposerNanoServices<[ServiceCategory], CategoryListModelStub>.MakeStandard
    /*private*/ typealias LoadLatestForCategory = (ServiceCategory, @escaping (Result<[Latest], Error>) -> Void) -> Void
    /*private*/ typealias LoadOperators = (UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload, @escaping ([PaymentServiceOperator]) -> Void) -> Void
    /*private*/ typealias LoadOperatorsForCategory = (ServiceCategory, @escaping (Result<[PaymentServiceOperator], Error>) -> Void) -> Void
    
    /*private*/ static func makeStandard(
        loadLatestForCategory: @escaping LoadLatestForCategory,
        loadOperators: @escaping LoadOperators,
        loadOperatorsForCategory: @escaping LoadOperatorsForCategory,
        model: Model,
        pageSize: Int,
        mainScheduler: AnySchedulerOf<DispatchQueue>
    ) -> MakeStandard {
        
        return { category, completion in
            
            let microServicesComposer = UtilityPrepaymentMicroServicesComposer(
                pageSize: pageSize,
                nanoServices: .init(loadOperators: loadOperators)
            )
            let standardNanoServicesComposer = StandardSelectedCategoryDestinationNanoServicesComposer(
                loadLatest: loadLatestForCategory,
                loadOperators: loadOperatorsForCategory,
                makeMicroServices: microServicesComposer.compose,
                model: model,
                scheduler: mainScheduler
            )
            let standardNanoServices = standardNanoServicesComposer.compose(category: category)
            let composer = StandardSelectedCategoryDestinationMicroServiceComposer(
                nanoServices: standardNanoServices
            )
            let standardMicroService = composer.compose()
            
            standardMicroService.makeDestination(category, completion)
        }
    }
}

// MARK: - Helpers

#warning("duplication - see UtilityPaymentOperatorLoaderComposer")

private extension Model {
    
    func loadOperators(
        _ payload: UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload,
        _ completion: @escaping LoadOperatorsCompletion
    ) {
        let log = LoggerAgent().log
        let cacheLog = { log(.debug, .cache, $0, $1, $2) }
        
        if let operators = localAgent.load(type: [CodableServicePaymentOperator].self) {
            cacheLog("Total Operators count \(operators.count)", #file, #line)
            
            let page = operators.operators(for: payload)
            cacheLog("Operators page count \(page.count) for \(payload.categoryType.name)", #file, #line)
            
            completion(page)
        } else {
            cacheLog("No more Operators", #file, #line)
            completion([])
        }
    }
    
    typealias LoadOperatorsCompletion = ([PaymentServiceOperator]) -> Void
}

// TODO: - add tests
extension Array where Element == CodableServicePaymentOperator {
    
    /// - Warning: expensive with sorting and search. Sorting is expected to happen at cache phase.
    func operators(
        for payload: UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload
    ) -> [PaymentServiceOperator] {
        
        // sorting is performed at cache phase
        return self
            .filter { $0.matches(payload) }
            .page(startingAfter: payload.operatorID, pageSize: payload.pageSize)
            .map(PaymentServiceOperator.init(codable:))
    }
}

// MARK: - Search

// TODO: - add tests
extension CodableServicePaymentOperator {
    
    func matches(
        _ payload: UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload
    ) -> Bool {
        
        type == payload.categoryType.name && contains(payload.searchText)
    }
    
    func contains(_ searchText: String) -> Bool {
        
        guard !searchText.isEmpty else { return true }
        
        return name.localizedCaseInsensitiveContains(searchText)
        || inn.localizedCaseInsensitiveContains(searchText)
    }
}

private extension PaymentServiceOperator {
    
    init(codable: CodableServicePaymentOperator) {
        
        self.init(
            id: codable.id,
            inn: codable.inn,
            md5Hash: codable.md5Hash,
            name: codable.name,
            type: codable.type
        )
    }
}
