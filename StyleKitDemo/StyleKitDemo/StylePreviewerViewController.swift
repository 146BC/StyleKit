//
//  StylePreviewerViewController.swift
//  StyleKitDemo
//
//  Created by Grant Kemp on 01/09/2016.
//  Copyright © 2016 Bernard Gatt. All rights reserved.
//

import UIKit

class StylePreviewerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var picker_Data = [String]()
    
    @IBOutlet weak var tf_SelectFont: UITextField!
    
    @IBOutlet weak var picker_FontSelector: UIPickerView!
    
    @IBOutlet weak var lbl_textPreview: UILabel!
    
    //MARK: UI Actions
    
    @IBAction func atf_selectedFontTextField(sender: UITextField) {
        _StartSelectingFont()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    //MARK: Methods
    
    func _StartSelectingFont() {
        picker_FontSelector.hidden = false
    }
    
    func _DidSelectFontfromPicker(fontfamilyname:String) {
        let selectedFont = picker_FontSelector.selectedRowInComponent(0)
        lbl_textPreview.font = UIFont(name: fontfamilyname, size: 18)
        lbl_textPreview.hidden = false
        tf_SelectFont.text = fontfamilyname
    }
    
    
    //MARK: View Setup
    func setupView() {
        picker_FontSelector.hidden = true
        tf_SelectFont.placeholder = "Select Font"
        lbl_textPreview.hidden = true
        picker_Data = generateFonts()
    }
    
    //MARK: Picker Delegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return picker_Data.count
     
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return picker_Data[row]
    }
    
    //MARK: Helpers
    //TODO: Move this to seperate Utility Class
    func generateFonts() -> [String] {
       return  UIFont.familyNames()
        
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let fontSelected = picker_Data[row]
        _DidSelectFontfromPicker(fontSelected)
    }
    
}
