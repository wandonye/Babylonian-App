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

NSString*       StartNewTranslation     (PFUser *user, PFUser *translator);

//---------------------------------------------------------------------------------------------------
void            CreateTrans             (NSString *userId, NSString *transId, NSArray *members, NSString *description, NSString *profileId, NSString *type);
void            CreateTransItem         (NSString *userId, NSString *transId, NSArray *members, NSString *description, NSString *profileId, NSString *type);
void            RestartRecentTrans      (NSDictionary *recent);

//---------------------------------------------------------------------------------------------------
void			UpdateRecents			(NSString *groupId, NSString *lastMessage);
void			UpdateRecentItem		(NSDictionary *recent, NSString *lastMessage);

//---------------------------------------------------------------------------------------------------
void			ClearRecentCounter		(NSString *groupId);
void			ClearRecentCounterItem	(NSDictionary *recent);

//---------------------------------------------------------------------------------------------------
void			DeleteRecents			(PFUser *user1, PFUser *user2);
void			DeleteRecentItem		(NSDictionary *recent);
