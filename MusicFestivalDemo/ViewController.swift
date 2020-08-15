//
//  ViewController.swift
//  CollapseTableView
//


import UIKit
import CollapseTableView

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: CollapseTableView!
    var reachability: Reachability!
    var tableDataArray = NSMutableArray();
    let recordLabelDictionary = NSMutableDictionary();
    let bandDictionary = NSMutableDictionary();
    var recordLevelArray = [Any]()
    var counter = 0
    struct MusicFestival :  Codable {
        var name: String?
        var bands: [Bands2]?
    }
    struct Bands2 :  Codable {
        var name: String?
        var recordLabel: String?
    }
    
    // MARK: View life cycle methods
    
    override func viewDidAppear(_ animated: Bool) {
        
        do {
            try reachability = Reachability()
            if reachability.connection != .unavailable {
                if reachability.connection == .wifi {
                    self.fetchAndParseData()
                } else {
                    self.fetchAndParseData()
                }
            } else {
                self.showAlertWith(title: ConstantValues.Constants.noInternetConnectivityTitle,
                                   message: ConstantValues.Constants.noInternetConnectivityMessage)
            }
        } catch {
            print(ConstantValues.Constants.reachabilitIssue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        tableView.didTapSectionHeaderView = { (sectionIndex, isOpen) in
            debugPrint("sectionIndex \(sectionIndex), isOpen \(isOpen) and object is \(self.recordLevelArray[sectionIndex]))" )
            self.createBandData(bandArray:self.recordLabelDictionary.object(forKey: self.recordLevelArray[sectionIndex] ) as! NSArray)
            self.tableView.reloadData()
            
        }
        
    }
    
     // MARK: Fetch and parsing data
    
    func fetchAndParseData() -> Void {
        let urlString = ConstantValues.Constants.Music_Festival_Url
        self.loadJson(fromURLString: urlString) { (result) in
            switch result {
            case .success(let data):
                self.parse(jsonData: data)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    private func loadJson(fromURLString urlString: String,
                          completion: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                }
                if let data = data {
                    completion(.success(data))
                }
            }
            urlSession.resume()
        }
    }
    
    private func parse(jsonData: Data) {
        do {
            let decodedData = try JSONDecoder().decode([MusicFestival].self,
                                                       from: jsonData)
            if decodedData.count == 0 {
                return;
            }
            for item in decodedData {
                let bandData = item.bands
                for bands in 0..<(bandData!.count) {
                    let recordLevel = bandData![bands].recordLabel ?? nil
                    if ((recordLevel != nil) && recordLabelDictionary[recordLevel as Any] != nil ){
                        let modifyingArray = recordLabelDictionary.value(forKey: recordLevel ?? "") as! NSMutableArray;
                        modifyingArray.add(bandData![bands].name!)
                        recordLabelDictionary.setValue(modifyingArray, forKey:recordLevel ?? "")
                        let bandName = bandData![bands].name!
                        if bandDictionary[bandName] != nil && recordLabelDictionary.value(forKey: bandName) != nil{
                            
                            let modifyingArray = recordLabelDictionary.value(forKey: bandName) as! NSMutableArray;
                            modifyingArray.add(item.name!)
                            bandDictionary.setValue(modifyingArray, forKey:bandName)
                        }
                    } else {
                        let bandArray = NSMutableArray()
                        var musicalFestivalArray = NSMutableArray()
                        
                        if  (bandDictionary[bandData![bands].name as Any] != nil){
                            musicalFestivalArray = bandDictionary.value(forKey:bandData![bands].name ?? "") as! NSMutableArray;
                        }
                        if (item.name != nil) {
                            musicalFestivalArray.add(item.name!)
                        }
                        
                        bandDictionary.setValue(musicalFestivalArray, forKey:bandData![bands].name!)
                        bandArray.add(bandData![bands].name!);
                        if (recordLevel != nil) {
                            recordLabelDictionary.setValue(bandArray, forKey:recordLevel ?? "")
                        }
                        
                    }
                }
            }
        }
            
        catch {
            DispatchQueue.main.async {
                self.showAlertWith(title: ConstantValues.Constants.parsingErrorTitle ,message: error.localizedDescription)
            }
        }
        let array = self.recordLabelDictionary.allKeys as NSArray
        let recordLevelArrayWithoutEmptyString = self.removeEmptyStringFromArray(arrayToCheck: array)
        self.recordLevelArray =   self.sortedStringArrayAlphabatically(arrayToSort:recordLevelArrayWithoutEmptyString as NSArray  )
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
     // MARK: Some Convenience methods
    
    func showAlertWith(title : String , message : String) -> Void {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: ConstantValues.Constants.alertButtonOk, style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func sortedStringArrayAlphabatically(arrayToSort : NSArray) ->[Any] {
        let sortedArray = arrayToSort.sorted { ((($0) as AnyObject).localizedCaseInsensitiveCompare($1 as! String) == ComparisonResult.orderedAscending) }
        return sortedArray ;
    }
    
    func removeEmptyStringFromArray(arrayToCheck : NSArray) -> [Any] {
           let predicate = NSPredicate(format: "length > 0")
           return arrayToCheck.filtered(using: predicate)
           
       }
    
     // MARK: Setup and reload tableview
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UINib(nibName: SectionHeaderView.reuseIdentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: SectionHeaderView.reuseIdentifier)
    }
    
    func reloadTableView(_ completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            completion()
        })
        tableView.reloadData()
        CATransaction.commit()
    }
    
   
}




extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
     // MARK: Tableview data source and delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.recordLevelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConstantValues.Constants.bandCellIdentifier, for: indexPath) as! customTableViewCell
        let bandVar =  tableDataArray[indexPath.row] as? Bands.bands
        cell.bandLabel.text = bandVar?.bandNmae
        if bandVar?.expandCollapseAllowed == true {
            if ((bandVar?.selectedState == true)) {
                cell.expandCollapseImageView.image = UIImage(named: ConstantValues.Constants.openStateImageName)
            } else {
                cell.expandCollapseImageView.image = UIImage(named: ConstantValues.Constants.closedStateImageName)
            }
        } else {
            cell.expandCollapseImageView.image = nil;
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        headerLabel.frame = CGRect(x: 10, y: 15, width: tableView.frame.size.width - 5, height: 18)
        headerLabel.backgroundColor = UIColor.clear
        headerLabel.textColor = UIColor.black
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        let bandVar =  self.recordLevelArray[section]
        headerLabel.text = (bandVar as! String)
        headerLabel.textAlignment = .left
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderView.reuseIdentifier)
        for v in view!.subviews{
            if v is UILabel{
                v.removeFromSuperview()
            }
        }
        view!.addSubview(headerLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var bandVar =  self.tableDataArray[indexPath.row] as? Bands.bands
        if bandVar?.expandCollapseAllowed == false {
            return;
        }
        if  ((bandVar?.selectedState ) == true) {
            if counter == 1 {
                self.bringDataToAllCollapsedState()
                let index = self.find(value: (bandVar?.bandNmae)!, in: tableDataArray as! [Bands.bands])
                var bandVar =  self.tableDataArray[index!] as? Bands.bands
                bandVar?.selectedState = false
                tableDataArray.replaceObject(at: index!, with: bandVar as Any)
                counter = counter - 1
            } else {
                bandVar?.selectedState = false
                tableDataArray = [];
                tableDataArray.replaceObject(at: indexPath.row, with: bandVar as Any)
                counter = counter + 1
            }
            
        } else {
            if counter == 1 {
                self.bringDataToAllCollapsedState()
                let index = self.find(value: (bandVar?.bandNmae)!, in: tableDataArray as! [Bands.bands])
                var bandVar =  self.tableDataArray[index!] as? Bands.bands
                bandVar?.selectedState = true
                let localArr =  bandVar?.festivalArray
                tableDataArray.replaceObject(at: index!, with: bandVar as Any)
                var indexpath = index! + 1;
                for item in localArr! {
                    var photoInstance = Bands.bands();
                    photoInstance.bandNmae = " " + item
                    photoInstance.isMusicalGroup = true;
                    tableDataArray.insert(photoInstance, at: indexpath)
                    indexpath = indexpath + 1
                }
            } else if counter == 0 {
                bandVar?.selectedState = true
                let localArr =  bandVar?.festivalArray
                counter = counter + 1;
                tableDataArray.replaceObject(at: indexPath.row, with: bandVar as Any)
                var indexpath = indexPath.row + 1;
                for item in localArr! {
                    var photoInstance = Bands.bands();
                    photoInstance.bandNmae = " " + item
                    photoInstance.isMusicalGroup = true;
                    tableDataArray.insert(photoInstance, at: indexpath)
                    indexpath = indexpath + 1
                }
            }
        }
        self.tableView.reloadData()
    }
    // MARK: Some Convenience methods
    
    /**
     Finds the index of a string in array
    - Parameter : searchValuey - The string to be searched
               array - the array in which string is to be searched
    - Returns: the index of string in array``
    */
    func find(value searchValue: String, in array: [Bands.bands]) -> Int?
    {
        for (index, value) in array.enumerated()
        {
            if value.bandNmae == searchValue {
                return index
            }
        }
        return nil
    }
    /**
      Creates the band data array from given array
    - Parameter bandArray: The original array
    */
    func createBandData(bandArray: NSArray) -> Void{
        tableDataArray.removeAllObjects()
        // originalDataArray.removeAllObjects()
        for data in bandArray {
            var photoInstance = Bands.bands();
            photoInstance.bandNmae = (data as! String)
            photoInstance.selectedState = false ;
            if (self.bandDictionary.object(forKey:photoInstance.bandNmae as Any ) != nil) {
                photoInstance.festivalArray = self.bandDictionary.object(forKey:photoInstance.bandNmae as Any ) as! [String]
            }
            if photoInstance.festivalArray.count > 0 {
                photoInstance.expandCollapseAllowed = true ;
            } else {
                photoInstance.expandCollapseAllowed = false ;
            }
            photoInstance.isMusicalGroup = false
            tableDataArray.add(photoInstance)
        }
        
    }
    
    /**
    Reset data to collapsed state
    */
    
    func bringDataToAllCollapsedState() -> Void {
        let locaArray = NSMutableArray();
        for i in 0...tableDataArray.count - 1 {
            let bandsObject = tableDataArray[i] as!Bands.bands
            if (!bandsObject.isMusicalGroup) {
                locaArray.add(tableDataArray[i])
            } else {
                
            }
        }
        tableDataArray.removeAllObjects()
        tableDataArray.addObjects(from: locaArray as! [Any])
    }
    
}

