//
//  IGMoviePlaybackController.m
//  IgViewer
//
//  Created by matata on 05/03/2013.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "IGMoviePlaybackController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface IGMoviePlaybackController ()

@end

@implementation IGMoviePlaybackController

-(id)initWithPathForFile:(NSString *)path
{
	return [self initWithPathForFile:path andSourceType:MPMovieSourceTypeFile];
}

-(id)initWithPathForFile:(NSString *)path andSourceType:(MPMovieSourceType)type
{
	self = [super init];
	if (self) {
		file = [NSURL fileURLWithPath:path];
		sourceType = type;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	movieController = [[MPMoviePlayerController alloc] initWithContentURL:file];
	[movieController setMovieSourceType:sourceType];
	[movieController prepareToPlay];
	[movieController setFullscreen:NO];
	[movieController.view setFrame:CGRectMake(0, 0, 1024, 704)];
	[[self view] addSubview:movieController.view];
}

-(void)play
{
	if (movieController) [movieController play];
}

-(void)stop
{
	if (movieController) [movieController stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
