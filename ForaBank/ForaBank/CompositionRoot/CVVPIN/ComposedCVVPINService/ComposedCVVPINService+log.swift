//
//  ComposedCVVPINService+log.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.10.2023.
//

extension ComposedCVVPINService {
    
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void

    convenience init(
        activate: @escaping Activate,
        changePIN: @escaping ChangePIN,
        checkActivation: @escaping CheckActivation,
        confirmActivation: @escaping ConfirmActivation,
        getPINConfirmationCode: @escaping GetPINConfirmationCode,
        showCVV: @escaping ShowCVV,
        log: @escaping Log
    ) {
        self.init(
            activate: { completion in
                
                activate { result in
                    
                    switch result {
                    case let .failure(error):
                        log(.error, .crypto, "Activation Failure: \(error).", #file, #line)
                    case let .success(phone):
                        log(.info, .crypto, "Activation success: \(phone).", #file, #line)
                    }
                    
                    completion(result)
                }
            },
            changePIN: { cardID, pin ,otp, completion in
                
                changePIN(cardID, pin, otp) { result in
                    
                    switch result {
                    case let .failure(error):
                        log(.error, .crypto, "Change PIN Failure: \(error)", #file, #line)
                    case .success:
                        log(.info, .crypto, "Change PIN success.", #file, #line)
                    }
                    
                    completion(result)
                }
            },
            checkActivation: checkActivation,
            confirmActivation: { otp, completion in
                
                confirmActivation(otp) { result in
                    
                    switch result {
                    case let .failure(error):
                        log(.error, .crypto, "Confirm Activation Failure: \(error)", #file, #line)
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
                        log(.error, .crypto, "Get PIN Confirmation Code Failure: \(error)", #file, #line)
                    case let .success(response):
                        log(.info, .crypto, "Get PIN Confirmation Code success: \(response)", #file, #line)
                    }
                    
                    completion(result)
                }
            },
            showCVV: { cardID, completion in
                
                showCVV(cardID) { result in
                    
                    switch result {
                    case let .failure(error):
                        log(.error, .crypto, "Show CVV Failure: \(error)", #file, #line)
                    case let .success(cvv):
                        log(.info, .crypto, "Show CVV success: \(cvv).", #file, #line)
                    }
                    
                    completion(result)
                }
            }
        )
    }
}
