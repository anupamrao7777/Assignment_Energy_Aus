//
//  Bands.swift
//  CollapseTableView
//
//  Created by Anupam Rao on 10/8/20.


import Foundation
class Bands : NSObject{
    struct bands {
        var bandNmae:String? = nil
        var selectedState   = false
        var expandCollapseAllowed   = false
        var isMusicalGroup   = false
        var festivalArray = [String]()
        
    }
    
//
    func sortedArrayOfMusicalFestivalForBand(arrayToSort : NSMutableArray) -> NSMutableArray {
        let sortedArray = arrayToSort.sorted { (($0 as!  Bands.bands).bandNmae as AnyObject).localizedCaseInsensitiveCompare(($1 as! Bands.bands).bandNmae!) == ComparisonResult.orderedAscending }
        arrayToSort.removeAllObjects()
        arrayToSort.addObjects(from: sortedArray )
        return arrayToSort;
    }
}
