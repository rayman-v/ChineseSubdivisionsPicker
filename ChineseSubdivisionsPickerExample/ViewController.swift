//
//  ViewController.swift
//  ChineseSubdivisionsPickerExample
//
//  Created by huajiahen on 12/7/15.
//  Copyright © 2015 huajiahen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ChineseSubdivisionsPickerDelegate {
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var subdivisionsPicker: ChineseSubdivisionsPicker!
    
    @IBAction func selectPickerType(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            subdivisionsPicker.pickerType = .province
        case 1:
            subdivisionsPicker.pickerType = .city
        case 2:
            subdivisionsPicker.pickerType = .district
        default:
            break
        }
    }
    
    func subdivisionsPickerDidUpdate(_ sender: ChineseSubdivisionsPicker) {
        dataLabel.text = (subdivisionsPicker.province ?? "") + " " + (subdivisionsPicker.city ?? "") + " " + (subdivisionsPicker.district ?? "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subdivisionsPicker.pickerDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

