//
//  SocketRocketTool.h
//  JSONTest
//
//  Created by guojianheng on 2018/9/27.
//  Copyright © 2018年 guojianheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket.h>

@protocol SocketRocketToolDelegate <NSObject>
@optional
// 收到id类型消息的回调
- (void)webSocket:(SRWebSocket *_Nullable)webSocket didReceiveMessage:(id _Nullable )message;
// 收到json string类型消息的回调
- (void)webSocket:(SRWebSocket *_Nullable)webSocket didReceiveMessageWithString:(NSString *_Nullable)string;
// 收到data类型消息的回调
- (void)webSocket:(SRWebSocket *_Nullable)webSocket didReceiveMessageWithData:(NSData *_Nullable)data;
// 收到连接错误的回调
- (void)webSocket:(SRWebSocket *_Nullable)webSocket didFailWithError:(NSError *_Nullable)error;
// 收到连接关闭的回调
- (void)webSocket:(SRWebSocket *_Nullable)webSocket didCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason wasClean:(BOOL)wasClean;
// 收到Ping-Pong的回调
- (void)webSocket:(SRWebSocket *_Nullable)webSocket didReceivePingWithData:(nullable NSData *)data;
- (void)webSocket:(SRWebSocket *_Nullable)webSocket didReceivePong:(nullable NSData *)pongData;
//
- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *_Nullable)webSocket NS_SWIFT_NAME(webSocketShouldConvertTextFrameToString(_:));
// webSocket已经打开
- (void)webSocketDidOpen:(SRWebSocket *_Nullable)webSocket;
// webSocket已经关闭
- (void)webSocketDidClose:(SRWebSocket *_Nullable)webSocket;
@end;

@interface SocketRocketTool : NSObject

// 代理属性
@property(nonatomic,weak) id<SocketRocketToolDelegate> delegate;
// 观察队列
@property (nonatomic,strong) NSMutableSet *observerQueue;
//
@property (nonatomic,strong) NSString *wsURLString;

// 单例对象
+ (instancetype)sharedInstance;

// 连接webSocket
- (void)connect;

// 重连webSocket
- (void)reconnect;

// 关闭WebSocket的连接
- (void)closeWebSocket;

// 添加观察
- (void)socketAddObserver:(id _Nullable )observer;

// 移除观察
- (void)socketRemoveObserver:(id _Nullable )observer;

// 发送json数据
- (BOOL)sendString:(NSString *)string error:(NSError **)error;

// 发送data
- (BOOL)sendData:(nullable NSData *)data error:(NSError **)error;

@end
