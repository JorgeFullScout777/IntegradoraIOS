//
//  RegisterViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 08/03/24.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var scrRegister: UIScrollView!
    
    @IBOutlet var txfname: UITextField!
    
    @IBOutlet var txfpassword: UITextField!
    @IBOutlet var txfemail: UITextField!
    @IBOutlet var errorname: UILabel!
    
    @IBOutlet var txfpassword_confirmation: UITextField!
    @IBOutlet var errorpassword: UILabel!
    @IBOutlet var erroremail: UILabel!
    
    @IBOutlet var errorconfirmation: UILabel!
    @IBOutlet weak var btnRegister: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        btnRegister.layer.cornerRadius = 20
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrRegister.contentSize = CGSize(width: 0, height: 548)
    }
    
    
    @IBAction func registro() {
        let nombre = txfname.text!
        let correo = txfemail.text!
        let password = txfpassword.text!
        let confirmacion = txfpassword_confirmation.text!
        
        let url = URL(string: "http://\(ApplicationConfiguration.direccionIP)/api/auth/register")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: String] = [
            "name": nombre,
            "email": correo,
            "password": password,
            "password_confirmation":confirmacion
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            request.httpBody = jsonData

            //se utilizo sesion para hacer las peticiones
            let session = URLSession.shared

            let task = session.dataTask(with: request) { (data, response, error) in
                // Handle successful response
                guard let data = data else {
                    print("No data received from server")
                    return
                }
                // Verificar el código de respuesta HTTP
                if let httpResponse = response as? HTTPURLResponse {
                    print("se recibio respuesta")
                        do {
                            print("Entarndo en el do")
                            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                            if let responseDictionary = jsonResponse as? [String: Any] {
                                print("Procesando codigos de estado")
                                if httpResponse.statusCode == 200{
                                    print("Estado 200")
                                    let message = responseDictionary["msg"] as? String
                                    DispatchQueue.main.async {
                                        // Mostrar un mensaje de alerta en lugar de usar el label
                                        let alert = UIAlertController(title: "¡Registro exitoso!", message: message, preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { _ in
                                            self.dismiss(animated: true)
                                        }))
                                        self.present(alert, animated: true)
                                    }
                                }
                                if httpResponse.statusCode == 422{
                                    if let errores = responseDictionary["errors"] as? [String:String]{
                                        if let name = errores["name"]{
                                            
                                        }
                                    }
                                }

                                
                            } else {
                                print("Invalid JSON response")
                            }
                        } catch {
                            
                            print("Error parsing JSON response:", error)
                        }
                } // Fin de la validación del código de respuesta HTTP
            }

            task.resume()
        } catch {
            print("Error al codificar los parámetros JSON:", error)
        }
        
    }
    

    @IBAction func btnBack() {
        dismiss(animated: true)
    }
    

}
