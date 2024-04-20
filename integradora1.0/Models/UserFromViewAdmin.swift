//
//  UserFromViewAdmin.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 20/04/24.
//

import UIKit

class UserFVA: NSObject {
    var id:Int
    var rolId:Int
    var nameUsuario:String
    var emailUsuario:String
    var status:Bool
    
    init(id: Int, rolId: Int, nameUsuario: String, emailUsuario: String, status: Bool) {
        self.id = id
        self.rolId = rolId
        self.nameUsuario = nameUsuario
        self.emailUsuario = emailUsuario
        self.status = status
    }
    
    
}
