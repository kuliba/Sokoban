//
//  ProfileState.swift
//  
//
//  Created by Igor Malyarov on 29.08.2024.
//

public enum ProfileState<Corporate, Personal> {
    
    case corporate(Corporate)
    case personal(Personal)
}

extension ProfileState: Equatable where Corporate: Equatable, Personal: Equatable {}
