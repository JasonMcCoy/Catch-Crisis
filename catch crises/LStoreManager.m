//
//  LStoreManagerIOS.m
//  RopeFlay
//
//  Created by Chen on 7/23/13.
//
//

#import "LStoreManagerIOS.h"

@implementation LStoreManagerIOS

+(LStoreManagerIOS*) sharedInstance
{
    static LStoreManagerIOS* instance = nil;
    if (instance == nil)
        instance = [[LStoreManagerIOS alloc] init];
    return instance;
}

-(id) init
{
    if (self = [super init])
    {
        ebPurchase = [[EBPurchase alloc] init];
        ebPurchase.delegate = self;
        
        isTestMode = NO;
    }
    
    return self;
}

-(bool) isPurchasedProductId:(NSString*) productId
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault boolForKey:productId];
}
-(bool) buyProduct:(NSString*) productId
{
    if (isTestMode)
    {
        [self successfulPurchase:nil identifier:productId receipt:nil];
        return YES;
    }
    return [ebPurchase requestProduct:productId];
}
-(bool) restore
{
    if (isTestMode)
    {
        [self successfulRestore:ebPurchase purchasedList: nil];
        return YES;
    }
    return [ebPurchase restorePurchase];
}

-(void) requestedProduct:(EBPurchase*)ebp identifier:(NSString*)productId name:(NSString*)productName price:(NSString*)productPrice description:(NSString*)productDescription
{
    if (ebPurchase.validProduct)
    {
        [ebPurchase purchaseProduct:ebPurchase.validProduct];
    }
    else if ([self.delegate respondsToSelector:@selector(purchaseFailed:message:)])
    {
        [self.delegate purchaseFailed:ebp.validProduct.productIdentifier message:@"Invalid Product"];
    }
}

-(void) successfulPurchase:(EBPurchase*)ebp identifier:(NSString*)productId receipt:(NSData*)transactionReceipt
{
    if ([self.delegate respondsToSelector:@selector(purchaseSuccessed:)])
    {
        [self.delegate purchaseSuccessed:productId];
    }
}

-(void) failedPurchase:(EBPurchase*)ebp error:(NSInteger)errorCode message:(NSString*)errorMessage
{
    if ([self.delegate respondsToSelector:@selector(purchaseFailed:message:)])
    {
        if (ebp.validProduct) {
            [self.delegate purchaseFailed:ebp.validProduct.productIdentifier message:errorMessage];
        }
    }
}

-(void) successfulRestore:(EBPurchase*)ebp purchasedList:(NSArray*) productIdList
{
    if ([self.delegate respondsToSelector:@selector(restoreSuccessed:)])
    {
        [self.delegate restoreSuccessed:productIdList];
    }
}

-(void) failedRestore:(EBPurchase*)ebp error:(NSInteger)errorCode message:(NSString*)errorMessage
{
    if ([self.delegate respondsToSelector:@selector(restoreFailed:)])
    {
        [self.delegate restoreFailed:errorMessage];
    }
}

-(void) setTestMode
{
    isTestMode = YES;
}

@end
