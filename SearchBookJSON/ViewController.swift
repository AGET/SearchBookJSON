//
//  ViewController.swift
//  SearchBookJSON
//
//  Created by Workstation on 30/04/16.
//  Copyright © 2016 Workstation. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var buscar: UISearchBar!
    @IBOutlet weak var indicador: UIActivityIndicatorView!
    @IBOutlet weak var indicadorImagen: UIActivityIndicatorView!
    
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var autor1: UILabel!
    @IBOutlet weak var autor2: UILabel!
    @IBOutlet weak var autor3: UILabel!
    
    @IBOutlet weak var imgPortada: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        buscar.text = "1577486056"
        autor1.text = ""
        autor2.text = ""
        autor3.text = ""
        titulo.text = ""
        configureSearchBar()
    }
    
    
    
    // MARK: Configuration
    func configureSearchBar() {
        buscar.showsCancelButton = true
    }
    
    // MARK: UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        NSLog("Selecciono la scope\(selectedScope).")
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        NSLog("Buscando: \(searchBar.text!).")
        searchBar.resignFirstResponder()
        busqueda(buscar.text!)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        NSLog("Cancelado")
        searchBar.resignFirstResponder()
    }
    //SearchEND
    
    
    //Busqueda
    func busqueda(isbn: String){
        
        //AsincronoInicio
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(isbn)"
        NSLog(urls)
        let url = NSURL(string:urls)
        let sesion = NSURLSession.sharedSession()
        
        let bloque = {(datos:NSData?,resp : NSURLResponse?,error:NSError?) -> Void in
            if error == nil{
                if datos?.length > 10 {
                    dispatch_async(dispatch_get_main_queue(),{
                        self.optenerDatos(datos!, isbn: isbn)
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(),{
                        self.mostrarMensajeSimple("Alerta!", message: "No se encontro", owner: self)
                        self.indicador.stopAnimating()
                    })
                }
            }else{
                dispatch_async(dispatch_get_main_queue(),{
                    self.mostrarMensajeSimple("Alerta!", message: "Error de conexion", owner: self)
                    self.indicador.stopAnimating()
                })
            }
        }
        let dt = sesion.dataTaskWithURL(url!, completionHandler: bloque)
        dt.resume()
        self.indicador.startAnimating()
    }
    //BusquedaFin
    
    func mostrarMensajeSimple (title: String, message: String, owner:UIViewController) {
        let alerta = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alerta.addAction(UIAlertAction(title: "Entiendo", style: UIAlertActionStyle.Default, handler:{ (ACTION:UIAlertAction!)in
        }))
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    func optenerDatos(dato: NSData, isbn: String){
        var nombres = [String]()
        var titulo = ""
        //var img = ""
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(dato, options: NSJSONReadingOptions.MutableLeaves)
            if  let js = json as? NSDictionary{
                if  let jsIsbn = js["ISBN:\(isbn)"] as? NSDictionary  {
                    titulo = jsIsbn["title"] as! NSString as String
                    if let imagenes = jsIsbn["cover"] as? NSDictionary{
                        //img = imagenes["medium"] as! NSString as String
                        //img = imagenes["small"] as! NSString as String
                        let url = NSURL(string: imagenes["medium"] as! NSString as String)
                        loadImagen(url!)
                    }else{
                        self.imgPortada.image = UIImage(named: "book")
                    }
                    let cantidadAutores = jsIsbn["authors"]?.count
                    for indice in 0 ..< cantidadAutores!{
                        let jsAutores = jsIsbn["authors"]![indice] as? NSDictionary
                        nombres.append(jsAutores!["name"] as! NSString as String)
                    }
                }
            }
        }
        catch _ {
        }
        self.titulo.text = titulo
        let num = nombres.count
        if num > 0 {
            if num == 1 {
                self.autor1.text = nombres[0]
                self.autor2.text = ""
                self.autor3.text = ""
            }else if nombres.count == 2 {
                self.autor1.text = nombres[0]
                self.autor2.text = nombres[1]
                self.autor3.text = ""
            }else {
                self.autor1.text = nombres[0]
                self.autor2.text = nombres[1]
                self.autor3.text = nombres[2]
            }
        }
//        if !img.isEmpty{
//            if let url = NSURL(string: img) {
//                if let data = NSData(contentsOfURL: url) {
//                    imgPortada.image = UIImage(data: data)
//                }
//            }
//            loadImagen(img)
//        }else{
//            self.imgPortada.image = UIImage(named: "book")
//        }
        self.indicador.stopAnimating()
    }
    
    func loadImagen(direccionImagen:NSURL) {
        //let imgURL = direccionImagen
        let resq: NSURLRequest = NSURLRequest(URL: direccionImagen)
        let sesion = NSURLSession.sharedSession()
        let miSesion = sesion.dataTaskWithRequest(resq){
            (data, response, error) -> Void in
            if (error == nil && data != nil){
                func mostrarImg(){
                    self.imgPortada.image = UIImage(data: data!)
                    self.indicadorImagen.stopAnimating()
                }
                dispatch_async(dispatch_get_main_queue(), mostrarImg)
            }
        }
        miSesion.resume()
        self.indicadorImagen.startAnimating()
    }
    
    @IBAction func limpiar(sender: AnyObject) {
        buscar.text = ""
        titulo.text = ""
        autor1.text = ""
        autor2.text = ""
        autor3.text = ""
        imgPortada.image = UIImage(named: "book")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

