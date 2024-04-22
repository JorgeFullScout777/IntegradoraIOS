//
//  UpdateUserViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 21/04/24.
//

import UIKit

protocol UpdateUserViewControllerDelegate: AnyObject {
    func backButtonPressed(user:UserFVA)
}

class UpdateUserViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    weak var delegate:UpdateUserViewControllerDelegate?
    @IBOutlet weak var txfNombre: UITextField!
    @IBOutlet weak var txfCorreo: UITextField!
    @IBOutlet weak var txfContraseña: UITextField!
    @IBOutlet weak var pkvRoles: UIPickerView!
    @IBOutlet weak var swtIsActive: UISwitch!
    @IBOutlet weak var lblIsActive: UILabel!
    @IBOutlet weak var lblNombreErrors: UILabel!
    @IBOutlet weak var lblCorreoErrors: UILabel!
    @IBOutlet weak var lblContraseñaErrors: UILabel!
    @IBOutlet weak var btnConfirmar: UIButton!
    @IBOutlet weak var btnCancelar: UIButton!
    var user: UserFVA?
    var alertController: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup(){
        btnConfirmar.layer.cornerRadius = 25
        btnCancelar.layer.cornerRadius = 25
        txfNombre.delegate = self
        txfCorreo.delegate = self
        txfContraseña.delegate = self
        txfContraseña.isSecureTextEntry = true
        txfNombre.text = user?.nameUsuario
        txfCorreo.text = user?.emailUsuario
        swtIsActive.isOn = user!.status
        if user?.status == true{
            lblIsActive.text = "Activo"
        }
        else{
            lblIsActive.text = "Desactivado"
        }
        
        pkvRoles.dataSource = self
        pkvRoles.delegate = self
        
        if user?.rolId == 2{
            pkvRoles.selectRow(1, inComponent: 0, animated: true)
        }
        else{
            pkvRoles.selectRow(0, inComponent: 0, animated: true)
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func Back() {
        dismiss(animated: true)
    }
    @IBAction func switchChange(_ sender: Any) {
        if let sw = sender as? UISwitch{
            if sw.isOn{
                lblIsActive.text = "Activo"
            }
            else{
                lblIsActive.text = "Desactivado"
            }
        }
    }
    
    @IBAction func updateUser(_ sender: Any){
        let alertController = UIAlertController(title: "Actualizar Usuario", message: "¿Estás seguro de que deseas actualizar este usuario?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
        let confirmAction = UIAlertAction(title: "Confirmar", style: .default) { (_) in
            self.updateUser2(sender)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
        
    }
    
    func updateUser2(_ sender: Any) {
        let url = URL(string: "http://\(ApplicationConfiguration.direccionIP)/api/v1/users/update/\(user!.id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token")!)"]
        let parameters: [String: Any] = [
            "name": txfNombre.text!,
            "email": txfCorreo.text!,
            "password": txfContraseña.text!,
            "status": swtIsActive.isOn,
            "rol_id": pkvRoles.selectedRow(inComponent: 0) + 1
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
                        if httpResponse.statusCode == 200{
                            DispatchQueue.main.async{
                                self.user?.nameUsuario = self.txfNombre.text!
                                self.user?.emailUsuario = self.txfCorreo.text!
                                self.user?.status = self.swtIsActive.isOn
                                self.user?.rolId = self.pkvRoles.selectedRow(inComponent: 0) + 1
                                self.lblNombreErrors.text = ""
                                self.lblCorreoErrors.text = ""
                                self.lblContraseñaErrors.text = ""
                                self.delegate?.backButtonPressed(user: self.user!)
                                self.dismiss(animated: true)
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
    

}
