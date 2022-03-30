//
//  DetailsVC.swift
//  UdemyArtBookProject
//
//  Created by Kaan Yalçınkaya on 29.11.2021.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if chosenPainting != "" {
            //CoreData
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idString = chosenPaintingId?.uuidString
            
            fetchrequest.returnsObjectsAsFaults = false
            
            //Sadece bir kez isim çekmek için
            fetchrequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            do{
                let results = try context.fetch(fetchrequest)
                
                if results.count > 0 {
                    for result in results as![NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                            
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                            
                        }
                        
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                            
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }
            catch{
                print("error")
                
            }
            
            let stringUUID = chosenPaintingId!.uuidString
            print(stringUUID)


        }
        else {
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }
        
        //Kullanıcı isim girerken klavyenin kaybolması.
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)

    }
    
    @objc func selectImage(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
        
        view.endEditing(true)
    }

    
    @IBAction func saveButtonClicke(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes
        
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        
        
        
        if let year = Int(yearText.text!) {
            newPainting.setValue(year, forKey: "year")
        }
            
        newPainting.setValue(UUID(), forKey: "id")
        
        //görseli data olarak kaydetme (görseli dataya çevirme)
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("success")
        }
        catch{
            print("error")
        }
        
        //Kayıt olan userlar için mesaj yollama aracı.
        NotificationCenter.default.post(name: NSNotification.Name("New Data"), object: nil) //object bir şey yollamak ister misin diye soruyor.
        
                //Save yaptıktan sonra bir sonraki ViewController a geri gelmek için.
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
}
