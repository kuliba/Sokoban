//
//  CompanyData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct CompanyData: Codable, Equatable {
    
    let address: AddressDataItem?
    let authorities: String?
    let branchCount: String?
    let branchType: String?
    let capital: String?
    let documents: String?
    let emails: String?
    let employeeCount: String?
    let finance: FinanceData?
    let founders: String?
    let hid: String?
    let inn: String?
    let kpp: String?
    let licenses: String?
    let management: CompanyManagement?
    let managers: String?
    let name: CompanyName?
    let ogrn: String?
    let ogrnDate: String?
    let okpo: String?
    let okved: String?
    let okvedType: String?
    let okveds: String?
    let opf: CompanyOpf?
    let phones: String?
    let qc: String?
    let source: String?
    let state: StateData?
    let type: String?
    
    struct CompanyOpf: Codable, Equatable {
        
        let code: String?
        let full: String?
        let short: String?
        let type: String?
    }
    
    struct CompanyName: Codable, Equatable {
        
        let full: String?
        let fullWithOpf: String?
        let latin: String?
        let short: String?
        let shortWithOpf: String?
    }
    
    struct CompanyManagement: Codable, Equatable {
        
        let disqualified: String?
        let name: String?
        let post: String?
    }
    
    struct FinanceData: Codable, Equatable {
        
        let debt: String?
        let expense: String?
        let income: String?
        let penalty: String?
        let taxSystem: String?
    }
}
