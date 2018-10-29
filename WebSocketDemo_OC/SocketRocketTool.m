//
//  SocketRocketTool.m
//  JSONTest
//
//  Created by guojianheng on 2018/9/27.
//  Copyright © 2018年 guojianheng. All rights reserved.
//

#import "SocketRocketTool.h"

// 接受SRWebSocketDelegate
@interface SocketRocketTool()<SRWebSocketDelegate>
// SRWebSocket
@property (nonatomic,strong)SRWebSocket *socket;
// 发送ping的计时器
@property(nonatomic,strong)NSTimer *pingTimer;
// 重新连接的计时器
@property(nonatomic,strong)NSTimer *reconnetTimer;

@end

static const NSTimeInterval WebSocketHeartBeatTimeInterval = 1.0;

@implementation SocketRocketTool

// 单例方法
static SocketRocketTool * instance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    }) ;
    return instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [SocketRocketTool sharedInstance];
}
- (id)copyWithZone:(struct _NSZone *)zone
{
    return [SocketRocketTool sharedInstance];
}

#pragma mark SRWebSocket  Open&Close&Send
// 连接webSocket
- (void)connect
{
    // 发出连接webSocket的通知,需不需要使用由自己决定
//    NSNotification *notification = [[NSNotification alloc]initWithName:kWebSocketWillConnectNoti object:nil userInfo:nil];
//    [[NSNotificationCenter defaultCenter]postNotification:notification];
    if (![self isNullObject:self.socket])
    {
        [self.socket close];
        self.socket = nil;
    }
    
    self.socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.wsURLString]]];
    self.observerQueue=[[NSMutableSet alloc] init];
    self.socket.delegate=self;
    [self.socket open];
    NSLog(@"[方法:%s-行数:%d]WebSocket_Host_URL:%@",__FUNCTION__,__LINE__,self.wsURLString);
}


-(void)socketAddObserver:(id)observer{
    if (![self.observerQueue containsObject:observer]) {
        [self.observerQueue addObject:observer];
    }
}

-(void)socketRemoveObserver:(id)observer{
    if ([self.observerQueue containsObject:observer]) {
        [self.observerQueue removeObject:observer];
    }
}

// 发送消息的方法
- (BOOL)sendString:(NSString *)string error:(NSError **)error{
    // webSocket没有打开的状态下
    if (self.socket.readyState != SR_OPEN) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(webSocketDidClose:)]) {
            [self.delegate webSocketDidClose:self.socket];
        }
        NSLog(@"发送json时webSocket没有打开!");
        return NO;
    }
    if ([self stringIsNull:string]) {
        NSLog(@"[方法:%s-行数:%d]发送json数据为空!",__FUNCTION__,__LINE__);
        return NO;
    }
    NSLog(@"\n[方法:%s-行数:%d]\n发送消息:\n%@\n",__FUNCTION__,__LINE__,string);
    [self.socket send:string];
    return YES;
}

- (BOOL)sendData:(nullable NSData *)data error:(NSError **)error{
    if (self.socket.readyState != SR_OPEN) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(webSocketDidClose:)]) {
            [self.delegate webSocketDidClose:self.socket];
        }
        NSLog(@"发送data时webSocket没有打开!");
        return NO;
    }
    if (data.length==0) {
        NSLog(@"[方法:%s-行数:%d]发送data数据为空!",__FUNCTION__,__LINE__);
        return NO;
    }
    [self.socket send:data ];
    return YES;
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSString * aMessage = (NSString*)message?:@"";
    if (![self stringIsNull:aMessage])
    {
        NSDictionary *dic = @{@"message":aMessage};
        NSLog(@"webSocket根源收到的消息:%@",dic);
//        NSNotification *notification = [[NSNotification alloc]initWithName:kWebSocketReciveMessgeNoti object:nil userInfo:dic];
//        [[NSNotificationCenter defaultCenter]postNotification:notification];
    }else
    {
        NSLog(@"[方法:%s-行数:%d] message is null !",__FUNCTION__,__LINE__);
    }
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(webSocket:didReceiveMessage:)]) {
        [self.delegate webSocket:webSocket didReceiveMessage:message];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(NSString *)string{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(webSocket:didReceiveMessageWithString:)]) {
        [self.delegate webSocket:webSocket didReceiveMessageWithString:string];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithData:(NSData *)data{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(webSocket:didReceiveMessageWithData:)]) {
        [self.delegate webSocket:webSocket didReceiveMessageWithData:data];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    NSLog(@"[方法:%s-行数:%d]\nwebSocketDidOpen!\n",__FUNCTION__,__LINE__);
    // 连接webSocket成功时发出的通知
//    NSNotification *notification = [[NSNotification alloc]initWithName: kWebSocketConnectDidSuccessNoti object:nil userInfo:nil];
//    [[NSNotificationCenter defaultCenter]postNotification:notification];
    // webSockeet连接每一秒发送一个Ping指令
    [self startPing];
    NSError *error;
    [self sendString:@"testString" error:&error];
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(webSocketDidOpen:)]) {
        [self.delegate webSocketDidOpen:webSocket];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@"[方法:%s-行数:%d] [webSocket connect fail error resson:]%@\n[closed createTime]%@[closed host]%@\n",__FUNCTION__, __LINE__,error.description,[NSDate date],webSocket.url);
    if (self.delegate&&[self.delegate respondsToSelector:@selector(webSocket:didFailWithError:)]) {
        [self.delegate webSocket:webSocket didFailWithError:error];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason wasClean:(BOOL)wasClean{
    NSLog(@"[方法:%s-行数:%d][webSocketClosed with reason:]%@\n[closed createTime:]%@\n[closed host:]%@\n" ,__FUNCTION__, __LINE__,reason,[NSDate date],webSocket.url);
    if (self.delegate&&[self.delegate respondsToSelector:@selector(webSocket:didCloseWithCode:reason:wasClean:)]) {
        [self.delegate webSocket:webSocket didCloseWithCode:code reason:reason wasClean:wasClean];
    }
    // webSocket断开连接发出的通知
//    NSNotification *notification = [[NSNotification alloc]initWithName: kWebSocketConnectDidCloseNoti object:nil userInfo:nil];
//    [[NSNotificationCenter defaultCenter]postNotification:notification];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePingWithData:(nullable NSData *)data{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(webSocket:didReceivePingWithData:)]) {
        [self.delegate webSocket:webSocket didReceivePingWithData:data];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(nullable NSData *)pongData{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(webSocket:didReceivePong:)]) {
        [self.delegate webSocket:webSocket didReceivePong:pongData];
    }
}

#pragma -mark Heartbeat

-(void)startPing{
    if (_pingTimer) {
        [_pingTimer invalidate];
        _pingTimer = nil;
    }
    
    if (_reconnetTimer) {
        [_reconnetTimer invalidate];
        _reconnetTimer = nil;
    }
    _pingTimer = [NSTimer scheduledTimerWithTimeInterval:WebSocketHeartBeatTimeInterval target:self selector:@selector(sendPing:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_pingTimer forMode:NSRunLoopCommonModes];
}

-(void)sendPing:(id)sender{
    if (self.socket.readyState == SR_OPEN)
    {
        NSError *error;
        [self.socket sendPing:nil];
        if (error) {
            NSLog(@"%s:%d %@", __FUNCTION__, __LINE__,error);
        }
    }else
    {
        [_pingTimer invalidate];
        _pingTimer = nil;
        [self reconnect];
    }
}

- (void)destoryHeartBeat{
    if (_pingTimer) {
        [_pingTimer invalidate];
        _pingTimer = nil;
    }
}

#pragma -mark Reconnect

-(void)reconnect{
    // 连接
    [self connect];
    NSLog(@"[%s:%d]reconnecting! ",__FUNCTION__,__LINE__);
    [self closeWebSocket];
    _reconnetTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(startReconnect) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_reconnetTimer forMode:NSRunLoopCommonModes];
}

-(void)startReconnect
{
    self.socket = nil;
    [self connect];
    NSLog(@"%s:%d socket reconnecting!", __FUNCTION__, __LINE__);
}

-(void)closeWebSocket{
    if (self.socket){
        [self.socket close];
        self.socket = nil;
        [self destoryHeartBeat];
    }
}

#pragma -mark util

- (BOOL)stringIsNull:(NSString *)string
{
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    
    if (!string || [string isKindOfClass:[NSNull class]] || string.length == 0 || [string isEqualToString:@""]) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)isNullObject:(id)anObject
{
    if (!anObject || [anObject isKindOfClass:[NSNull class]]) {
        return YES;
    }else{
        return NO;
    }
}

@end
