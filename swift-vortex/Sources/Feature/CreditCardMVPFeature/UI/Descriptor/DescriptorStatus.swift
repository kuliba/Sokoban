//
//  SwiftUIView.swift
//  
//
//  Created by Igor Malyarov on 31.03.2025.
//

public enum DescriptorStatus: Equatable {
    
    case loaded(Descriptor)
    case loading, placeholder
}
