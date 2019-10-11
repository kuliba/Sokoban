//
//  ILogger.swift
//  Anna
//
//  Created by Igor on 17/10/2017.
//  Copyright © 2017 Anna Financial Service Ltd. All rights reserved.
//

import UIKit

protocol ILogger {
    func setup()

    func write(string: String?)
    func write(string: String?, file: String?, function: String?, line: Int?)
    func write(string: String?, file: String?, line: Int?)
}
