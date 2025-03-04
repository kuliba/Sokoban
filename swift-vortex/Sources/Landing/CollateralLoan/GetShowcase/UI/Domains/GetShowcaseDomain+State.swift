//
//  GetShowcaseDomain+State.swift
//
//
//  Created by Valentin Ozerov on 26.12.2024.
//

extension GetShowcaseDomain {
    
    public struct State<InformerPayload> {
        
        public var isLoading = false
        public var result: Result<InformerPayload>?
        var selectedLandingId: String?

        public init(
            isLoading: Bool = false,
            result: Result<InformerPayload>? = nil,
            selectedLandingId: String? = nil
        ) {
            self.isLoading = isLoading
            self.result = result
            self.selectedLandingId = selectedLandingId
        }
    }
}

public extension GetShowcaseDomain.State {
    
    var showcase: GetShowcaseDomain.ShowCase? {
        
        guard case let .success(showcase) = result
        else { return nil }
        
        return showcase
    }
}
