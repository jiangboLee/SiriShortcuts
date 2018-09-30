# SiriShortcuts
Siri Shortcuts是iOS 12中强大的新功能，允许您的应用向Siri公开其功能。这使Siri能够根据不同的背景在相关时间建议您的快捷方式。快捷方式也可以添加到Siri，以便在iOS，HomePod和watchOS上使用语音短语运行。先奉上苹果官方的[WWDC视频](https://developer.apple.com/videos/play/wwdc2018/211/),苹果的[官方demo下载地址,Soup Chef](https://developer.apple.com/documentation/sirikit/soup_chef_accelerating_app_interactions_with_shortcuts)

#### 仿写demo的体会、错误
官方demo里面的文件是很多，想要一下子就明白是很难的。所以我决定重写一遍官方demo，看代码最好的方式就是照着自己来一遍，其中的所有也就能明白了~
1. 发现国外的demo都喜欢storyBoard布局，这样确实是快，其实我也很喜欢，工作中同事反倒都提示少用，这么好的图形化界面不用，多可惜。
- 在storyboard中dismiss回来
```swift
/// 用于返回此控制器,现在present这个控制器，然后连线即可
    @IBAction func unwind(for unwindSegue: UIStoryboardSegue) {
        
    }
```
- xcode10 选择libranys是不是选一个要点一次很麻烦？
只需要按住`option`键拖一次，他就会一直留在页面上了
2. 数据封装的很好，在控制器中很干净，直接拿着数据源使用，没有其他杂七杂八的数据处理，（特别是tableview的数据源，可以好好学习下）。对于共享的代码推荐使用framework封装一下，target之间就不需要相互引用。（视频中也有介绍这个）
3. extension要多用哦，跟这demo比起来发现平时用的还是不够多。只要能扩展的就多用吧~
#### 入正题吧，SiriShortcuts使用
如果是打开 App 特定页面，跳转到 App 内用户继续完成一些操作，在 Spotlight 结果中复现已经索引的内容，这种情况的 Shortcut 推荐使用 NSUserActivity 来实现，只需修改 userActivity 的新属性 isEligibleForPrediction ，并向 viewcontroller 的 userActivity 属性赋值即可完成 donate。
这里有[一篇文章,使用NSUserActivity](https://swift.gg/2018/09/20/siri-shortcuts/)
如果用户无需跳转到 App 内，通过 Siri 语音或者自定义的 Siri 展示界面即可响应用户需求（使用 Siri Intent Extension Target 响应），推荐使用 Intents ， 当然 Intent 也可以实现跳转到 App。这个是本文的重点。
##### 先创建Intents.intentdefinition文件

![效果图.gif](https://upload-images.jianshu.io/upload_images/2868618-160082efb2148983.gif?imageMogr2/auto-orient/strip)

![image.png](https://upload-images.jianshu.io/upload_images/2868618-9911abbe9c5a099c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![image.png](https://upload-images.jianshu.io/upload_images/2868618-ea68e347839fc55d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
描述信息title什么的网上说有助于siri语义分析 推荐！
![image.png](https://upload-images.jianshu.io/upload_images/2868618-789251983f4a722f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![image.png](https://upload-images.jianshu.io/upload_images/2868618-6fc1e74ae8b8cb97.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image.png](https://upload-images.jianshu.io/upload_images/2868618-2422d23b8572e940.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
这个是Response:
![image.png](https://upload-images.jianshu.io/upload_images/2868618-d4d83a816444dcbc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

然后编译，系统会自动生成一个文件,你在主项目中是看不到的，但可以使用OrderSoupIntent
```swift
public class OrderSoupIntent: INIntent {

    @NSManaged public var soup: INObject?
    @NSManaged public var quantity: NSNumber?
    @NSManaged public var options: [INObject]?

}
@available(iOS 12.0, watchOS 5.0, *)
@objc(OrderSoupIntentHandling)
public protocol OrderSoupIntentHandling: NSObjectProtocol {
    @objc(handleOrderSoup:completion:)
    func handle(intent: OrderSoupIntent, completion: @escaping (OrderSoupIntentResponse) -> Swift.Void)

    @objc(confirmOrderSoup:completion:)
    optional func confirm(intent: OrderSoupIntent, completion: @escaping (OrderSoupIntentResponse) -> Swift.Void)
}

/*!
 @abstract Constants indicating the state of the response.
 */
@available(iOS 12.0, watchOS 5.0, *)
@objc public enum OrderSoupIntentResponseCode: Int {
    case unspecified = 0
    case ready
    case continueInApp
    case inProgress
    case success
    case failure
    case failureRequiringAppLaunch
    case failureOutOfStock = 100
    case successReadySoon
}

@available(iOS 12.0, watchOS 5.0, *)
@objc(OrderSoupIntentResponse)
public class OrderSoupIntentResponse: INIntentResponse {
}
```
接下来创建Intents UI Extension

![image.png](https://upload-images.jianshu.io/upload_images/2868618-a23e43403257605e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

在`IntentHandler.swift`文件中
```swift
class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        
        guard intent is OrderSoupIntent else {
            fatalError("Unhandled intent type: \(intent)")
        }
        
        return OrderSoupIntentHandler()
    }
}
```
```swift
public class OrderSoupIntentHandler: NSObject, OrderSoupIntentHandling {
    
    ///确认下单回调方法
    public func handle(intent: OrderSoupIntent, completion: @escaping (OrderSoupIntentResponse) -> Void) {
        
        guard let soup = intent.soup,
            let order = Order(from: intent) else {
                completion(OrderSoupIntentResponse(code: .failure, userActivity: nil))
                return
        }
        //下单
        let ordermanager = SoupOrderDataManager()
        ordermanager.placeOrder(order: order)
        
        let orderdate = Date()
        let readydate = Date(timeInterval: 10 * 60, since: orderdate)
        
        let userActivity = NSUserActivity(activityType: NSUserActivity.orderCompleteActivityType)
        userActivity.addUserInfoEntries(from: [NSUserActivity.ActivityKeys.orderID.rawValue: order.identifier])
        print(order.identifier)
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        if let formattedWaitTime = formatter.string(from: orderdate, to: readydate) {
            let response = OrderSoupIntentResponse.success(soup: soup, waitTime: formattedWaitTime)
            response.userActivity = userActivity
            
            completion(response)
        } else {
            // A fallback success code with a less specific message string
            let response = OrderSoupIntentResponse.successReadySoon(soup: soup)
            response.userActivity = userActivity
            
            completion(response)
        }
    }
    
    public func confirm(intent: OrderSoupIntent, completion: @escaping (OrderSoupIntentResponse) -> Void) {
        ///确认阶段为您提供了对意图参数进行任何最终验证的机会,验证是否有任何所需的服务。您可能确认可以与公司的服务器通信
        let soupMenuManager = SoupMenuManager()
        guard let soup = intent.soup,
            let identifier = soup.identifier,
            let menuItem = soupMenuManager.findItem(identifier: identifier) else {
                completion(OrderSoupIntentResponse(code: .failure, userActivity: nil))
                return
        }
        
        if menuItem.isAvailable == false {
            completion(OrderSoupIntentResponse.failureOutOfStock(soup: soup))
            return
        }
        //验证意图后，指示意图已准备好处理
        completion(OrderSoupIntentResponse(code: .ready, userActivity: nil))
    }
}
```

在`IntentViewController`中
```swift
 // 准备视图控制器以进行交互处理
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        // 在此处进行配置，包括准备视图和计算所需的演示文稿大小
        
        guard let intent = interaction.intent as? OrderSoupIntent else {
            completion(false, Set(), .zero)
            return
        }
        //可以显示不同的UI，这取决于意图是在确认阶段还是处理阶段。此示例使用视图控制器包含来通过专用视图控制器管理每个不同的视图
        if interaction.intentHandlingStatus == .ready {
            let invoiceVC = InvoiceViewController(for: intent)
            attachChild(invoiceVC)
            completion(true, parameters, desiredSize)
        } else if interaction.intentHandlingStatus == .success {
            if let response = interaction.intentResponse as? OrderSoupIntentResponse {
                let confirmedVC = OrderConfirmedViewController(for: intent, with: response)
                attachChild(confirmedVC)
                completion(true, parameters, desiredSize)
            }
        }
        completion(false, parameters, .zero)
    }
    
    /// UI尺寸
    var desiredSize: CGSize {
        let width = self.extensionContext!.hostedViewMaximumAllowedSize.width
        
        return CGSize(width: width, height: 170)
    }
```
我去，感觉不知道怎么说啊，直接看代码吧
![image.png](https://upload-images.jianshu.io/upload_images/2868618-4928e8349474918c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
这个要注意，一定要把item改为OrderSoupIntent!!!不然你siri可能没什么效果

好了，大家自己看代码吧，[重写代码地址](https://github.com/jiangboLee/SiriShortcuts)
使用git管理，大家可以根据commit一个个看，会比较清晰点。












