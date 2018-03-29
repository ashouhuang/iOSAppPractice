//
//  Spot.swift
//  iOSAppPractice
//
//  Created by Carter on 2018/3/29.
//  Copyright © 2018年 Carter. All rights reserved.
//

import Foundation
import UIKit

protocol JSONFormatter {
    associatedtype T
    static func formatter(from jsonDictionary: [AnyHashable: Any] ) -> T?
}

public struct Spot {
    let ParkName: String
    let Name: String
    let OpenTime: String?
    let Image: String?
    let Introduction: String?
}

extension Spot: JSONFormatter {
    typealias T = Spot
    static func formatter(from jsonDictionary: [AnyHashable : Any]) -> Spot? {
        
        if let pn = jsonDictionary["ParkName"] as? String,
           let name = jsonDictionary["Name"] as? String,
           let intro = jsonDictionary["Introduction"] as? String {
            
            return Spot(
                ParkName: pn,
                Name: name,
                OpenTime: jsonDictionary["OpenTime"] as? String,
                Image: jsonDictionary["Image"] as? String,
                Introduction: intro)
        }
        else {
            return nil
        }
    }
}
