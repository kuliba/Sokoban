//
//  ComposedCVVPINService+log.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.10.2023.
//

extension ComposedCVVPINService {
#warning("remove LoggerAgentCategory")
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
    
    convenience init(
        changePIN: @escaping ChangePIN,
        checkActivation: @escaping CheckActivation,
        confirmActivation: @escaping ConfirmActivation,
        getPINConfirmationCode: @escaping GetPINConfirmationCode,
        initiateActivation: @escaping InitiateActivation,
        showCVV: @escaping ShowCVV,
        log: @escaping Log
    ) {
        self.init(
            changePIN: { cardID, pin ,otp, completion in
                
                changePIN(cardID, pin, otp) { result in
                    
                    switch result {
                    case let .failure(error):
                        log(.error, .crypto, "Change PIN failure: \(error).", #file, #line)
                        
                    case .success:
                        log(.info, .crypto, "Change PIN success.", #file, #line)
                    }
                    
                    completion(result)
                }
            },
            checkActivation: { completion in
                
                checkActivation { result in
                    
                    switch result {
                    case let .failure(error):
                        log(.error, .crypto, "Check Activation failure: \(error).", #file, #line)
                        
                    case .success:
                        log(.info, .crypto, "Check Activation success.", #file, #line)
                    }
                    
                    completion(result)
                }
            },
            confirmActivation: { otp, completion in
                
                confirmActivation(otp) { result in
                    
                    switch result {
                    case let .failure(error):
                        log(.error, .crypto, "Confirm Activation failure: \(error).", #file, #line)
                        
                    case .success:
                        log(.info, .crypto, "Confirm Activation success.", #file, #line)
                    }
                    
                    completion(result)
                }
            },
            getPINConfirmationCode: { completion in
                
                getPINConfirmationCode { result in
                    
                    switch result {
                    case let .failure(error):
                        log(.error, .crypto, "Get PIN Confirmation Code failure: \(error).", #file, #line)
                        
                    case let .success(response):
                        log(.info, .crypto, "Get PIN Confirmation Code success: \(response.otpEventID.eventIDValue), \(response.phone).", #file, #line)
                    }
                    
                    completion(result)
                }
            },
            initiateActivation: { completion in
                
                initiateActivation { result in
                    
                    switch result {
                    case let .failure(error):
                        log(.error, .crypto, "Initiate Activation failure: \(error).", #file, #line)
                        
                    case let .success(success):
                        log(.info, .crypto, "Initiate Activation success: \(success.phone.phoneValue).", #file, #line)
                    }
                    
                    completion(result)
                }
            },
            showCVV: { cardID, completion in
                
                showCVV(cardID) { result in
                    
                    switch result {
                    case let .failure(error):
                        log(.error, .crypto, "Show CVV failure: \(error).", #file, #line)
                        
                    case .success:
                        log(.info, .crypto, "Show CVV success.", #file, #line)
                    }
                    
                    completion(result)
                }
            }
        )
    }
}
