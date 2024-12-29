//
//  RootViewModelFactory+makeProviderServicePickerTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 28.12.2024.
//

import Combine
import PayHub
import VortexTools

#warning("move to UI")
extension ProviderServicePickerDomain.Content {
    
    var navBar: Navbar { return provider.navBar }
    
    var items: [UIItem] { services.elements.map(\.item) }
    
    struct Navbar: Equatable {
        
        let icon: String?
        let title: String
        let subtitle: String
    }
    
    struct UIItem: Equatable {
        
        let label: Label
        let item: ServicePickerItem
        
        struct Label: Equatable {
            
            let icon: String?
            let title: String
        }
    }
}

private extension UtilityPaymentOperator {
    
    var navBar: ProviderServicePickerDomain.Content.Navbar {
        
        return .init(icon: icon, title: title, subtitle: subtitle)
    }
}

private extension UtilityService {
    
    var item: ProviderServicePickerDomain.Content.UIItem {
        
        return .init(
            label: .init(icon: icon, title: name),
            item: .init(service: self, isOneOf: true)
        )
    }
}

extension RootViewModelFactory {
    
    func makeProviderServicePicker(
        provider: UtilityPaymentOperator,
        services: MultiElementArray<UtilityService>
    ) -> ProviderServicePickerDomain.Binder {
        
        compose(
            getNavigation: getProviderServicePickerNavigation,
            content: .init(provider: provider, services: services),
            witnesses: .init(
                emitting: { _ in Empty().eraseToAnyPublisher() },
                dismissing: { _ in {}}
            )
        )
    }
    
    func getProviderServicePickerNavigation(
        select: ProviderServicePickerDomain.Select,
        notify: @escaping ProviderServicePickerDomain.Notify,
        completion: @escaping (ProviderServicePickerDomain.Navigation) -> Void
    ) {
        switch select {
        case let .outside(outside):
            completion(.outside(outside))
            
        case let .service(servicePayload):
            process(payload: servicePayload.payload) { [weak self] in
                
                guard let self else { return }
                
                switch $0 {
                case let .failure(failure):
                    completion(.failure(failure))
                    
                case let .success(anywayFlowModel):
                    completion(.payment(.init(
                        model: anywayFlowModel,
                        cancellable: bind(anywayFlowModel, to: notify)
                    )))
                }
            }
        }
    }
    
    func bind(
        _ model: AnywayFlowModel,
        to notify: @escaping ProviderServicePickerDomain.Notify
    ) -> AnyCancellable {
        
        model.$state
            .compactMap(\.outside?.event)
            .sink { notify(.select(.outside($0))) }
    }
}

private extension ProviderServicePickerDomain.Select.ServicePayload {
    
    var payload: RootViewModelFactory.ProcessServicePayload {
        
        return .init(item: item, operator: `operator`.provider)
    }
}

private extension UtilityPaymentOperator {
    
    var provider: UtilityPaymentProvider {
        
        return .init(id: id, icon: icon, inn: inn, title: title, type: type)
    }
}

private extension AnywayFlowState.Status.Outside {
    
    var event: ProviderServicePickerDomain.Outside {
        
        switch self {
        case .main:     return .main
        case .payments: return .payments
        }
    }
}

/// A nameSpace.
enum ProviderServicePickerDomain {}

extension ProviderServicePickerDomain {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    
    // MARK: - Content
    
    struct Content: Equatable {
        
        let provider: Provider
        let services: Services
        
        typealias Provider = UtilityPaymentOperator
        typealias Services = MultiElementArray<UtilityService>
    }
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHub.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias Notify = FlowDomain.Notify
    typealias NotifyEvent = FlowDomain.NotifyEvent
    
    enum Select: Equatable {
    
        case outside(Outside)
        case service(ServicePayload)
        
        struct ServicePayload: Equatable {
            
            let item: ServicePickerItem
            let `operator`: UtilityPaymentOperator
        }
    }
    
    enum Outside: Equatable {
        
        case main, payments
    }
    
    enum Navigation {
        
        case outside(Outside)
        case failure(ServiceFailureAlert.ServiceFailure)
        case payment(Node<AnywayFlowModel>)
    }
}

@testable import Vortex
import XCTest

final class RootViewModelFactory_makeProviderServicePickerTests: RootViewModelFactoryTests {
    
    func test_shouldSetContentFromPayload() {
        
        let provider = makeProvider()
        let services = makeMulti()
        let sut = makeSUT().sut
        
        let binder = sut.makeProviderServicePicker(
            provider: provider,
            services: services
        )
        
        XCTAssertNoDiff(binder.content.provider, provider)
        XCTAssertNoDiff(binder.content.services, services)
    }
    
    func test_shouldSetContentNavbarFromPayload() {
        
        let provider = makeProvider()
        let sut = makeSUT().sut
        
        let binder = sut.makeProviderServicePicker(
            provider: provider,
            services: makeMulti()
        )
        
        XCTAssertNoDiff(binder.content.navBar, .init(
            icon: provider.icon,
            title: provider.title,
            subtitle: provider.subtitle
        ))
    }
    
    func test_shouldSetContentItemsFromPayload() {
        
        let services = makeMulti()
        let sut = makeSUT().sut
        
        let binder = sut.makeProviderServicePicker(
            provider: makeProvider(),
            services: services
        )
        
        let first = services.elements[0]
        let second = services.elements[1]
        XCTAssertNoDiff(binder.content.items, [
            .init(
                label: .init(icon: first.icon, title: first.name),
                item: .init(service: first, isOneOf: true)
            ),
            .init(
                label: .init(icon: second.icon, title: second.name),
                item: .init(service: second, isOneOf: true)
            ),
        ])
    }
    
    // MARK: - Helpers
    
    private func makeProvider(
        id: String = anyMessage(),
        inn: String = anyMessage(),
        title: String = anyMessage(),
        icon: String? = anyMessage(),
        type: String = anyMessage()
    ) -> UtilityPaymentOperator {
        
        return .init(id: id, inn: inn, title: title, icon: icon, type: type)
    }
    
    private func makeMulti(
        first: UtilityService? = nil,
        second: UtilityService? = nil,
        tail: UtilityService...
    ) -> MultiElementArray<UtilityService> {
        
        return .init(first ?? makeUtilityService(), second ?? makeUtilityService(), tail)
    }
}

extension RootViewModelFactoryTests {
    
    func makeUtilityService(
        icon: String? = anyMessage(),
        name: String = anyMessage(),
        puref: String = anyMessage()
    ) -> UtilityService {
        
        return .init(icon: icon, name: name, puref: puref)
    }
}
