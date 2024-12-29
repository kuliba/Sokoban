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
    
    var items: [Item] { services.elements.map(\.item) }
    
    struct Navbar: Equatable {
        
        let icon: String?
        let title: String
        let subtitle: String
    }
    
    struct Item: Equatable {
        
        let icon: String?
        let title: String
    }
}

private extension UtilityPaymentOperator {
    
    var navBar: ProviderServicePickerDomain.Content.Navbar {
        
        return .init(icon: icon, title: title, subtitle: subtitle)
    }
}

private extension UtilityService {
    
    var item: ProviderServicePickerDomain.Content.Item {
        
        return .init(icon: icon, title: name)
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
        process(payload: select.payload) {
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(success):
                completion(.ok)
            }
        }
    }
}

private extension ProviderServicePickerDomain.Select {
    
    var payload: RootViewModelFactory.ProcessServicePayload {
        
        return .init(item: item, operator: `operator`.provider)
    }
}

private extension UtilityPaymentOperator {
    
    var provider: UtilityPaymentProvider {
        
        return .init(id: id, icon: icon, inn: inn, title: title, type: type)
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
    
    struct Select: Equatable {
        
        let item: ServicePickerItem
        let `operator`: UtilityPaymentOperator
    }
    
    enum Navigation {
        
        case failure(ServiceFailureAlert.ServiceFailure)
        case ok
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
            .init(icon: first.icon, title: first.name),
            .init(icon: second.icon, title: second.name),
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
