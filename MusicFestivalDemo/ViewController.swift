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
    var recordLabelDictionary = NSMutableDictionary();
    var bandDictionary = NSMutableDictionary();
    var recordLevelArray = [Any]()
    var counter = 0
    let commonMethods = CommomMethods()
    let serviceCall = ServiceCall()
    
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
                commonMethods.showAlertWith(title: ConstantValues.Constants.noInternetConnectivityTitle,
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
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    // MARK: Fetch and parsing data
    
    func fetchAndParseData() -> Void {
        let urlString = ConstantValues.Constants.Music_Festival_Url
        serviceCall.loadJson(fromURLString: urlString) { (result) in
            switch result {
            case .success(let data):
                (self.recordLabelDictionary , self.bandDictionary ,self.recordLevelArray) =  self.commonMethods.parse(jsonData: data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.commonMethods.showAlertWith(title: ConstantValues.Constants.serverError,
                                                     message: error.localizedDescription)
                }
                
            }
        }
        
    }
    
    // MARK: Setup and reload tableview
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UINib(nibName: SectionHeaderView.reuseIdentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: SectionHeaderView.reuseIdentifier)
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
                let index = commonMethods.find(value: (bandVar?.bandNmae)!, in: tableDataArray as! [Bands.bands])
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
                let index = commonMethods.find(value: (bandVar?.bandNmae)!, in: tableDataArray as! [Bands.bands])
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
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    // MARK: Some Convenience methods
    
    /**
     Creates the band data array from given array
     - Parameter bandArray: The original array
     */
    func createBandData(bandArray: NSArray) -> Void{
        tableDataArray.removeAllObjects()
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

