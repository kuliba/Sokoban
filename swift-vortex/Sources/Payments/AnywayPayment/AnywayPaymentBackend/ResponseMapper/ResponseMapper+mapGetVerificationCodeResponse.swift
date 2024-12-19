//
//  ResponseMapper+mapGetVerificationCodeResponse.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetVerificationCodeResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetVerificationCodeResponse> {
        
        map(data, httpURLResponse, mapOrThrow: GetVerificationCodeResponse.init)
    }
}

extension ResponseMapper {
    
    public struct GetVerificationCodeResponse: Equatable {
        
        public let resendOTPCount: Int
        public let otp: String?
        
        public init(
            resendOTPCount: Int,
            otp: String?
        ) {
            self.resendOTPCount = resendOTPCount
            self.otp = otp
        }
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let resendOTPCount: Int
        let otp: String?
    }
}

// MARK: - Adapters

private extension ResponseMapper.GetVerificationCodeResponse {
    
    init(_ data: ResponseMapper._Data) {
        
        self.init(
            resendOTPCount: data.resendOTPCount,
            otp: data.otp
        )
    }
}
