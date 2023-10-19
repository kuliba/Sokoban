//
//  anyChangePINAPIError.swift
//  
//
//  Created by Igor Malyarov on 17.10.2023.
//

extension MakeComposerInfraTests {
    
    func anyChangePINAPIError(
        statusCode: Int = 1234,
        errorMessage: String = "error message"
    ) -> ChangePINAPIError {
        
        .error(
            statusCode: statusCode,
            errorMessage: errorMessage
        )
    }
}
