//
//  VKAuthViewController.swift
//  VK
//
//  Created by Ilyas Tyumenev on 30/07/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit
import WebKit

class VKAuthViewController: UIViewController, WKNavigationDelegate {
    let session = Session.instance
    lazy var firebase = FirebaseService()
    
    // MARK: - Outlets
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        loadVKAuth()
    }
    
    // MARK: - loadVKAuth
    func loadVKAuth() {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "oauth.vk.com"
        components.path = "/authorize"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: "8146788"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "scope", value: "wall,friends,photos"),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "v", value: "5.131")
        ]
        
        guard let url = components.url else { return }
        let request = URLRequest(url: url)
        print("\nURL запроса авторизации:", url, "\n")        
        webView.load(request)
    }
    
    // MARK: - WKNavigationDelegate
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) { // метод, который перехватывает ответы сервера при переходе
        
        // Можем отслеживать все переходы и отменять либо разрешать их по необходимости. Первая часть кода проверяет URL,
        // на который было совершено перенаправление. Если это нужный нам URL (/blank.html), и в нем есть токен,
        // приступим к его обработке, если же нет, дадим зеленый свет на переход между страницами c помощью метода
        // decisionHandler(.allow). Дальше мы просто режем строку с параметрами на части, используя как разделители
        // символы & и =. В результате получаем словарь с параметрами.
        
        guard let url = navigationResponse.response.url,
              url.path == "/blank.html",
              let fragment = url.fragment  else {
            decisionHandler(.allow)
            return
        }
        
        let params = fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
            }
        
        if let token = params["access_token"], let userId = params["user_id"] {
            session.token = token
            session.userId = userId
            firebase.logUser()
            
            print("Token:", token)
            print("User ID:", userId)
            
            performSegue(withIdentifier: "tabBarController", sender: nil)
        } else {
            print("No access token found")
        }
        
        decisionHandler(.cancel)
    }    
}   
