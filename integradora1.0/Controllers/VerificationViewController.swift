//
//  VerificationViewController.swift
//  integradora1.0
//
//  Created by imac on 09/04/24.
//

import UIKit

class VerificationViewController: UIViewController {
    
    
    @IBOutlet var txfcodigo: UITextField!
    
    @IBOutlet var lblerrores: UILabel!
    var correo:String!
    var contraseña:String!
    var estado = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(correo!)
        print(contraseña!)
    }
    
    @IBAction func verificarcodigo() {
        let correo = correo!
        let password = contraseña!
        let codigo =  txfcodigo.text!


        let url = URL(string: "http://192.168.80.109:8000/api/auth/login")!

        // Crear la solicitud con codificación JSON
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: String] = [
            "email": correo,
            "password": password,
            "code": codigo
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            request.httpBody = jsonData

            // Use URLSession for requests
            let session = URLSession.shared

            let task = session.dataTask(with: request) { (data, response, error) in


                // Handle successful response
                guard let data = data else {
                    print("No data received from server")
                    return
                }

                // Verificar el código de respuesta HTTP
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        // Procesar la respuesta exitosa
                        do {
                            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                            if let responseDictionary = jsonResponse as? [String: Any] {
                                let token = responseDictionary["access_token"] as? String
                                let tokentype = responseDictionary["token_type"] as? String
                               
                                    DispatchQueue.main.async {
                                        // Mostrar la alerta y realizar el segue
                                        print(token!, httpResponse)
                                        print(tokentype!)
                                            self.estado = true
                                            self.performSegue(withIdentifier: "sginicio", sender: nil)
                                    }
                                    
                            } else {
                                print("Invalid JSON response")
                            }
                        } catch {
                                
                            print("Error parsing JSON response:", error)
                        }
                    } else {
                        //aca pondremos los errores
                        print("Error: código de respuesta \(httpResponse.statusCode)")
                    }
                }
            }

            task.resume()
        } catch {
            print("Error encoding JSON parameters:", error)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "sginicio" && estado == false{
            return false
        }
        
        return true
    }
    
}
