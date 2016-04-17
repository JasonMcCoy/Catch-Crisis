//
//  LStoreManager.h
//  RopeFlay
//
//  Created by Chen on 7/23/13.
//
//

#import <Foundation/Foundation.h>
#import "EBPurchase.h"

@protocol LPurchaseDelegate <NSObject>

@optional
-(void) purchaseSuccessed:(NSString*) productId;
-(void) purchaseFailed:(NSString*) productId message:(NSString*) errMsg;
-(void) restoreSuccessed:(NSArray*) productIdList;
-(void) restoreFailed:(NSString*) errMsg;

@end

@interface LStoreManager : NSObject <EBPurchaseDelegate>
{
    EBPurchase* ebPurchase;
    BOOL        isTestMode;
}

@property (nonatomic, assign) id<LPurchaseDelegate> delegate;

-(bool) isPurchasedProductId:(NSString*) productId;
-(bool) buyProduct:(NSString*) productId;
-(bool) restore;
-(void) setTestMode;
+(LStoreManager*) sharedInstance;
@end
