//
//  SectionHeaderView.swift
//  CollapseTableView
//


import UIKit
import CollapseTableView

class SectionHeaderView: UITableViewHeaderFooterView, CollapseSectionHeader {
    
    @IBOutlet weak var imageView: UIImageView!
    var recordLabelText : String?
    var indicatorImageView: UIImageView {
        return imageView
    }
    func setRecordLabel(recordLabelValue: String) -> Void {
       
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.image = #imageLiteral(resourceName: "arrow_down").withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
      
    }
}
