//
//  ViewController.m
//  WebSocketDemo_OC
//
//  Created by guojianheng on 2018/10/26.
//  Copyright © 2018年 guojianheng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<SocketRocketToolDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 连接webSocket
    [self connectWebSocket];
}
// 连接webSockeet
- (void)connectWebSocket
{
    [SocketRocketTool sharedInstance].wsURLString = @"ws://192.168.36.60:8081/websocket";
    [[SocketRocketTool sharedInstance]connect];
    [SocketRocketTool sharedInstance].delegate = self;
}

#pragma mark ----- SocketRocketToolDelegate方法 -----
// webSocket已经打开
- (void)webSocketDidOpen:(SRWebSocket *_Nullable)webSocket
{
    
}
// webSocket已经关闭
- (void)webSocketDidClose:(SRWebSocket *_Nullable)webSocket
{
    
}

// 收到json string类型消息的回调
- (void)webSocket:(SRWebSocket *_Nullable)webSocket didReceiveMessage:(id)message
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
