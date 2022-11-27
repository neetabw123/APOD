//
//  ViewController.swift
//  WaIE-APOD
//
//  Created by Kibbcom India on 26/11/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var errorMsg: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var txtVw: UITextView!
    
    let defaults = UserDefaults.standard
    let dateFormatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default
                    .addObserver(self,
                                 selector: #selector(statusManager),
                                 name: .flagsChanged,
                                 object: nil)
        self.updateUserInterface()
     
        
    }
    
    func saveInCoreDataWith(object: [String: AnyObject]) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let APODEntity = NSEntityDescription.insertNewObject(forEntityName: "APODData", into: context) as? APODData
        APODEntity!.date = (object["date"] as! String)
        APODEntity!.explanation = (object["explanation"] as! String)
        APODEntity!.hdurl = (object["hdurl"] as! String)
        APODEntity!.title = (object["title"] as! String)
        do {
            try context.save()
            print("successfully saved")
        } catch {
            print("Could not save")
        }
    }
    
    func fetchFromCoreData() -> [APODData] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var dataAPOD = [APODData]()
        do {
            dataAPOD =
                try context.fetch(APODData.fetchRequest())
        } catch {
            print("couldnt fetch")
        }
        return dataAPOD
    }
    
    func clearData() {
            do {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "APODData")
                do {
                    let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                    _ = objects.map{$0.map{context.delete($0)}}
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                } catch let error {
                    print("ERROR DELETING : \(error)")
                }
            }
        }
    
    func updateUserInterface() {
            switch Network.reachability.status {
            case .unreachable:
                self.defaults.set(Date(), forKey: "dateUpdate")
                let savedDate = UserDefaults.standard.object(forKey: "dateUpdate") as! Date
                
                //if user comes in a same day to page when internet not connected
                if (savedDate == Date())  {
                    self.callAPI()
               }
                else {
                    self.errorMsg.isHidden = false
                    let dataFetch = self.fetchFromCoreData()
                    for item in dataFetch {
                        self.txtVw.text = item.explanation
                        self.titleLbl.text = item.title
                        self.dateLbl.text = item.date
                        self.imgVw.downloaded(from: item.hdurl!)
                    }
                }
               // view.backgroundColor = .red
            case .wwan:
               // view.backgroundColor = .yellow
                print("trying to reach - isRunningOnDevice")
            case .wifi:
                errorMsg.isHidden = true
                self.defaults.set(Date(), forKey: "dateUpdate")
                self.callAPI()
               
              //  view.backgroundColor = .green
            }
            print("Reachability Summary")
            print("Status:", Network.reachability.status)
            print("HostName:", Network.reachability.hostname ?? "nil")
            print("Reachable:", Network.reachability.isReachable)
            print("Wifi:", Network.reachability.isReachableViaWiFi)
        }
    
        @objc func statusManager(_ notification: Notification) {
            updateUserInterface()
        }

    
    func callAPI() {
        let service = APIManager()
        service.getDataWith { (result) in
            switch result {
            case .Success(let data):
                self.errorMsg.isHidden = true
                
                self.clearData()
                self.saveInCoreDataWith(object: data)
                
                let dataFetch = self.fetchFromCoreData()
                    print(dataFetch)
                for item in dataFetch {
                    self.txtVw.text = item.explanation
                    self.titleLbl.text = item.title
                    self.dateLbl.text = item.date
                    self.imgVw.downloaded(from: item.hdurl!)
                }
                
            case .Error(let message):
                DispatchQueue.main.async {
                    self.errorMsg.isHidden = false
                    let dataFetch = self.fetchFromCoreData()
                    for item in dataFetch {
                        self.txtVw.text = item.explanation
                        self.titleLbl.text = item.title
                        self.dateLbl.text = item.date
                        self.imgVw.downloaded(from: item.hdurl!)
                    }
                }
            }
        }
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

