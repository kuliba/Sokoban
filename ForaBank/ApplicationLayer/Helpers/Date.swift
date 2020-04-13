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

func getDateToDateMonthYear(date: Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/YY"
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
