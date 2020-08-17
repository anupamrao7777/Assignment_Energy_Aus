//
//  ConstantValues.swift
//  CollapseTableView
//
//  Created by Anupam Rao on 13/8/20.
//  Copyright © 2020 Serhii Kharauzov. All rights reserved.
//

import Foundation
class ConstantValues : NSObject{
    
    struct Constants {
        static let Music_Festival_Url = "http://eacodingtest.digital.energyaustralia.com.au/api/v1/festivals"
        static let bandCellIdentifier = "customCell"
        static let noInternetConnectivityTitle = "Network unreachable!"
        static let noInternetConnectivityMessage = "Please check your internet connectivity and try again"
        static let openStateImageName = "whiteOpen"
        static let closedStateImageName = "whiteClose"
        static let parsingErrorTitle = "Data not correct!"
        static let reachabilitIssue  = "Reachability is not working."
        static let alertButtonOk  = "OK"
        static let serverError = "Server error !"
    }
}
