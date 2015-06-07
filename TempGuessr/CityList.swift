//
//  CityList.swift
//  TempGuessr
//
//  Created by Mark J Bradburn on 6/6/15.
//  Copyright (c) 2015 Mark J Bradburn. All rights reserved.
//

import Foundation

struct CityList {
    static var city : [String] = [
        "New York City, New York",
        "Tokyo, Japan"
//        "Rio De Janeiro, Brazil",
//        "Jakarta, Indonesia",
//        "London, United Kingdom"
    ]
}

struct Player {
    enum Type {
        case first
        case second
    }
}
