//
//  TransferAbroadResponseData.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 06.12.2022.
//

struct TransferAbroadResponseData: Codable, Equatable {
    
    let serial: String
    let main: MainTransferData
    let directionsDetailList: [DirectionDetailData]
    let bannersDetailList: [BannerDetailData]
    let countriesDetailList: CountryDetailData
}

// MARK: - Main

extension TransferAbroadResponseData {
    
    struct MainTransferData: Codable, Equatable {
        
        let title: String
        let subTitle: String
        let legalTitle: String
        let promotion: [PromotionTransferData]
        let directions: DirectionTransferData
        let bannerCatalogList: [BannerCatalogListData]
        let info: InfoTransferData
        let countriesList: CountriesListData
        let advantages: AdvantageTransferData
        let questions: QuestionTransferData
        let support: SupportTransferData
    }
}

extension TransferAbroadResponseData {
    
    struct PromotionTransferData: Codable, Equatable {
        
        let iconType: IconType
        let title: String
        
        enum IconType: String, Codable, Equatable {
            
            case quickly
            case safely
            case profitably
        }
    }
    
    struct DirectionTransferData: Codable, Equatable {
        
        let title: String
        let countriesList: [CountriesList]
        
        struct CountriesList: Codable, Equatable {
            
            let code: String
            let rate: String
        }
    }
    
    struct InfoTransferData: Codable, Equatable {
        
        let md5hash: String
        let title: String
    }
    
    struct CountriesListData: Codable, Equatable {
        
        let title: String
        let codeList: [String]
    }
    
    struct AdvantageTransferData: Codable, Equatable {
        
        let title: String
        let content: [ContentData]
        
        struct ContentData: Codable, Equatable {
            
            let title: String
            let description: String
            let iconType: String 
        }
    }
    
    struct QuestionTransferData: Codable, Equatable {
        
        let title: String
        let content: [ContentData]
        
        struct ContentData: Codable, Equatable {
            
            let title: String
            let description: String
        }
    }
    
    struct SupportTransferData: Codable, Equatable {
        
        let title: String
        let content: [ContentData]
        
        struct ContentData: Codable, Equatable {
            
            let iconType: String
            let title: String
        }
    }
}

// MARK: - Details

extension TransferAbroadResponseData {
    
    struct DirectionDetailData: Codable, Equatable {
        
        let code: String
        let transfersMoney: MoneyData?
        let commission: ContentData
        let sending: ContentData
        let receiving: ContentData
        let banksList: [String]?
        
        struct MoneyData: Codable, Equatable {
            
            let md5hash: String
            let title: String
        }
        
        struct ContentData: Codable, Equatable {
            
            let title: String
            let description: String
        }
    }
    
    struct BannerDetailData: Codable, Equatable {
        
        let countryId: String
        let type: BannerActionType
        let title: String?
        let info: String?
        let list: [ListData]?
        let transfersMoney: MoneyData?
        let promoInfo: [String]?
        let freeCard: FreeCardData?
        let advantages: [AdvantageTransferData.ContentData]?
        let banksList: [String]?
        let promoTerms: [String]?
        
        struct MoneyData: Codable, Equatable {
            
            let md5hash: String
            let title: String
        }
        
        struct FreeCardData: Codable, Equatable {
            
            let title: String?
            let md5hash: String?
        }
        
        struct ListData: Codable, Equatable {
            
            let iconType: IconType?
            let title: String?
            let description: String?
            
            enum IconType: String, Codable, Equatable {
                
                case cash
                case limit
                case commission
                case sending
                case offer
            }
        }
    }
    
    struct CountryDetailData: Codable, Equatable {
        
        let title: String
        let codeList: [String]
    }
}
