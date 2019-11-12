//
//  AppDelegate.swift
//  PhotosDemo
//
//  Created by Vlad Zhavoronkov on 11/8/19.
//  Copyright © 2019 Zhvrnkov. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let tabBarCon = UITabBarController(nibName: nil, bundle: nil)
        let base = BaseViewModel()
        let storage = SavedPhotosStorage()
        tabBarCon.viewControllers = [
            UINavigationController(rootViewController: getMain(vm: VMMainViewController(base: base, savedStorage: storage))),
            UINavigationController(rootViewController: getSaved(vm: VMSavedPhotosViewController(savedStorage: storage)))
        ]
        window?.rootViewController = tabBarCon
        window?.makeKeyAndVisible()

        return true
    }

    func getMain(vm: MainViewModel) -> MainViewController {
        let vc = MainViewController()
        vc.viewModel = vm
        return vc
    }

    func getSlider(vm: SliderViewModel) -> ImageSliderViewController {
        let vc = ImageSliderViewController()
        vc.viewModel = vm
        return vc
    }

    func getSaved(vm: SavedPhotosViewModel) -> SavedPhotosViewController {
        let vc = SavedPhotosViewController()
        vc.viewModel = vm
        return vc
    }
}
