//
//  Sensor.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 21/04/24.
//

import UIKit

class Sensor: NSObject {
    
    var name:String
    var date:String
    var unit:String
    var value:Int
    
    init(name: String, date: String, unit: String, value: Int) {
        self.name = name
        self.date = date
        self.unit = unit
        self.value = value
    }

}
