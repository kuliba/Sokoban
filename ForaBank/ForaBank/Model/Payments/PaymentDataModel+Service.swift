//
//  PaymentDataModel+Service.swift
//  ForaBank
//
//  Created by Max Gribov on 07.02.2022.
//

import Foundation

extension Payments.Service {
    
    typealias Operator = Payments.Operator
    typealias Service = Payments.Service
    
    enum Kind: Identifiable {

        case taxes(Taxes)
        
        enum Taxes {
            
            case fssp(FSSP)
            case fms(FMS)
            case fns(FNS)
            
            enum FSSP {
                
                case category
            }
            
            enum FMS {
                
                case category
            }
            
            enum FNS {
                
                case category
                case uin
            }
        }
        
        var id: Identifier {
            
            switch self {
            case .taxes(let taxes):
                switch taxes {
                case .fssp(let fssp):
                    switch fssp {
                    case .category: return .init(operatorId: "iFora||5429", serviceId: "a3_SearchType_1_1")
                    }
                case .fms(let fms):
                    switch fms {
                    case .category: return .init(operatorId: "iFora||6887", serviceId: "a3_dutyCategory_1_1")
                    }
                case .fns(let fns):
                    switch fns {
                    case .category: return .init(operatorId: "iFora||6273", serviceId: "a3_dutyCategory_1_1")
                    case .uin: return .init(operatorId: "iFora||7069", serviceId: "a3_BillNumber_1_1")
                    }
                }
            }
        }
        
        init?(with puref: String, id: String) {
            
            switch (puref, id) {
            case ("iFora||5429", "a3_SearchType_1_1"): self = .taxes(.fssp(.category))
            case ("iFora||6887", "a3_dutyCategory_1_1"): self = .taxes(.fms(.category))
            case ("iFora||6273", "a3_dutyCategory_1_1"): self = .taxes(.fns(.category))
            case ("iFora||7069", "a3_BillNumber_1_1"): self = .taxes(.fns(.uin))
                
            default:
                return nil
            }
        }
        
        struct Identifier: Hashable {
            
            let operatorId: Operator.ID
            let serviceId: Service.ID
        }
    }
}
