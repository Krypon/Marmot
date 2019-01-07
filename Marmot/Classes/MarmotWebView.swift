//
//  Marmot
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

import WebKit

open class MarmotWebView: WKWebView {
  
  lazy var handler: MarmotHandler = { return MarmotHandler(webView: self) }()
  private var marmotUIDelegate: MarmotUIDelegate = MarmotUIDelegate()
  
  public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
    super.init(frame: frame, configuration: configuration)
    self.configuration.userContentController.add(handler, name: Marmot.key)
    self.scrollView.contentMode = .scaleAspectFit
    self.uiDelegate = marmotUIDelegate

    let bundlePath = Bundle(for: MarmotWebView.self).bundlePath + "/Marmot.bundle/"
    try? FileManager.default.contentsOfDirectory(atPath: bundlePath).compactMap { (item) -> String? in
      return item.hasSuffix(".js") ? bundlePath + item : nil
      }.forEach { (item) in
        do {
          let js = try String(contentsOfFile: item, encoding: .utf8)
          let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true)
          self.configuration.userContentController.addUserScript(script)
        } catch {
          print(error.localizedDescription)
        }
    }
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}



