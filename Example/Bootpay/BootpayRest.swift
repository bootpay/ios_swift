//
//  BootpayRest.swift
//  Bootpay_Example
//
//  Created by Taesup Yoon on 2022/06/02.
//  Copyright © 2022 CocoaPods. All rights reserved.
//


import UIKit
import Alamofire
import Bootpay


var isDebug = false

@objc public protocol BootpayRestProtocol {
  @objc(callbackRestToken:) func callbackRestToken(resData: [String: Any])
  @objc(callbackEasyCardUserToken:) func callbackEasyCardUserToken(resData: [String: Any])
}

@available(*, deprecated, message: "이 로직은 서버사이드에서 수행되어야 합니다. rest_application_id와 prviate_key는 보안상 절대로 노출되어서 안되는 값입니다. 개발자의 부주의로 고객의 결제가 무단으로 사용될 경우, 부트페이는 책임이 없음을 밝힙니다.")
@objc public class BootpayRest: NSObject {
  @objc(getRestToken:::)
  public static func getRestToken(
       sendable: BootpayRestProtocol,
       restApplicationId: String,
       privateKey: String) {
      
      var params = [String: Any]()
      params["application_id"] = restApplicationId
      params["private_key"] = privateKey
      
           
      var url = "https://api.bootpay.co.kr/v2/request/token.json"
      if(isDebug) {
        url = "https://dev-api.bootpay.co.kr/v2/request/token.json"
      }
   
           
      Alamofire.request(url,
                 method: .post,
                 parameters: params,
                 encoding: URLEncoding.default)
               .validate()
               .responseJSON { response in
                  
                  switch response.result {
                  case .success(let value):
//                        print("token \(value)")
                      guard let res = value as? [String: AnyObject] else { return }
                      sendable.callbackRestToken(resData: res)
//                        if let value = value as? [String: AnyObject] {

//                        }
                  case .failure(_):
                      if let data = response.data {
                          if let jsonString = String(data: data, encoding: String.Encoding.utf8), let json = jsonString.convertToDictionary() {
                              print(json)
                          }
                      }
                  }
      }
  }
  
  
  @objc(getEasyPayUserToken:::)
  public static func getEasyPayUserToken(sendable: BootpayRestProtocol,
                                         restToken: String,
                                         user: BootUser) {
       
      
      do {
          var params = [String: Any]()
          params["user_id"] = user.id
          params["email"] = user.email
          params["username"] = user.username
          params["gender"] = user.gender
          params["birth"] = user.birth
          params["phone"] = user.phone
          
          let headers: HTTPHeaders = [
              "Authorization": "Bearer \(restToken)",
              "Accept": "application/json"
          ]
          
          var url = "https://api.bootpay.co.kr/v2/request/user/token"
          if(isDebug) {
            url = "https://dev-api.bootpay.co.kr/v2/request/user/token"
          }
          
          Alamofire.request(
               url,
               method: .post,
               parameters: params,
               encoding:  URLEncoding.default,
               headers: headers
          )
         .validate()
         .responseJSON { response in
                      
              switch response.result {
              case .success(let value):
                  print(value)
                  if let value = value as? [String: AnyObject] {
                      sendable.callbackEasyCardUserToken(resData: value)
                  }
              case .failure(_):
                  if let data = response.data {
                      if let jsonString = String(data: data, encoding: String.Encoding.utf8), let json = jsonString.convertToDictionary() {
                          print(json)
                      }
                  }
              }
         }
      } catch {
          print(error)
      }
  }
}



