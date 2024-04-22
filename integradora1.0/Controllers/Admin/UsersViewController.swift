//
//  UsersViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 17/04/24.
//

import UIKit

class UsersViewController: UIViewController, ModalUserViewControllerDelegate, StoreUserViewControllerDelegate {
    
    @IBOutlet weak var scrUsers: UIScrollView!
    var users:[UserFVA] = []
    var y = 0.0
    @IBOutlet weak var btnAdduser: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnAdduser.layer.cornerRadius = 35
        
        consultarUsers()
    }
    
    @IBAction func refresh() {
        users = []
        y = 0.0
        for subview in scrUsers.subviews{
            subview.removeFromSuperview()
        }
        consultarUsers()
    }
    
    func consultarUsers(){
        let conexion = URLSession(configuration: .default)
        let url = URL(string: "http://\(ApplicationConfiguration.direccionIP)/api/v1/users/index")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        conexion.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la solicitud GET: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("Código de estado HTTP de la respuesta: \(httpResponse.statusCode)")
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
                if let data = data {
                    do{
                        let json = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                        if let resultados = json["data"] as? [[String:Any]]{
                            for user in resultados{
                                self.users.append(UserFVA(id: user["id"] as! Int, rolId: user["rol_id"] as! Int, nameUsuario: user["name"] as! String, emailUsuario: user["email"] as! String, status: user["status"] as! Bool))
                            }
                            DispatchQueue.main.async{
                                self.dibujarUsuarios()
                            }
                        }
                        else{
                            print("No estas autorizado")
                        }

                    }
                    catch{
                        print("Error en la peticion =(")
                    }
                }
            }
        }.resume()
    }
    
    func dibujarUsuarios(){
        
        let x = 10.0
        let w = scrUsers.frame.width
        let h = 54.0
        let hTittle = 18.0
        let hSubTitle = 16.0
        
        for (index, user) in users.enumerated(){
            let vista = UIView(frame: CGRect(x: 0, y: y, width: w, height: h))
            vista.layer.borderWidth = 1
            vista.layer.borderColor = UIColor.lightGray.cgColor
            
            if user.status == false{
                vista.layer.backgroundColor = UIColor(red: 255/255, green: 236/255, blue: 236/255, alpha: 1.0).cgColor
            }
            
            let lblNombre = UILabel(frame: CGRect(x: x, y: 10.0, width: w/3.0, height: hTittle))
            lblNombre.text = user.nameUsuario
            lblNombre.font = .systemFont(ofSize: 18, weight: .semibold)
            lblNombre.adjustsFontSizeToFitWidth = true
            lblNombre.minimumScaleFactor = 0.7
            
            let lblCorreo = UILabel(frame: CGRect(x: lblNombre.frame.width + 20.0, y: 10.0, width: w/2.0, height: hTittle))
            lblCorreo.text = user.emailUsuario
            lblCorreo.font = .systemFont(ofSize: 18, weight: .semibold)
            lblCorreo.adjustsFontSizeToFitWidth = true
            lblCorreo.minimumScaleFactor = 0.7
            
            let lblRol = UILabel(frame: CGRect(x: x, y: lblNombre.frame.height + 10.0, width: lblNombre.frame.width, height: hSubTitle))
            if user.rolId == 2{
                lblRol.text = "Administrador"
            }
            else{
                lblRol.text = "Usuario"
            }
            lblRol.font = .systemFont(ofSize: 16, weight: .regular)
            lblRol.adjustsFontSizeToFitWidth = true
            lblRol.minimumScaleFactor = 0.7
            
            let lblStatus = UILabel(frame: CGRect(x: lblCorreo.frame.origin.x, y: lblCorreo.frame.height+10.0, width: lblCorreo.frame.width, height: hSubTitle))
            if user.status == false{
                lblStatus.text = "Desactivado"
            }
            else{
                lblStatus.text = "Activado"
            }
            lblStatus.font = .systemFont(ofSize: 16, weight: .regular)
            lblStatus.adjustsFontSizeToFitWidth = true
            lblStatus.minimumScaleFactor = 0.7
            
            let arrow = UIImageView(frame: CGRect(x: vista.frame.width-vista.frame.height+15.0, y: vista.frame.height/2.0-13, width: vista.frame.height-20.0, height: vista.frame.height-30.0))
            arrow.image = UIImage(systemName: "arrow.right")
            arrow.tintColor = UIColor.lightGray
            
            let openButton = UIButton()
            openButton.frame = CGRect(x: 0, y: 0, width: vista.frame.width, height: vista.frame.height)
            openButton.tag = index
            openButton.addTarget(self, action: #selector(irDetalle(sender: )), for: .touchUpInside)
            y += h
            vista.addSubview(openButton)
            vista.addSubview(arrow)
            vista.addSubview(lblNombre)
            vista.addSubview(lblCorreo)
            vista.addSubview(lblRol)
            vista.addSubview(lblStatus)
            scrUsers.addSubview(vista)
        }
        scrollUsers()
    }
    
    func clearUsers(){
        y = 0.0
        for subview in self.scrUsers.subviews {
            subview.removeFromSuperview()
        }
    }
    
    @objc func irDetalle(sender: UIButton) {
        let user = users[sender.tag]
        if let muvc = storyboard?.instantiateViewController(withIdentifier: "userView") as? ModalUserViewController {
            muvc.user = user
            muvc.index = sender.tag
            muvc.modalPresentationStyle = .fullScreen
            muvc.modalTransitionStyle = .crossDissolve
            muvc.delegate = self
            present(muvc, animated: true)
        }
    }
    
    func backButtonPressed(index: Int, user: UserFVA) {
        users[index] = user
        clearUsers()
        dibujarUsuarios()
    }
    
    func backButtonPressedStore() {
        users.removeAll()
        clearUsers()
        consultarUsers()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgStoreAdmin" {
            if let storeUserVC = segue.destination as? StoreUserViewController {
                storeUserVC.delegate = self
            }
        }
    }

    @objc func closeModal() {
        dismiss(animated: true, completion: nil)
    }

    func scrollUsers(){
        scrUsers.contentSize = CGSize(width: view.frame.width, height: y+83)
    }
    
}
