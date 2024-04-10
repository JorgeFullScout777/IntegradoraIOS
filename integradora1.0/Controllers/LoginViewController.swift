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
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Blur Imagen
        /*let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = imgBackground.bounds
        imgBackground.addSubview(blurEffectView)*/
        
        //Redondeo Contenedor
        viewBackgroundInputs.layer.cornerRadius = 20
        
        //Redonde Botones
        for boton in btnsLogin{
            boton.layer.cornerRadius = 20
            boton.layer.borderWidth = 4.0
            boton.layer.borderColor = btnsLogin[0].backgroundColor?.cgColor
        }
        
        txfPassword.isSecureTextEntry = true
        btnIniciarSesion.isEnabled = false
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
        print("OK")
        
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

        // Validación de email
        /*
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: correo) {
            labelerrors.text = "Formato de email inválido."
            return
        }
        */

        let url = URL(string: "http://192.168.80.109:8000/api/auth/login")!

        // Crear la solicitud con codificación JSON
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
                                    self.labelerrors.text = message
                                    //aqui en vez de ser con el label sera con alert para que la funcion delsegue me mande a la pantalla de verificar
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


}
