//
//  Routable
//
//  Copyright (c) 2017 linhay - https://github.com/linhay
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

import Foundation

extension Routable {
  
  /// 格式化url
  ///
  /// - Parameters:
  ///   - url: 待格式化 url 或 url 字符串
  ///   - params: 待拼接入url得参数
  /// - Returns: 合并后的 url
  public class func createURL(url: String,params:[String: Any]) -> URL?{
    if params.isEmpty { return URL(string: url) }
    guard var components = URLComponents(string: url) else { return nil }
    var querys = components.queryItems ?? []
    let newQuerys = params.map { (item) -> URLQueryItem in
      switch item.value {
      case let v as String:
        return URLQueryItem(name: item.key, value: v)
      case let v as [String:Any]:
        return URLQueryItem(name: item.key, value: RoutableHelp.formatJSON(data: v))
      case let v as [Any]:
        return URLQueryItem(name: item.key, value: RoutableHelp.formatJSON(data: v))
      default:
        return URLQueryItem(name: item.key, value: String(describing: item.value))
      }
    }
    querys += newQuerys
    components.queryItems = querys
    return components.url
  }
  
  /// 处理参数类型
  ///
  /// - Parameter string: 需要处理的参数字符
  /// - Returns: 处理后类型
  class func dealValueType(string: String?) -> Any? {
    guard var str = string?.removingPercentEncoding else { return string }
    guard !str.isEmpty else { return str }
    str = str.trimmingCharacters(in: CharacterSet.whitespaces)
    guard str.hasPrefix("[") || str.hasPrefix("{") else { return str }
    let dict = RoutableHelp.dictionary(string: str)
    if !dict.isEmpty { return dict }
    let array = RoutableHelp.array(string: str)
    if !array.isEmpty { return array }
    return str
  }
  
  /// 获取路径所需参数
  ///
  /// - Parameter url: 路径
  /// - Returns: 所需参数
  class func urlParse(url: URL) -> URLValue?{
    
    /// 处理协议头合法
    guard (scheme.isEmpty || url.scheme == scheme),
      let function = url.path.components(separatedBy: "/").last,
      let className = url.host else { return nil }
    
    /// 处理参数
    var params = [String: Any]()
    if let urlstr = url.query {
      urlstr.components(separatedBy: "&").forEach { (item) in
        let list = item.components(separatedBy: "=")
        if list.count == 2 {
          params[list.first!] = dealValueType(string: list.last)
        }else if list.count > 2 {
          params[list.first!] = dealValueType(string: list.dropFirst().joined())
        }
      }
    }
    return URLValue(targetName: className, selName: function, params: params)
  }
  
  /// 重定向策略
  class func rewrite(value: URLValue) -> URLValue {
    guard let id = getCacheId(value: value), var rule = repleRules[id] else { return value }
    var params = value.params
    
    /// 先执行覆盖原有key 后执行新增key
    /// 覆盖原有参数的值
    rule.params.forEach { (item) in
      if let v = item.value as? String, v.hasPrefix("$"){}
      else{
        params[item.key] = item.value
      }
    }
    
    rule.params.forEach { (item) in
      /// 从原有参数取值
      if var v = item.value as? String, v.hasPrefix("$"){
        v.removeFirst()
        params[item.key] = params[v]
      }
    }
    
    rule.params = params
    return rule
  }
  
}
