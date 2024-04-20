//
//  UsersViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 17/04/24.
//

import UIKit

class UsersViewController: UIViewController {
    @IBOutlet weak var scrUsers: UIScrollView!
    var users:[UserFVA] = []
    var y = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                        self.present(ApplicationConfiguration.closeApp(), animated: true)
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
            openButton.addTarget(self, action: #selector(openModal(sender: )), for: .touchUpInside)
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
    
    @objc func openModal(sender:UIButton) {
        print("hola")
        let user = users[sender.tag]
    }

    @objc func closeModal() {
        dismiss(animated: true, completion: nil)
    }

    func scrollUsers(){
        scrUsers.contentSize = CGSize(width: view.frame.width, height: y+80)
    }
    
}
