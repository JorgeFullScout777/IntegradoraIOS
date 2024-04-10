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
        
        let url = URL(string: "http://192.168.80.109:8000/api/auth/register")!
        
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
                
                // Manejar errores
                /*if let error = error {
                    print("Error:", error.localizedDescription)
                    DispatchQueue.main.async {
                        self.labelerrors.text = "Error: \(error.localizedDescription)"
                    }
                    return
                }*/

                // Manejar la respuesta exitosa
                if let data = data {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        if let responseDictionary = jsonResponse as? [String: Any] {
                            // Procesar el diccionario de respuesta
                            if let message = responseDictionary["msg"] as? String {
                                DispatchQueue.main.async {
                                    // Mostrar un mensaje de alerta en lugar de usar el label
                                    let alert = UIAlertController(title: "¡Registro exitoso!", message: message, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { _ in
                                    // Función para realizar el segue a la pantalla de verificar, esto cuando ya tengas la pantalla de verificar
                                    //self.performSegue(withIdentifier: "SegueToVerify", sender: self)
                                            }))
                                    self.present(alert, animated: true)
                                }
                            } else {
                                print("No se encontró mensaje en la respuesta")
                            }
                        } else {
                            print("Respuesta JSON inválida")
                        }
                    } catch {
                        print("Error al analizar la respuesta JSON:", error)
                    }
                } else {
                    print("No se recibieron datos del servidor")
                }
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
