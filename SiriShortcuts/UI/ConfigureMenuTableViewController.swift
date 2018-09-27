//
//  ConfigureMenuTableViewController.swift
//  SiriShortcuts
//
//  Created by Lee on 2018/9/27.
//  Copyright © 2018 Lee. All rights reserved.
//

import UIKit

class ConfigureMenuTableViewController: UITableViewController {
    enum SectionType {
        case regularItems, specialItems
    }
    
    private typealias SectionModel = (sectionType: SectionType, sectionHeaderText: String, sectionFooterText: String, rowContent: [String])
    
    private var sectionData: [SectionModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    private func reloadData() {
        
    }
}
