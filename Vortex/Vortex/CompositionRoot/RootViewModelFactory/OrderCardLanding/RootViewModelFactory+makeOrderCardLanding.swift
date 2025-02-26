//
//  RootViewModelFactory+makeOrderCardLanding.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 25.02.2025.
//

import Foundation
import RemoteServices

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
        
        //TODO: replace stub to real data
        return .stub
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
                //TODO: replace stub to real data
                completion(.success(.stub))
            }
        }
    }
}

private extension String {
    
    static let connectivity = "Возникла техническая ошибка.\nСвяжитесь с поддержкой банка для уточнения"
}

private extension OrderCardLandingDomain.Content {
    
    static let stub: Self = .init(
        header: .init(
            title: "Карта МИР «Все включено»",
            options: [
                "кешбэк до 10 000 ₽ в месяц",
                "5% выгода при покупке топлива",
                "5% на категории сезона",
                "от 0,5% до 1% кешбэк на остальные покупки**"
            ],
            backgroundImage: .cardPlaceholder
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
                    description: "тест"
                ),
                .init(
                    title: "Как начисляются проценты?",
                    description: "тесттесттесттесттесттесттесттест"
                ),
                .init(
                    title: "Какие условия бесплатного обслуживания?",
                    description: ""
                )
            ]
        )
    )
}
