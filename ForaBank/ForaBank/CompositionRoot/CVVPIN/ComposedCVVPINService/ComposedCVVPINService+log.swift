//
//  ComposedCVVPINService+log.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.10.2023.
//

extension ComposedCVVPINService {
    
    convenience init(
        log: @escaping (String, StaticString, UInt) -> Void,
        activate: @escaping Activate,
        changePIN: @escaping ChangePIN,
        checkActivation: @escaping CheckActivation,
        confirmActivation: @escaping ConfirmActivation,
        getPINConfirmationCode: @escaping GetPINConfirmationCode,
        showCVV: @escaping ShowCVV
    ) {
        self.init(
            activate: { completion in
                
                activate { result in
                    
                    switch result {
                    case let .failure(error):
                        log("Activation Failure: \(error)", #file, #line)
                    case let .success(phone):
                        log("Activation success: \(phone)", #file, #line)
                    }
                    
                    completion(result)
                }
            },
            changePIN: { cardID, pin ,otp, completion in
                
                changePIN(cardID, pin, otp) { result in
                    
                    switch result {
                    case let .failure(error):
                        log("Change PIN Failure: \(error)", #file, #line)
                    case .success:
                        log("Change PIN success.", #file, #line)
                    }
                    
                    completion(result)
                }
            },
            checkActivation: checkActivation,
            confirmActivation: { otp, completion in
                
                confirmActivation(otp) { result in
                    
                    switch result {
                    case let .failure(error):
                        log("Confirm Activation Failure: \(error)", #file, #line)
                    case .success:
                        log("Confirm Activation success.", #file, #line)
                    }
                    
                    completion(result)
                }
            },
            getPINConfirmationCode: { completion in
                
                getPINConfirmationCode { result in
                    
                    switch result {
                    case let .failure(error):
                        log("Get PIN Confirmation Code Failure: \(error)", #file, #line)
                    case let .success(response):
                        log("Get PIN Confirmation Code success: \(response)", #file, #line)
                    }
                    
                    completion(result)
                }
            },
            showCVV: { cardID, completion in
                
                showCVV(cardID) { result in
                    
                    switch result {
                    case let .failure(error):
                        log("Show CVV Failure: \(error)", #file, #line)
                    case let .success(cvv):
                        log("Show CVV success: \(cvv).", #file, #line)
                    }
                    
                    completion(result)
                }
            }
        )
    }
}
