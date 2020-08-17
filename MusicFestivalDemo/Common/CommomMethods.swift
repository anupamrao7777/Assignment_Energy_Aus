//
//  CommomMethods.swift
//  MusicFestivalDemo
//
//  Created by Anupam Rao on 16/8/20.
//  Copyright © 2020 Serhii Kharauzov. All rights reserved.
//

import Foundation
import UIKit

class CommomMethods : NSObject{
    
    
    struct MusicFestival :  Codable {
        var name: String?
        var bands: [Bands2]?
    }
    struct Bands2 :  Codable {
        var name: String?
        var recordLabel: String?
    }
    /**
     Sort array object in alphabetic order
     - Parameter :  Unsorted array
     - Returns: Sorted array
     */
    func sortedStringArrayAlphabatically(arrayToSort : NSArray) ->[Any] {
        let sortedArray = arrayToSort.sorted { ((($0) as AnyObject).localizedCaseInsensitiveCompare($1 as! String) == ComparisonResult.orderedAscending) }
        return sortedArray ;
    }
    /**
     Removes empty object from array
     - Parameter : arrayToCheck -  Array with empty string
     - Returns: Array without empty string
     */
    func removeEmptyStringFromArray(arrayToCheck : NSArray) -> [Any] {
        let predicate = NSPredicate(format: "length > 0")
        return arrayToCheck.filtered(using: predicate)
        
    }
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
     The method parses json data
     - Parameter : jsonData - jsonData
     - Returns: recordLabelDictionary , bandDictionary and recordLevelArray
     */
    func parse(jsonData: Data) -> ( NSMutableDictionary,  NSMutableDictionary , [Any]) {
        let recordLabelDictionary = NSMutableDictionary();
        let bandDictionary = NSMutableDictionary();
        var recordLevelArray  = [Any]();
        
        do {
            let decodedData = try JSONDecoder().decode([MusicFestival].self,
                                                       from: jsonData)
            if decodedData.count == 0 {
                return (recordLabelDictionary, bandDictionary , recordLevelArray );
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
            // Error handling
        catch {
            DispatchQueue.main.async {
                self.showAlertWith(title: ConstantValues.Constants.parsingErrorTitle ,message: error.localizedDescription)
            }
        }
        let array = recordLabelDictionary.allKeys as NSArray
        let recordLevelArrayWithoutEmptyString = self.removeEmptyStringFromArray(arrayToCheck: array)
        recordLevelArray = (self.sortedStringArrayAlphabatically(arrayToSort:recordLevelArrayWithoutEmptyString as NSArray ))
        return (recordLabelDictionary , bandDictionary , recordLevelArray)
    }
    
    /**
     The method to present Alert
     - Parameter : title - Title of Aler
     message : Message of Alert
     - Returns: Void
     */
    
    func showAlertWith(title : String , message : String) -> Void {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: ConstantValues.Constants.alertButtonOk, style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
}

