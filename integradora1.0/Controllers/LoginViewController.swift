//
//  LoginViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 10/03/24.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txfPassword: UITextField!
    @IBOutlet weak var txfCorreo: UITextField!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet var labelerrors: UILabel!
    @IBOutlet weak var viewBackgroundInputs: UIView!
    @IBOutlet weak var btnIniciarSesion: UIButton!
    @IBOutlet var btnsLogin: [UIButton]!
    var estado = false
    var errores:[String:Any] = [:]
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Blur Imagen
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = imgBackground.bounds
        imgBackground.addSubview(blurEffectView)
        
        //Redondeo Contenedor
        viewBackgroundInputs.layer.cornerRadius = 20
        
        //Redonde Botones
        for boton in btnsLogin{
            boton.layer.cornerRadius = 20
            boton.layer.borderWidth = 4.0
            boton.layer.borderColor = btnsLogin[0].backgroundColor?.cgColor
        }
        
        txfPassword.isSecureTextEntry = true
        //btnIniciarSesion.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == txfCorreo{
            txfPassword.becomeFirstResponder()
        }
        else{
            txfPassword.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (txfCorreo.text)!.count > 1 && (txfPassword.text)!.count > 1 {
            btnIniciarSesion.isEnabled = true
        }
        else{
            btnIniciarSesion.isEnabled = false
        }
    }
    

    
    @IBAction func IniciarSesion() {
        let correo = txfCorreo.text!
        let password = txfPassword.text!

        let url = URL(string: "http://\(ApplicationConfiguration.direccionIP)/api/auth/login")!

        // Create the request with JSON encoding
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: String] = [
            "email": correo,
            "password": password
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
                                        // Mostrar la alerta y realizar el segue
                                        print(message!, httpResponse)
                                        let alerta = UIAlertController(title: "Credenciales correctas", message: message, preferredStyle: .alert)
                                        alerta.addAction(UIAlertAction(title: "Continuar", style: .default, handler: { _ in
                                            self.estado = true
                                            self.performSegue(withIdentifier: "sgVerification", sender: nil)
                                        }))
                                        self.present(alerta, animated: true, completion: nil)
                                    }
                                
                                }
                                if httpResponse.statusCode == 401{
                                    print("Estado 401")
                                    DispatchQueue.main.async {
                                        self.labelerrors.text = "Las credenciales son incorrectas"
                                    }
                            }
                                if httpResponse.statusCode == 403{
                                    print("Esatdo 403")
                                    let message = responseDictionary["error"] as? String
                                    print(message!)
                                    DispatchQueue.main.async {
                                        self.labelerrors.text = message
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
            print("Error encoding JSON parameters:", error)
        }
    }



 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgVerification" {
                let vc = segue.destination as! VerificationViewController
                vc.correo = txfCorreo.text!
                vc.contraseña = txfPassword.text!
            }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "sgVerification" && estado == false{
            return false
        }
        
        return true
    }
}
