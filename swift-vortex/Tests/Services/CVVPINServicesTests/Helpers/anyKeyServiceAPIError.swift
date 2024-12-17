//
//  anyKeyServiceAPIError.swift
//  
//
//  Created by Igor Malyarov on 17.10.2023.
//

extension MakeComposerInfraTests {
    
    func anyKeyServiceAPIError(
        statusCode: Int = 1234,
        errorMessage: String = "error message"
    ) -> KeyServiceAPIError {
        
        .error(
            statusCode: statusCode,
            errorMessage: errorMessage
        )
    }
}
