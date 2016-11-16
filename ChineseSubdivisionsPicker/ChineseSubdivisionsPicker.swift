//
//  ChineseSubdivisionsPicker.swift
//  ChineseSubdivisionsPickerExample
//
//  Created by huajiahen on 12/7/15.
//  Copyright © 2015 huajiahen. All rights reserved.
//

import UIKit

public protocol ChineseSubdivisionsPickerDelegate {
    func subdivisionsPickerDidUpdate(_ sender: ChineseSubdivisionsPicker)
}

open class ChineseSubdivisionsPicker: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    struct Province {
        let name: String
        let cities: [City]
    }
    
    struct City {
        let name: String
        let districts: [String]
    }
    
    public enum ChineseSubdivisionsPickerType {
        case province
        case city
        case district
    }
    
    open var pickerType: ChineseSubdivisionsPickerType = .district {
        didSet {
            province = nil
            city = nil
            district = nil
            reloadAllComponents()
            selectRow(0, inComponent: 0, animated: false)
        }
    }
    open var pickerDelegate: ChineseSubdivisionsPickerDelegate?
    open var province: String? {
        get { return __province }
        set {
            if let newValue = newValue,
                let index = provinces.index(of: newValue), selectedRow(inComponent: 0) != index {
                selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
    
    open var city: String? {
        get { return __city }
        set {
            if pickerType != .province,
                let newValue = newValue,
                let index = cities.index(of: newValue), selectedRow(inComponent: 1) != index {
                selectRow(index, inComponent: 1, animated: false)
            }
        }
    }
    
    open var district: String? {
        get { return __district }
        set {
            if pickerType == .district,
                let newValue = newValue,
                let index = districts.index(of: newValue), selectedRow(inComponent: 2) != index {
                selectRow(index, inComponent: 2, animated: false)
            }
        }
    }
    
    
    fileprivate lazy var subdivisionsData: [Province] = {
        let podBundle = Bundle(for: self.classForCoder)
        
        guard let path = podBundle.path(forResource: "ChineseSubdivisions", ofType: "plist"),
            let localData = NSArray(contentsOfFile: path) as? [[String: [[String: [String]]]]] else {
                #if DEBUG
                    assertionFailure("ChineseSubdivisionsPicker load data failed.")
                #endif
                return []
        }
        
        return localData.map { provinceData in
            Province(name: provinceData.keys.first!, cities: provinceData.values.first!.map({ citiesData in
                City(name: citiesData.keys.first!, districts: citiesData.values.first!)
            }))
        }
    }()
    fileprivate lazy var provinces: [String] = self.subdivisionsData.map({ $0.name })
    fileprivate var cities: [String] = []
    fileprivate var districts: [String] = []
    fileprivate var __province: String?
    fileprivate var __city: String?
    fileprivate var __district: String?
    
    override open weak var delegate: UIPickerViewDelegate? {
        didSet {
            if delegate !== self {
                delegate = self
            }
        }
    }

    override open weak var dataSource: UIPickerViewDataSource? {
        didSet {
            if dataSource !== self {
                dataSource = self
            }
        }
    }

    //MARK: view life cycle
    
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        
        if __province == nil {
            selectRow(0, inComponent: 0, animated: false)
        }
        pickerDelegate?.subdivisionsPickerDidUpdate(self)
    }
    
    //MARK: init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupPicker()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupPicker()
    }
    
    func setupPicker() {
        delegate = self
        dataSource = self
    }
    
    //MARK: - Picker view data source
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerType {
        case .province:
            return 1
        case .city:
            return 2
        case .district:
            return 3
        }
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return provinces.count
        case 1:
            return cities.count
        case 2:
            return districts.count
        default:
            return 0
        }
    }
    
    //MARK: - Picker view delegate
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return provinces[row]
        case 1:
            guard row != -1 && row < cities.count else {
                return nil
            }
            return cities[row]
        case 2:
            guard row != -1 && row < districts.count else {
                return nil
            }
            return districts[row]
        default:
            return nil
        }
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            guard __province != provinces[row] else {
                return
            }
            
            __province = provinces[row]
            if pickerType != .province {
                let citiesInProvince = subdivisionsData[row].cities
                cities = citiesInProvince.map({ $0.name })

                reloadComponent(1)
                selectRow(0, inComponent: 1, animated: false)
            } else {
                pickerDelegate?.subdivisionsPickerDidUpdate(self)
            }
        case 1:
            guard __city != cities[row] else {
                return
            }
            
            __city = cities[row]
            if pickerType != .city {
                guard let province = subdivisionsData.filter({ $0.name == __province }).first,
                    let city = province.cities.filter({ $0.name == __city }).first else {
                        return
                }
                districts = city.districts
                
                reloadComponent(2)
                selectRow(0, inComponent: 2, animated: false)
            } else {
                pickerDelegate?.subdivisionsPickerDidUpdate(self)
            }
        case 2:
            if row != 0 {
                __district = districts[row]
                pickerDelegate?.subdivisionsPickerDidUpdate(self)
            }
        default:
            break
        }
    }
    
    //MARK: - Other
    override open func selectRow(_ row: Int, inComponent component: Int, animated: Bool) {
        super.selectRow(row, inComponent: component, animated: animated)
        
        self.pickerView(self, didSelectRow: row, inComponent: component)
    }
}
