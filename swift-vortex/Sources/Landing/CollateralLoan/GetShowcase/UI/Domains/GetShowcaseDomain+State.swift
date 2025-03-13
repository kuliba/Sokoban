//
//  GetShowcaseDomain+State.swift
//
//
//  Created by Valentin Ozerov on 26.12.2024.
//

extension GetShowcaseDomain {
    
    public struct State<InformerPayload> {
        
        public var status: Status<InformerPayload>

        var selectedLandingId: String?
        var backendFailure: BackendFailure<InformerPayload>?

        public init(
            status: Status<InformerPayload>,
            selectedLandingId: String? = nil,
            backendFailure: BackendFailure<InformerPayload>? = nil
        ) {
            self.status = status
            self.selectedLandingId = selectedLandingId
            self.backendFailure = backendFailure
        }
    }
        
    public enum Status<InformerPayload> {
        
        case initiate
        case inflight(Showcase?)
        case loaded(Showcase)
        case failure(Failure, Showcase?)
        
        public var isLoading: Bool {
            
            switch self {
            case .inflight:
                return true
            case .initiate, .failure, .loaded:
                return false
            }
        }
        
        var oldShowcase: Showcase? {
            
            switch self {
            case let .loaded(showcase):
                return showcase
                
            case let .failure(_, showcase):
                return showcase
                
            case let .inflight(showcase):
                return showcase

            case .initiate:
                return nil
            }
        }

        public enum Failure {
            
            case alert(String)
            case informer(InformerPayload)
        }
    }
}

extension GetShowcaseDomain.State {
    
    public var failure: GetShowcaseDomain.Status<InformerPayload>.Failure? {
        
        if case let .failure(failure, _) = status {
     
                return failure
        }
        
        return nil
    }
}

//
//public extension GetShowcaseDomain.State {
//    
//    var showcase: GetShowcaseDomain.ShowCase? {
//        
//        guard case let .success(showcase) = result
//        else { return nil }
//        
//        return showcase
//    }
//}
