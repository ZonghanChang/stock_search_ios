//
//  AutocompleteCellData.swift
//  Autocomplete
//
//  Created by Amir Rezvani on 3/12/16.
//  Copyright © 2016 cjcoaxapps. All rights reserved.
//

import UIKit

public protocol AutocompletableOption {
    var text: String { get }
    var symbol: String { get }
}

open class AutocompleteCellData: AutocompletableOption {
    fileprivate let _text: String
    open var text: String { get { return _text } }
    open let image: UIImage?
    open let symbol: String

    public init(text: String, symbol: String, image: UIImage?) {
        self._text = text
        self.image = image
        self.symbol = symbol
    }
}
