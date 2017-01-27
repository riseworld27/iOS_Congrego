//
//  IGMoviePlaybackController.h
//  IgViewer
//
//  Created by matata on 05/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface IGMoviePlaybackController : UIViewController
{
	NSURL *file;
	MPMoviePlayerController *movieController;
	MPMovieSourceType sourceType;
}

-(id)initWithPathForFile:(NSString *)path;
-(void)play;
-(void)stop;

@end
