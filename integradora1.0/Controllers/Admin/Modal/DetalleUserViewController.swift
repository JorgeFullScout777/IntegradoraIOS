//
//  ModalViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 20/04/24.
//

import UIKit

protocol ModalUserViewControllerDelegate: AnyObject {
    func backButtonPressed(index:Int, user:UserFVA)
}

class ModalUserViewController: UIViewController, UpdateUserViewControllerDelegate {
    
    weak var delegate:ModalUserViewControllerDelegate?
    var user: UserFVA?
    var color:UIColor?
    @IBOutlet weak var lblNombre: UILabel!
    @IBOutlet weak var lblCorreo: UILabel!
    @IBOutlet weak var lblEstado: UILabel!
    @IBOutlet weak var lblRol: UILabel!
    @IBOutlet weak var imgIsActive: UIImageView!
    @IBOutlet weak var btnActualizar: UIButton!
    var index: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        color = imgIsActive.tintColor
        btnActualizar.layer.cornerRadius = 25
        setup()
    }
    
    func setup(){
        lblNombre.text = "Nombre: \(user!.nameUsuario)"
        lblCorreo.text = "Correo: \(user!.emailUsuario)"
        if user?.status == true{
            lblEstado.text = "Estado: Activo"
        }
        else{
            lblEstado.text = "Estado: Desactivado"
        }
        if user?.rolId == 2{
            lblRol.text = "Rol: Administrador"
        }
        else{
            lblRol.text = "Rol: Usuario"
        }
        iconIsActive()
    }
    
    func backButtonPressed(user: UserFVA) {
        self.user = user
        setup()
    }
    
    func iconIsActive(){
        if user?.status == true{
            imgIsActive.tintColor = color
        }
        else{
            imgIsActive.tintColor = .systemRed
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgEditUser" {
            if let uuvc = segue.destination as? UpdateUserViewController {
                uuvc.user = user
                uuvc.delegate = self
            }
        }
    }
    
    @IBAction func Back() {
        self.delegate?.backButtonPressed(index: index!, user: user!)
        dismiss(animated: true)
    }
    
    

}
