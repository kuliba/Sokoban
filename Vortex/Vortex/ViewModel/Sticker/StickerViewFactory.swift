//
//  StickerViewFactory.swift
//  Vortex
//
//  Created by Andryusina Nataly on 27.10.2024.
//

import Foundation
import CombineSchedulers
import SwiftUI
import PaymentSticker

final class StickerViewFactory {
        
    let model: Model
    let httpClient: HTTPClient
    let logger: LoggerAgentProtocol
        
    init(
        model: Model,
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol
    ) {
        self.model = model
        self.httpClient = httpClient
        self.logger = logger
    }
}

extension StickerViewFactory {
    
    func makeNavigationOperationView(
        dismissAll: @escaping() -> Void
    ) -> () -> some View {
        
        return makeNavigationOperationView
        
        func operationView(
            setSelection: (@escaping (Location, @escaping NavigationFeatureViewModel.Completion) -> Void)
        ) -> some View {
            
            let makeOperationStateViewModel = makeOperationStateViewModel()
            
            return OperationView(
                model: makeOperationStateViewModel(setSelection),
                operationResultView: { result in
                    
                    OperationResultView(
                        model: result,
                        buttonsView: self.makeStickerDetailDocumentButtons(),
                        mainButtonAction: dismissAll,
                        configuration: .iVortex
                    )
                },
                configuration: .iVortex
            )
        }
        
        func dictionaryAtmList(location: Location) -> [AtmData] {
            
            model.dictionaryAtmList()?
                .filter({ $0.cityId.description == location.id })
                .filter({ $0.serviceIdList.contains(where: { $0 == 140 } )}) ?? []
        }
        
        func dictionaryAtmMetroStations() -> [AtmMetroStationData] {
            
            model.dictionaryAtmMetroStations() ?? []
        }
        
        func listView(
            location: Location,
            completion: @escaping (Office?) -> Void
        ) -> some View {
            
            PlacesListInternalView(
                items: dictionaryAtmList(location: location).map { item in
                    PlacesListViewModel.ItemViewModel(
                        id: item.id,
                        name: item.name,
                        address: item.address,
                        metro: dictionaryAtmMetroStations().filter({
                            item.metroStationList.contains($0.id)
                        }).map({
                            PlacesListViewModel.ItemViewModel.MetroStationViewModel(
                                id: $0.id,
                                name: $0.name,
                                color: $0.color.color
                            )
                        }),
                        schedule: item.schedule,
                        distance: nil
                    )
                },
                selectItem: { item in
                    
                    completion(Office(id: item.id, name: item.name))
                }
            )
        }
        
        //NavigationOperationView
        func makeNavigationOperationView() -> some View {
            
            NavigationOperationView(
                location: .init(id: ""),
                viewModel: .init(),
                operationView: operationView,
                listView: listView
            )
        }
    }
    
    func makeStickerDetailDocumentButtons(
    ) -> (
        PaymentSticker.OperationResult.PaymentID
    ) -> some View {
        
        let makeDetailButton = makeOperationDetailButton()
        
        let makeDocumentButton = makeDocumentButton(
            printFormType: "sticker"
        )
        
        return make
        
        func make(
            paymentID: PaymentSticker.OperationResult.PaymentID
        ) -> some View {
            
            HStack {
                
                makeDetailButton(.init("\(paymentID.id)"))
                makeDocumentButton(.init(paymentID.id))
            }
        }
    }
}

extension StickerViewFactory {
    
    static let preview = StickerViewFactory(
        model: .emptyMock,
        httpClient: Model.emptyMock.authenticatedHTTPClient(),
        logger: LoggerAgent()
    )
}
