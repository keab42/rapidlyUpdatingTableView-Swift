//
//  ViewController.swift
//  rapidlyUpdatingTableView-Swift
//
//  Created by Matthew Keable on 22/05/2016.
//  Copyright © 2016 Matthew Keable. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var section1Slider: UISlider!
    @IBOutlet weak var section1ValueLabel: UILabel!
    @IBOutlet weak var section2Slider: UISlider!
    @IBOutlet weak var section2ValueLabel: UILabel!
    @IBOutlet weak var numberUpdatesSlider: UISlider!
    @IBOutlet weak var numberUpdatesValueLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        section1Slider.value = 0
        section1ValueLabel.text = "\(Int(section1Slider.minimumValue))"
        section2Slider.value = 0;
        section2ValueLabel.text = "\(Int(section2Slider.minimumValue))"
        numberUpdatesSlider.value = 0;
        numberUpdatesValueLabel.text = "\(Int(numberUpdatesSlider.minimumValue))"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func section1SliderValueChanged(sender:AnyObject) {
        let roundedVal = round(section1Slider.value);
        section1ValueLabel.text = "\(Int(roundedVal))"
        section1Slider.value = roundedVal
    }
    
    @IBAction func section2SliderValueChanged(sender:AnyObject) {
        let roundedVal = round(section2Slider.value);
        section2ValueLabel.text = "\(Int(roundedVal))"
        section2Slider.value = roundedVal;
    }
    
    @IBAction func updatesSliderValueChanged(sender:AnyObject){
        let roundedVal = round(numberUpdatesSlider.value);
        numberUpdatesValueLabel.text = "\(Int(roundedVal))"
        numberUpdatesSlider.value = roundedVal;
    }
    
    // MARK - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mainToTableSegue" {
            let sectionData = [Int(section1Slider.value), Int(section2Slider.value)];
            let dest:ConversationsListTableViewController  = segue.destinationViewController as! ConversationsListTableViewController
            //Set the information we need
            dest.sectionData = sectionData
            dest.updatesPerMinute = Int(numberUpdatesSlider.value)
        }
    }
    
}

