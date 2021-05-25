//
//  Date.swift
//  ForaBank
//
//  Created by Бойко Владимир on 06/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation

func monthYear(milisecond: Double) -> String {
    let date = Date.init(timeIntervalSince1970: TimeInterval(milisecond) / 1000.0)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/YY"
    return dateFormatter.string(from: date)
}

func dayMonthYear(milisecond: Double) -> String {
    let date = Date.init(timeIntervalSince1970: TimeInterval(milisecond) / 1000.0)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy"
    return dateFormatter.string(from: date)
}

func dayMonthYear(data: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy"
    return dateFormatter.string(from: data)
}

func getDateCurrencys(data: Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    return dateFormatter.string(from: data)
}

func getDateToHours(_ data: Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.string(from: data)
}

func getDateToDateMonthYear(date: Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/YY"
    return dateFormatter.string(from: date)
}
func getDateToDate(date: Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
    return dateFormatter.string(from: date)
}

func getDateFromString(strTime: String?)-> Date{
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MM-yyyy HH:mm"
    //formatter.locale = Locale(identifier: "ru_RU")
    guard strTime != nil else{return Date()}
    guard let date = formatter.date(from: strTime!) else{return Date()}
    return date
}


func getDateFromFormate(date: Date, format: String)->String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.locale = Locale(identifier: "ru_RU")
    return dateFormatter.string(from: date)
}


func sortedCoverCard(numberCard: String?) -> UIImage{
    if numberCard?.prefix(6) == "465626" {
        let image = UIImage(named: "card_visa_gold")
        return image ?? UIImage(named: "card_visa_infinity")!
    }
    if numberCard?.prefix(6) == "457825" {
        let image  = UIImage(named: "card_visa_platinum")
        return image ?? UIImage(named: "card_visa_infinity")!
    }
    if numberCard?.prefix(6) == "425690" {
        let image = UIImage(named: "card_visa_debet")
        return image ?? UIImage(named: "card_visa_infinity")!
    }
    if numberCard?.prefix(6) == "557986" {
        let image = UIImage(named: "card_visa_standart")
        return image ?? UIImage(named: "card_visa_infinity")!
    }
    if numberCard?.prefix(6) == "536466" {
        let image = UIImage(named: "card_visa_virtual")
        return image ?? UIImage(named: "card_visa_infinity")!
    }
    if numberCard?.prefix(6) == "470336" {
        let image = UIImage(named: "card_visa_infinity")
    return image ?? UIImage(named: "card_visa_infinity")!
    }
    return UIImage(named: "card_visa_debet")!
}
