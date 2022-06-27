//
//  DetailViewController+extension.swift
//  Virtual Tourist
//
//  Created by Eyvind on 6/6/22.
//

import Foundation
import UIKit

extension DetailViewController{
    func applyFlowLayoutSpaces(){
        flowLayout.sectionInset.right = CELL_SPACES
        flowLayout.sectionInset.left = CELL_SPACES
        flowLayout.minimumInteritemSpacing = CELL_SPACES
        flowLayout.minimumLineSpacing = CELL_SPACES
        flowLayout.itemSize = getCellSize()
    }
    
    private func getCellSize() -> CGSize{
        let itemsPerRow = ITEMS_PER_ROW
        // Per each item there are n - 1 spaces to add between them and also adding the left and right is n - 1 + 2, then the result is n + 1
        let dimension = (flowLayout.collectionView!.frame.size.width - ((itemsPerRow + 1.0) * CELL_SPACES)) / itemsPerRow
        return CGSize(width: dimension, height: dimension)
    }
}
