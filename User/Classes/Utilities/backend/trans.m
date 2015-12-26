//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Parse/Parse.h>
#import <Firebase/Firebase.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "PFUser+Util.h"
#import "converter.h"
#import "password.h"

#import "trans.h"

#pragma mark - Private Chat methods

//-------------------------------------------------------------------------------------------------------
NSString* StartNewTranslation(PFUser *user, PFUser *translator)
//-------------------------------------------------------------------------------------------------------
{
    NSString *userId1 = user.objectId;
    NSString *userId2 = translator.objectId;

    NSString *transId = ([userId1 compare:userId2] < 0) ? [userId1 stringByAppendingString:userId2] : [userId2 stringByAppendingString:userId1];
    int time = (int) [[NSDate date] timeIntervalSince1970];
    transId = [transId stringByAppendingString:[@(time) stringValue]];
    //-----------------------------------------------------------------------------------------------------
    NSArray *members = @[userId1, userId2];
    //---------------------------------------------------------------------------------------------------
    CreateTrans(userId2, transId, members, translator[PF_USER_FULLNAME], userId1, @"private");
    CreateTrans(userId1, transId, members, translator[PF_USER_FULLNAME], userId2, @"private");
    //---------------------------------------------------------------------------------------------------
    return transId;
}

//-------------------------------------------------------------------------------------------------------
void CreateTrans(NSString *userId, NSString *transId, NSArray *members, NSString *description, NSString *profileId, NSString *type)
//-------------------------------------------------------------------------------------------------------
{
    Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Trans", FIREBASE]];
    FQuery *query = [[firebase queryOrderedByChild:@"transId"] queryEqualToValue:transId];
    [query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
     {
         BOOL create = YES;
         //-------------------------------------------------------------------------------------------------
         if (snapshot.value != [NSNull null])
         {
             for (NSDictionary *recent in [snapshot.value allValues])
             {
                 if ([recent[@"userId"] isEqualToString:userId]) create = NO;
             }
         }
         //-------------------------------------------------------------------------------------------------
         if (create) CreateTransItem(userId, transId, members, description, profileId, type);
     }];
}
//-------------------------------------------------------------------------------------------------------
void CreateTransItem(NSString *userId, NSString *transId, NSArray *members, NSString *description, NSString *profileId, NSString *type)
//-------------------------------------------------------------------------------------------------------
{
    Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Trans", FIREBASE]];
    Firebase *reference = [firebase childByAutoId];
    //---------------------------------------------------------------------------------------------------
    NSString *recentId = reference.key;
    NSString *date = Date2String([NSDate date]);
    //---------------------------------------------------------------------------------------------------
    NSDictionary *recent = @{@"refkey":recentId, @"userId":userId, @"transId":transId, @"members":members, @"description":description,
                             @"lastMessage":@"", @"counter":@0, @"date":date, @"profileId":profileId, @"type":type, @"password":@"", @"transStatus":TRANS_STATUS_REQUESTED};
    //---------------------------------------------------------------------------------------------------
    [reference setValue:recent withCompletionBlock:^(NSError *error, Firebase *ref)
     {
         if (error != nil) NSLog(@"CreateTransItem save error.");
     }];
}

//-------------------------------------------------------------------------------------------------------
void RestartRecentTrans(NSDictionary *recent)
//-------------------------------------------------------------------------------------------------------
{
    if ([recent[@"type"] isEqualToString:@"private"])
    {
        for (NSString *userId in recent[@"members"])
        {
            if ([userId isEqualToString:[PFUser currentId]] == NO)
                CreateTrans(userId, recent[@"transId"], recent[@"members"], [PFUser currentName], [PFUser currentId], @"private");
        }
    }
}



#pragma mark - Update Recent methods

//-------------------------------------------------------------------------------------------------------
void UpdateRecents(NSString *transId, NSString *lastMessage)
//-------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Trans", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"transId"] queryEqualToValue:transId];
	[query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		if (snapshot.value != [NSNull null])
		{
			for (NSDictionary *recent in [snapshot.value allValues])
			{
				UpdateRecentItem(recent, lastMessage);
			}
		}
	}];
}

//-------------------------------------------------------------------------------------------------------
void UpdateRecentItem(NSDictionary *recent, NSString *lastMessage)
//-------------------------------------------------------------------------------------------------------
{
	NSString *date = Date2String([NSDate date]);
	NSInteger counter = [recent[@"counter"] integerValue];
	//---------------------------------------------------------------------------------------------------
	if ([recent[@"userId"] isEqualToString:[PFUser currentId]] == NO) counter++;
	//---------------------------------------------------------------------------------------------------
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Trans/%@", FIREBASE, recent[@"refkey"]]];
	NSDictionary *values = @{@"lastMessage":lastMessage, @"counter":@(counter), @"date":date};
	[firebase updateChildValues:values withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"UpdateRecentItem save error.");
	}];
}

#pragma mark - Clear Recent Counter methods

//-------------------------------------------------------------------------------------------------------
void ClearRecentCounter(NSString *transId)
//-------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Trans", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"transId"] queryEqualToValue:transId];
	[query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		if (snapshot.value != [NSNull null])
		{
			for (NSDictionary *recent in [snapshot.value allValues])
			{
				if ([recent[@"userId"] isEqualToString:[PFUser currentId]])
				{
					ClearRecentCounterItem(recent);
				}
			}
		}
	}];
}

//-------------------------------------------------------------------------------------------------------
void ClearRecentCounterItem(NSDictionary *recent)
//-------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Trans/%@", FIREBASE, recent[@"refkey"]]];
	[firebase updateChildValues:@{@"counter":@0} withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"ClearRecentCounterItem save error.");
	}];
}

#pragma mark - Delete Recent methods

//-------------------------------------------------------------------------------------------------------
void DeleteRecents(PFUser *user1, PFUser *user2)
//-------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Trans", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"refkey"] queryEqualToValue:user1.objectId];
	[query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		if (snapshot.value != [NSNull null])
		{
			for (NSDictionary *recent in [snapshot.value allValues])
			{
				if ([recent[@"members"] containsObject:user2.objectId])
				{
					DeleteRecentItem(recent);
				}
			}
		}
	}];
}

//-------------------------------------------------------------------------------------------------------
void DeleteRecentItem(NSDictionary *recent)
//-------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Trans/%@", FIREBASE, recent[@"refkey"]]];
	[firebase removeValueWithCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"DeleteRecentItem delete error.");
	}];
}
