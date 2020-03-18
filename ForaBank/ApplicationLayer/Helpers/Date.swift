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
