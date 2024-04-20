//
//  Planta.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 12/04/24.
//

import UIKit

class Planta: NSObject {
    
    let id:Int
    var name:String
    var status:Bool
    var image:UIImage?
    
    init(id:Int, name: String, status: Bool, image:UIImage?) {
        self.id = id
        self.name = name
        self.status = status
        self.image = image
    }
    
    

}
