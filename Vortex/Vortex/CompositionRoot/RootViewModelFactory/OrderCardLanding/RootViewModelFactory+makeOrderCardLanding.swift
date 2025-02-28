//
//  RootViewModelFactory+makeOrderCardLanding.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 25.02.2025.
//

import Foundation
import HeaderLandingComponent
import ListLandingComponent
import OrderCardLandingBackend
import RemoteServices
import DropDownTextListComponent

extension RootViewModelFactory {
    
    @inlinable
    func makeOrderCardLanding(
    ) -> OrderCardLandingDomain.Binder {
        
        composeBinder(
            content: makeOrderCardLandinContent(),
            getNavigation: getNavigation,
            selectWitnesses: .empty
        )
    }
    
    @inlinable
    func makeOrderCardLandinContent(
    ) -> OrderCardLandingDomain.Content {
        
        var orderCard: OrderCardLandingDomain.Content? = nil
        
        createOrderCardLanding { result in
        
            switch result {
            case let .success(landing):
                orderCard = landing
            case let .failure(error):
                break
            }
        }
        
        return orderCard ?? .stub
    }
    
    @inlinable
    func getNavigation(
        select: OrderCardLandingDomain.Select,
        notify: @escaping OrderCardLandingDomain.Notify,
        completion: @escaping (OrderCardLandingDomain.Navigation) -> Void
    ) {
        switch select {
        case .continue:
            break
            //TODO: add request and proccess
        }
    }
    
    @inlinable
    func createOrderCardLanding(
        completion: @escaping (ModelOrderPayloadResult) -> Void
    ) {

        createOrderCardLandingService() { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(payload):
                completion(.success(payload))
            }
        }
    }
    
    typealias ModelOrderPayloadResult = Result<OrderCardLanding, BackendFailure>

    @inlinable
    func createOrderCardLandingService(
        completion: @escaping (ModelOrderPayloadResult) -> Void
    ) {
        let service = onBackground(
            makeRequest: RequestFactory.createGetDigitalCardLandingRequest,
            mapResponse: RemoteServices.ResponseMapper.mapOrderCardLandingResponse,
            connectivityFailureMessage: .connectivity
        )
        
        service(()) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(response):
                completion(.success(.init(response))
                )
            }
        }
    }
}

private extension OrderCardLanding {

    init(_ response: OrderCardLandingResponse) {
        self.init(
            header: .init(product: response.product),
            conditions: .init(conditions: response.conditions),
            security: .init(security: response.security),
            dropDownList: .init(questions: response.frequentlyAskedQuestions)
        )
    }
}

private extension DropDownTextList {

    init(questions: OrderCardLandingResponse.Question) {
        self.init(
            title: questions.title,
            items: questions.list.compactMap({
                .init(
                    title: $0.title,
                    subTitle: $0.subtitle ?? ""
                )
            })
        )
    }
}

private extension ListLandingComponent.Items {
    
    init(security: OrderCardLandingResponse.Security) {
        self.init(
            title: security.title,
            list: security.list.compactMap({
                .init(
                    md5hash: $0.md5hash,
                    title: $0.title,
                    subtitle: $0.subtitle
                )
            })
        )
    }
}

private extension ListLandingComponent.Items {

    init(conditions: OrderCardLandingResponse.Condition) {
        self.init(
            title: conditions.title,
            list: conditions.list.compactMap({
                .init(
                    md5hash: $0.md5hash,
                    title: $0.title,
                    subtitle: $0.subtitle
                )
            })
        )
    }
}

private extension Header {

    init(product: OrderCardLandingResponse.Product) {
        
        self.init(
            title: product.title, 
            navTitle: product.navTitle,
            navSubtitle: product.navSubtitle,
            options: product.features,
            imageUrl: product.image
        )
    }
}

private extension String {
    
    static let connectivity = "Возникла техническая ошибка.\nСвяжитесь с поддержкой банка для уточнения"
}

private extension OrderCardLandingDomain.Content {
    
    static let stub: Self = .init(
        header: .init(
            title: "Карта МИР «Все включено»",
            navTitle: "Карта МИР",
            navSubtitle: "«Все включено»",
            options: [
                "кешбэк до 10 000 ₽ в месяц",
                "5% выгода при покупке топлива",
                "5% на категории сезона",
                "от 0,5% до 1% кешбэк на остальные покупки**"
            ],
            imageUrl: "dict/getProductCatalogImage?image=products/pages/order-card/digital-card-landing/images/digital_card_landing_bg.png"
        ),
        conditions: .init(
            title: "Выгодные условия",
            list: [
                .init(
                    md5hash: "b6fa019f307d6a72951ab7268708aa15",
                    title: "0 ₽",
                    subtitle: "Условия обслуживания"
                ),
                .init(
                    md5hash: "b6fa019f307d6a72951ab7268708aa15",
                    title: "До 35%",
                    subtitle: "Кешбэк и скидки"
                ),
                .init(
                    md5hash: "b6fa019f307d6a72951ab7268708aa15",
                    title: "Кешбэк 5%",
                    subtitle: "На востребованные категории"
                ),
                .init(
                    md5hash: "b6fa019f307d6a72951ab7268708aa15",
                    title: "Кешбэк 5%",
                    subtitle: "На топливо и 3% кешбэк на кофе"
                ),
                .init(
                    md5hash: "b6fa019f307d6a72951ab7268708aa15",
                    title: "8% годовых",
                    subtitle: "При сумме остатка от 500 001 ₽"
                )
            ]
        ),
        security: .init(
            title: "Безопасность",
            list: [
                .init(
                    md5hash: "b6fa019f307d6a72951ab7268708aa15",
                    title: "Ваши средства застрахованы в АСВ",
                    subtitle: "Банк входит в систему страхования вкладов Агентства по страхованию вкладов"
                ),
                .init(
                    md5hash: "b6fa019f307d6a72951ab7268708aa15",
                    title: "Безопасные платежи в Интернете (3-D Secure)",
                    subtitle: "3-D Secure — технология, предназначенная для повышения безопасности расчетов"
                ),
                .init(
                    md5hash: "b6fa019f307d6a72951ab7268708aa15",
                    title: "Блокировка подозрительных операций",
                    subtitle: "На востребованные категории"
                )
            ]
        ),
        dropDownList: .init(
            title: "Часто задаваемые вопросы",
            items: [
                .init(
                    title: "Как повторно подключить подписку?",
                    subTitle: "тест"
                ),
                .init(
                    title: "Как начисляются проценты?",
                    subTitle: "тесттесттесттесттесттесттесттест"
                ),
                .init(
                    title: "Какие условия бесплатного обслуживания?",
                    subTitle: ""
                )
            ]
        )
    )
}
