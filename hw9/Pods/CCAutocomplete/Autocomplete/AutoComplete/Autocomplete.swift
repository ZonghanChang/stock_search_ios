//
//  Autocomplete.swift
//  Autocomplete
//
//  Created by Amir Rezvani on 3/6/16.
//  Copyright © 2016 cjcoaxapps. All rights reserved.
//

import UIKit
open class Autocomplete {
    open class func setupAutocompleteForViewcontroller<T: UIViewController>(_ viewController: T) where T: AutocompleteDelegate {

        let podBundle: Bundle = Bundle(for: Autocomplete.self)

        let storyboard = UIStoryboard(name: "Autocomplete", bundle: podBundle)
        let autoCompleteViewController = storyboard.instantiateViewController(withIdentifier: "autocompleteScene") as! AutoCompleteViewController
        
        autoCompleteViewController.delegate = viewController

        autoCompleteViewController.willMove(toParentViewController: viewController)
        viewController.addChildViewController(autoCompleteViewController)
        autoCompleteViewController.didMove(toParentViewController: viewController)

        autoCompleteViewController.view.willMove(toSuperview: viewController.view)
        viewController.view.addSubview(autoCompleteViewController.view)
        autoCompleteViewController.view.didMoveToSuperview()

    }
}
