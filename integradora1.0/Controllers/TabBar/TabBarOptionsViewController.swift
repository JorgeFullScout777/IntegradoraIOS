//
//  TabBarOptionsViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 17/04/24.
//

import UIKit

class TabBarOptionsViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllers?[2].tabBarItem.isEnabled = false
        getRol()
    }
    
    func isAdmin(ID:Int){
        print(ID)
        UserDefaults().setValue(ID, forKey: "rolId")
        if(ID != 2){
            DispatchQueue.main.async{
                self.viewControllers?[2].tabBarItem.isEnabled = true
                self.viewControllers?.removeLast()
            }
        }
        else{
            DispatchQueue.main.async{
                self.viewControllers?[2].tabBarItem.isEnabled = true

            }
        }
    }
    
    func getRol() {
        let session = URLSession.shared
        let url = URL(string: "http://\(ApplicationConfiguration.direccionIP)/api/auth/getrol")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la solicitud POST: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("Código de estado HTTP de la respuesta: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 401{
                    DispatchQueue.main.async{
                        self.present(ApplicationConfiguration.closeApp(), animated: true)
                    }
                }
                if let data = data {
                    if let dataString = String(data: data, encoding: .utf8) {
                        if let intValue = Int(dataString) {
                            self.isAdmin(ID: intValue)
                        } else {
                            print("No se pudo convertir el dato a un entero")
                        }
                    } else {
                        print("No se pudo convertir los datos a un string")
                    }
                }
            }
        }
        task.resume()
    }

}
