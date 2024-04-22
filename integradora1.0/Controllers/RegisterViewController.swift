//
//  RegisterViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 08/03/24.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

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
        setup()
    }
    
    func setup(){
        btnRegister.layer.cornerRadius = 20
        txfpassword.isSecureTextEntry = true
        txfpassword_confirmation.isSecureTextEntry = true
        txfname.delegate = self
        txfemail.delegate = self
        txfpassword.delegate = self
        txfpassword_confirmation.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrRegister.contentSize = CGSize(width: 0, height: 548)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func btnEnable(){
        DispatchQueue.main.async {
            self.btnRegister.isEnabled = true
            self.btnRegister.alpha = 1.0
        }
    }
    
    func btnDisabled(){
        DispatchQueue.main.async{
            self.btnRegister.isEnabled = false
            self.btnRegister.alpha = 0.5
        }
    }
    
    
    @IBAction func registro() {
        btnDisabled()
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
                                if httpResponse.statusCode == 201{
                                    print("Estado 201")
                                    DispatchQueue.main.async{
                                        self.errorname.text = ""
                                        self.erroremail.text = ""
                                        self.errorpassword.text = ""
                                    }
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
                                if httpResponse.statusCode == 422 {
                                    if let errores = responseDictionary["errors"] as? [String:[String]] {
                                        DispatchQueue.main.async {
                                            if let nameError = errores["name"]?.first {
                                                self.errorname.text = nameError
                                            }
                                            else{
                                                self.errorname.text = ""
                                            }
                                            if let emailError = errores["email"]?.first {
                                                self.erroremail.text = emailError
                                            }
                                            else{
                                                self.erroremail.text = ""
                                            }
                                            if let passwordError = errores["password"]?.first {
                                                self.errorpassword.text = passwordError
                                            }
                                            else{
                                                self.errorpassword.text = ""
                                            }
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
                self.btnEnable()
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
