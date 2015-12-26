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

#import "common.h"
#import "WelcomeView.h"
#import "PremiumView.h"
#import "NavigationController.h"
#import "ProgressHUD.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void LoginUser(id target)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:[[WelcomeView alloc] init]];
	[target presentViewController:navigationController animated:YES completion:nil];
}
void ParentLoginUser(id target)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:[[WelcomeView alloc] init]];
    [[target parentViewController] presentViewController:navigationController animated:YES completion:nil];
    printf("tried parentlogin");
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ActionPremium(id target)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [ProgressHUD showError:[NSString stringWithFormat:@"This function is underconstruction!"]];
	//PremiumView *premiumView = [[PremiumView alloc] init];
	//premiumView.modalPresentationStyle = UIModalPresentationOverFullScreen;
	//[target presentViewController:premiumView animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void PostNotification(NSString *notification)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
}
