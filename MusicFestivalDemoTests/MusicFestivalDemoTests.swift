//
//  MusicFestivalDemoTests.swift
//  MusicFestivalDemoTests
//
//  Created by Anupam Rao on 13/8/20.
//  
//

import XCTest
@testable import MusicFestivalDemo
class MusicFestivalDemoTests: XCTestCase {
    
    func testIndexOfStringInArray() {
        let commomMethods = CommomMethods()
        let dataArray = NSMutableArray();
        
        var musicFestivalInstance1 = Bands.bands();
        musicFestivalInstance1.bandNmae = "test2"
        musicFestivalInstance1.selectedState = false ;
        musicFestivalInstance1.expandCollapseAllowed = true ;
        
        var musicFestivalInstance2 = Bands.bands();
        musicFestivalInstance2.bandNmae = "test"
        musicFestivalInstance2.selectedState = false ;
        musicFestivalInstance2.expandCollapseAllowed = true ;
        dataArray.add(musicFestivalInstance1)
        dataArray.add(musicFestivalInstance2)
        let index = commomMethods.find(value: "test", in: dataArray as! [Bands.bands])
        XCTAssertEqual(index, 1, "index should be 1")
    }
    
    func testFetchMusicFestivalData() {
        let exp = expectation(description:"fetching MusicFestival from server")
        
        let session: URLSession = URLSession(configuration: .default)
        let url = URL(string: "http://eacodingtest.digital.energyaustralia.com.au/api/v1/festival")
        session.dataTask(with: url!) { data, response, error in
            XCTAssertNil(error)
            exp.fulfill()
        }.resume()
        waitForExpectations(timeout: 60.0) { (error) in
            print(error?.localizedDescription ?? "error")
        }
    }
    
    func testRemovalOfEmptyStringInArray() {
        let commomMethods = CommomMethods()
        let dataArray = ["","testData1","testData2"];
        let expectedArrayValue = ["testData1","testData2"];
        
        let expectedArray =  commomMethods.removeEmptyStringFromArray(arrayToCheck: dataArray as NSArray)
        XCTAssertEqual(expectedArray as NSArray, expectedArrayValue as NSArray, "Function not working")
    }
    
    func testAlphabaticOrderingOfArray() {
        let commomMethods = CommomMethods()
        let dataArray = ["B","A","D","c"];
        let expectedArrayValue = ["A","B","c","D"];
        let expectedArray =  commomMethods.sortedStringArrayAlphabatically(arrayToSort: dataArray as NSArray)
        XCTAssertEqual(expectedArray as NSArray, expectedArrayValue as NSArray, "Function not working")
    }
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

