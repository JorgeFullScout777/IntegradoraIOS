//
//  ApplicationConfiguration.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 12/04/24.
//

import UIKit

class ApplicationConfiguration: NSObject {
    
    static let direccionIP = "18.227.105.11:8000"
    
    static func closeApp() -> UIAlertController{
        UserDefaults.standard.set("", forKey: "token")
        let alert = UIAlertController(title: "No estas autorizado", message: "Vuelve a iniciar sesion", preferredStyle: .alert)
        let aceptar = UIAlertAction(title: "Aceptar", style: .default) { accion in
            exit(1)
        }
        alert.addAction(aceptar)
        return alert
    }
    
    static func login() -> UIViewController{
        UserDefaults.standard.set("", forKey: "token")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "loginView")
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
    
    static func home() -> UIViewController{
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TabBar")
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
    


}
