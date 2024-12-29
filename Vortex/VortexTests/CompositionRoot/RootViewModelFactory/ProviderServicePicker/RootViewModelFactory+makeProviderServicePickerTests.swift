//
//  RootViewModelFactory+makeProviderServicePickerTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 28.12.2024.
//

@testable import Vortex
import VortexTools
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
