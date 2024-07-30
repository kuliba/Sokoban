//
//  PaymentCompletionConfig.swift
//
//
//  Created by Igor Malyarov on 30.07.2024.
//

import SharedConfigs
import SwiftUI

struct PaymentCompletionConfig: Equatable {
    
    let statuses: Statuses
    
    struct Statuses: Equatable {
        
        let completed: Status
        let inflight: Status
        let rejected: Status
        let fraudCancelled: Status
        let fraudExpired: Status
        
        struct Status: Equatable {
 
            let content: Content
            let config: Config
            
            struct Content: Equatable {
                
                let logo: Image
                let title: String
                let subtitle: String?
            }
            
            struct Config: Equatable {
                
                let amount: TextConfig
                let icon: Icon
                let logoHeight: CGFloat
                let title: TextConfig
                let subtitle: TextConfig
                
                struct Icon: Equatable {
                    
                    let foregroundColor: Color
                    let backgroundColor: Color
                    let innerSize: CGSize
                    let outerSize: CGSize
                }
            }
        }
    }
}
