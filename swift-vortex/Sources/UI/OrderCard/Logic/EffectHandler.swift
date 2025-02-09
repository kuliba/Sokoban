////
////  EffectHandler.swift
////
////
////  Created by Дмитрий Савушкин on 08.02.2025.
////
//
//import Foundation
//
//public final class EffectHandler<Confirmation> {
//    
//    private let load: Load
//    private let loadConfirmation: LoadConfirmation
//    private let orderCard: OrderCard
//    
//    public init(
//        load: @escaping Load,
//        loadConfirmation: @escaping LoadConfirmation,
//        orderCard: @escaping OrderCard
//    ) {
//        self.load = load
//        self.loadConfirmation = loadConfirmation
//        self.orderCard = orderCard
//    }
//    
//    public typealias DismissInformer = () -> Void
//    public typealias Load = (@escaping DismissInformer, @escaping (LoadFormResult<Confirmation>) -> Void) -> Void
//    
//    public enum ConfirmationEvent {
//        
//        case dismissInformer
//        case otp(String)
//    }
//    
//    public typealias ConfirmationNotify = (ConfirmationEvent) -> Void
//    public typealias LoadConfirmation = (@escaping ConfirmationNotify, @escaping (LoadConfirmationResult<Confirmation>) -> Void) -> Void
//    
//    public typealias OrderCard = (OrderCardPayload, @escaping (Event.OrderCardResult) -> Void) -> Void
//}
//
//public extension EffectHandler {
//    
//    func handleEffect(
//        _ effect: Effect,
//        _ dispatch: @escaping Dispatch
//    ) {
//        switch effect {
//        case .load:
//            load({ dispatch(.dismissInformer) }) { dispatch(.loaded($0)) }
//            
//        case .loadConfirmation:
//            
//            let confirmationNotify: ConfirmationNotify = {
//                
//                switch $0 {
//                case .dismissInformer:
//                    dispatch(.dismissInformer)
//                    
//                case let .otp(otp):
//                    dispatch(.otp(otp))
//                }
//            }
//            loadConfirmation(confirmationNotify) { dispatch(.loadConfirmation($0)) }
//            
//        case let .orderCard(payload):
//            orderCard(payload) { dispatch(.orderCardResult($0)) }
//        }
//    }
//    
//    typealias Dispatch = (Event<Confirmation>) -> Void
//}
