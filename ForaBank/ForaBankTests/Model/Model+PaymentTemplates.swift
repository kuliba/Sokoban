//
//  ModelPaymentTemplates.swift
//  ForaBankTests
//
//  Created by Dmitry Martynov on 23.06.2023.
//
/*
import XCTest
@testable import ForaBank

final class ModelPaymentTemplatesTests: XCTestCase {
    
    //данные содержат один шаблон
    //кэш пустой
    //выход должен содержать ту же одну картинку, что в данных (в кэш добавляется)

    func test_reduceImages_withEmptyCache() async throws {
         
        let templatesData = try getTemplatesDataFromJson()
        XCTAssertEqual(templatesData.count, 1)
            
        let images = [String: ImageData]()
            
        
            let sut = Model.reduce
            let sutData = await sut(images, templatesData)
            
            let sutImageData = try XCTUnwrap(sutData["Template\(templatesData[0].id)"])
            
            XCTAssertEqual(sutData.count, 1)
            XCTAssertEqual(sutImageData, try imageData(templateData: templatesData.first))
        
    }
    
    private func imageData(templateData: PaymentTemplateData?) throws -> ImageData {
        
        let templateData = try XCTUnwrap(templateData)
        let svgImageData = try XCTUnwrap(templateData.svgImage)
        
        return try XCTUnwrap(ImageData(with: svgImageData))
    }
    
    //данные содержат один шаблон
    //кэш содержит одну ту же картинку, что в данных
    //выход должен содержать ту же одну картинку, что в данных (кэш не меняется)

    func test_reduceImages_CacheWithOneImage() throws {
         
        let temlatesData = try getTemplatesDataFromJson()
        XCTAssertEqual(temlatesData.count, 1)
            
        let images = try getImages(svgString: [Self.fistSVG])
        XCTAssertEqual(images.count, 1)
            
        Task {
                
            let sut = await Model.reduce(images: images, with: temlatesData)
                
            let firstData = try XCTUnwrap(temlatesData.first)
            let svgImageData = try XCTUnwrap(firstData.svgImage)
            let imgData = try XCTUnwrap(ImageData(with: svgImageData))
                
            let firstSutImage = try XCTUnwrap(sut["Template\(firstData.id)"])
                
            XCTAssertEqual(sut.count, 1)
            XCTAssertEqual(firstSutImage, imgData)
        }
           
    }
    
    //данные содержат один шаблон
    //кэш содержит одну ту же картинку, что в данных и еще картинку
    //выход должен содержать ту же одну картинку, что в данных (удаление изкэша)

    func test_reduceImages_CacheWithTwoImages() throws {
        
        let temlatesData = try getTemplatesDataFromJson()
        XCTAssertEqual(temlatesData.count, 1)
        
        let images = try getImages(svgString: [Self.fistSVG, Self.secondSVG])
        XCTAssertEqual(images.count, 2)
        
        Task {
            
            let sut = await Model.reduce(images: images, with: temlatesData)
            
            let firstData = try XCTUnwrap(temlatesData.first)
            let svgImageData = try XCTUnwrap(firstData.svgImage)
            let imgData = try XCTUnwrap(ImageData(with: svgImageData))
            
            let firstSutImage = try XCTUnwrap(sut["Template\(firstData.id)"])
            
            XCTAssertEqual(sut.count, 1)
            XCTAssertEqual(firstSutImage, imgData)
        }
    }
    
}

//MARK: Helpers

private extension ModelPaymentTemplatesTests {
    
    func getTemplatesDataFromJson() throws -> [PaymentTemplateData] {
        
        let bundle = Bundle(for: ModelPaymentTemplatesTests.self)
        let decoder = JSONDecoder()
        let url = bundle.url(forResource: "PaymentTemplatesListWithSVG", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        return try decoder.decode([PaymentTemplateData].self, from: json)
        
    }
    
    func getImages(svgString: [String]) throws -> [String: ImageData] {
        
        var images = [String: ImageData]()
        
        for index in svgString.indices {
            
            let svgData = SVGImageData(description: svgString[index])
            let imgData = try XCTUnwrap(ImageData(with: svgData))
            
            images["Template\(index)"] =  imgData
        }
        return images
    }
    
    static let fistSVG =
    "<svg width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\">\n<path d=\"M9.61034 8.43286L8.39062 15.5906H10.3414L11.5621 8.43286H9.61034Z\" fill=\"#1434CB\"/>\n<path d=\"M6.75416 8.44096L4.84355 13.3223L4.63985 12.5853C4.26304 11.6972 3.19334 10.4218 1.9375 9.61803L3.68454 15.5872L5.74868 15.5837L8.82081 8.43945L6.75416 8.44096Z\" fill=\"#1434CB\"/>\n<path d=\"M3.89949 8.95334C3.78609 8.51733 3.45746 8.38738 3.04955 8.37183H0.0250868L0 8.51432C2.35364 9.08529 3.91103 10.4611 4.55726 12.1153L3.89949 8.95334Z\" fill=\"#1434CB\"/>\n<path d=\"M15.5142 9.80523C16.1524 9.79519 16.615 9.93468 16.9743 10.0792L17.1504 10.162L17.4143 8.6106C17.028 8.4656 16.4224 8.31006 15.6667 8.31006C13.7391 8.31006 12.3804 9.28092 12.3698 10.6722C12.3573 11.7003 13.3377 12.2743 14.0783 12.617C14.8384 12.9682 15.0933 13.1914 15.0898 13.505C15.0837 13.9842 14.4837 14.2039 13.9232 14.2039C13.142 14.2039 12.7271 14.0961 12.0864 13.8291L11.835 13.7148L11.5605 15.3168C12.0171 15.517 12.8595 15.6891 13.7341 15.6981C15.7847 15.6981 17.1173 14.7388 17.1313 13.2522C17.1398 12.4388 16.6195 11.8182 15.4921 11.3089C14.8098 10.9768 14.3923 10.756 14.3964 10.4209C14.3964 10.1233 14.7506 9.80523 15.5142 9.80523Z\" fill=\"#1434CB\"/>\n<path d=\"M22.4219 8.44092H20.9146C20.4465 8.44092 20.0983 8.56836 19.8926 9.03497L16.9961 15.5947H19.0447C19.0447 15.5947 19.3788 14.7126 19.4546 14.5194C19.6789 14.5194 21.6693 14.5224 21.9527 14.5224C22.0109 14.7723 22.1906 15.5947 22.1906 15.5947H24.0003L22.4219 8.44092ZM20.016 13.0544C20.1766 12.6434 20.7932 11.054 20.7932 11.054C20.7827 11.0735 20.9523 10.64 21.0531 10.3706L21.1846 10.9877C21.1846 10.9877 21.5584 12.6966 21.6366 13.0544H20.016Z\" fill=\"#1434CB\"/>\n</svg>"
    
    
    
    
    
    static let secondSVG =
    "<svg width=\"32\" height=\"32\" viewBox=\"0 0 32 32\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\">\n<rect y=\"5\" width=\"32\" height=\"22\" rx=\"3\" fill=\"#FF3636\"/>\n<g clip-path=\"url(#clip0)\">\n<path d=\"M5 10.5C5 10.2239 5.22386 10 5.5 10H9.5C9.77614 10 10 10.2239 10 10.5V11.8557C10 11.9744 9.83338 12.0308 9.75526 11.9414C9.3714 11.5021 8.56071 10.752 7.5 10.752C6.43929 10.752 5.6286 11.5021 5.24474 11.9414C5.16662 12.0308 5 11.9744 5 11.8557V10.5Z\" fill=\"white\"/>\n<path d=\"M5 14.7431C5 14.8871 5.11678 15.0039 5.26084 15.0039H9.73916C9.88322 15.0039 10 14.8871 10 14.7431V14.7431C10 14.7348 9.99724 14.7273 9.99125 14.7216C9.89001 14.6245 8.91861 13.7301 7.5 13.7301C6.08139 13.7301 5.10999 14.6245 5.00875 14.7216C5.00276 14.7273 5 14.7348 5 14.7431V14.7431Z\" fill=\"white\"/>\n<path d=\"M5 13.4207C5 13.5175 5.10972 13.5763 5.1917 13.5248C5.61983 13.2561 6.68048 12.6472 7.5 12.6472C8.31955 12.6472 9.38023 13.2558 9.80833 13.5243C9.89031 13.5757 10 13.5169 10 13.4201V13.1861C10 13.1282 9.9805 13.0727 9.94118 13.0302C9.70656 12.7763 8.78745 11.8805 7.5 11.8805C6.21255 11.8805 5.29344 12.7763 5.05882 13.0302C5.0195 13.0727 5 13.1282 5 13.1861V13.4207Z\" fill=\"white\"/>\n</g>\n<defs>\n<clipPath id=\"clip0\">\n<rect x=\"5\" y=\"10\" width=\"5\" height=\"5.00391\" rx=\"1\" fill=\"white\"/>\n</clipPath>\n</defs>\n</svg>"
}
*/
