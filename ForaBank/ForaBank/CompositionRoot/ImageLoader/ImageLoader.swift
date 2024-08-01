//
//  ImageLoader.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.06.2024.
//

import ForaTools
import SwiftUI

typealias ImageLoader = ForaTools.Loader<String, Result<(String, Image), Error>>
