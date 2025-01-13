//
//  anyShowCVVAPIError.swift
//  
//
//  Created by Igor Malyarov on 17.10.2023.
//

extension MakeComposerInfraTests {
    
    func anyShowCVVAPIError(
        statusCode: Int = 1234,
        errorMessage: String = "error message"
    ) -> ShowCVVAPIError {
        
        .error(
            statusCode: statusCode,
            errorMessage: errorMessage
        )
    }
}
