//
//  LStoreManager.h
//  RopeFlay
//
//  Created by Chen on 7/23/13.
//
//

#import <Foundation/Foundation.h>
#import "EBPurchase.h"

@protocol LPurchaseDelegateIOS <NSObject>
@optional

-(void) purchaseSuccessed:(NSString*) productId;
-(void) purchaseFailed:(NSString*) productId message:(NSString*) errMsg;
-(void) restoreSuccessed:(NSArray*) productIdList;
-(void) restoreFailed:(NSString*) errMsg;

@end

@interface LStoreManagerIOS : NSObject <EBPurchaseDelegate>
{
    EBPurchase* ebPurchase;
    BOOL        isTestMode;
    id<LPurchaseDelegateIOS> delegate;
}

@property (nonatomic, assign) id<LPurchaseDelegateIOS> delegate;

-(bool) isPurchasedProductId:(NSString*) productId;
-(bool) buyProduct:(NSString*) productId;
-(bool) restore;
-(void) setTestMode;
+(LStoreManagerIOS*) sharedInstance;
@end
