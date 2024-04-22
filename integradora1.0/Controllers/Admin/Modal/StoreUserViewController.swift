//
//  StoreUserViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 21/04/24.
//

import UIKit

protocol StoreUserViewControllerDelegate: AnyObject {
    func backButtonPressedStore()
}

class StoreUserViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    weak var delegate:StoreUserViewControllerDelegate?
    @IBOutlet weak var txfNombre: UITextField!
    @IBOutlet weak var lblNombreErrors: UILabel!
    @IBOutlet weak var txfCorreo: UITextField!
    @IBOutlet weak var lblCorreoErrors: UILabel!
    @IBOutlet weak var txfContraseña: UITextField!
    @IBOutlet weak var lblContraseñaErrors: UILabel!
    @IBOutlet weak var txfConfirmacion: UITextField!
    @IBOutlet weak var lblConfirmacionErrors: UILabel!
    @IBOutlet weak var pkvRol: UIPickerView!
    @IBOutlet weak var swtIsActive: UISwitch!
    @IBOutlet weak var lblIsActive: UILabel!
    @IBOutlet weak var btnConfirmar: UIButton!
    @IBOutlet weak var btnCancelar: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        btnConfirmar.layer.cornerRadius = 25
        btnCancelar.layer.cornerRadius = 25
        setup()

    }
    
    func setup(){
        txfNombre.delegate = self
        txfCorreo.delegate = self
        txfContraseña.isSecureTextEntry = true
        txfContraseña.delegate = self
        txfConfirmacion.isSecureTextEntry = true
        txfConfirmacion.delegate = self
        pkvRol.dataSource = self
        pkvRol.delegate = self
    }

    @IBAction func Confirmar() {
        let url = URL(string: "http://\(ApplicationConfiguration.direccionIP)/api/v1/users/store")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token")!)"]
        let parameters: [String: Any] = [
            "name": txfNombre.text!,
            "email": txfCorreo.text!,
            "password": txfContraseña.text!,
            "password_confirmation": txfConfirmacion.text!,
            "status": swtIsActive.isOn,
            "rol_id": pkvRol.selectedRow(inComponent: 0) + 1
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            print("Error al convertir los parámetros a JSON: \(error.localizedDescription)")
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la solicitud POST: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("Código de estado HTTP de la respuesta: \(httpResponse.statusCode)")
                if let data = data {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                        if httpResponse.statusCode == 201{
                            DispatchQueue.main.async{
                                self.lblNombreErrors.text = ""
                                self.lblCorreoErrors.text = ""
                                self.lblContraseñaErrors.text = ""
                                self.delegate?.backButtonPressedStore()
                                let alerta = UIAlertController(title: "Usuario creado", message: "El usuario ha sido creado exitosamente", preferredStyle: .alert)
                                alerta.addAction(UIAlertAction(title: "Aceptar", style: .default){accion in
                                    self.dismiss(animated: true)
                                })
                                self.present(alerta, animated: true)
                            }
                        }
                        if httpResponse.statusCode == 401{
                            DispatchQueue.main.async{
                                let alerta = UIAlertController(title: "Ha ocurrido algo", message: "Vuelve a iniciar sesion", preferredStyle: .alert)
                                let aceptar = UIAlertAction(title: "Aceptar", style: .default){accion in
                                    self.present(ApplicationConfiguration.login(), animated: true)
                                }
                                alerta.addAction(aceptar)
                                self.present(alerta, animated: true)
                            }
                        }
                        if httpResponse.statusCode == 403{
                            DispatchQueue.main.async{
                                let alerta = UIAlertController(title: "Ha ocurrido algo", message: "No tienes permisos suficientes", preferredStyle: .alert)
                                let aceptar = UIAlertAction(title: "Aceptar", style: .default){accion in
                                    self.present(ApplicationConfiguration.home(), animated: true)
                                }
                                alerta.addAction(aceptar)
                                self.present(alerta, animated: true)
                            }
                        }
                        if httpResponse.statusCode == 422 {
                            if let errores = jsonResponse["errors"] as? [String:[String]]{
                                DispatchQueue.main.async {
                                    if let nameError = errores["name"]?.first {
                                        self.lblNombreErrors.text = nameError
                                    }
                                    else{
                                        self.lblNombreErrors.text = ""
                                    }
                                    if let emailError = errores["email"]?.first {
                                        self.lblCorreoErrors.text = emailError
                                    }
                                    else{
                                        self.lblCorreoErrors.text = ""
                                    }
                                    if let passwordError = errores["password"]?.first {
                                        self.lblContraseñaErrors.text = passwordError
                                    }
                                    else{
                                        self.lblContraseñaErrors.text = ""
                                    }
                                }
                            }
                            
                        }
                    } catch {
                        print("Error al convertir los datos de la respuesta a JSON: \(error.localizedDescription)")
                    }
                }
            }
        }
        task.resume()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func Cancelar() {
        dismiss(animated: true)
    }
    
    @IBAction func Back() {
        dismiss(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ["Usuario", "Administrador"][row]
    }
    @IBAction func IsActive() {
        if swtIsActive.isOn{
            lblIsActive.text = "Activo"
        }
        else{
            lblIsActive.text = "Desactivado"
        }
    }
}
