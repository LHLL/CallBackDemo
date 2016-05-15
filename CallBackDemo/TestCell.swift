//
//  TestCell.swift
//  ClosureCallback
//
//  Created by Xu, Jay on 5/10/16.
//  Copyright © 2016 Xu, Jay. All rights reserved.
//

import UIKit

class TestCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var myTextField: UITextField!
    var shouldUpdateidLabel: (() -> Void)?
    var testClosure1: (String -> Void)?
    var testClosure2: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myTextField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.shouldUpdateidLabel!()
        self.testClosure1!(myTextField.text!)
        self.testClosure2!(myTextField.text!)
        myTextField.resignFirstResponder()
        return true
    }
}
