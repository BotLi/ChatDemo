//
//  POVoiceHUD.m
//  POVoiceHUD
//
//  Created by Polat Olu on 18/04/2013.
//  Copyright (c) 2013 Polat Olu. All rights reserved.
//


// This code is distributed under the terms and conditions of the MIT license.

// Copyright (c) 2013 Polat Olu
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "POVoiceHUD.h"

@implementation POVoiceHUD

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.contentMode = UIViewContentModeRedraw;

        self.autoresizesSubviews=YES;
        self.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];

		self.alpha = 0.0f;
        btnCancel = [[UIButton alloc] init];
        [btnCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        btnStop = [[UIButton alloc] init];
        [btnStop setTitle:NSLocalizedString(@"Stop", nil) forState:UIControlStateNormal];
        [btnStop addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        btnStart = [[UIButton alloc] init];
        [btnStart setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
        [btnStart addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btnCancel];
        [self addSubview:btnStop];
        [self addSubview:btnStart];
        
        imgMicrophone = [UIImage imageNamed:@"microphone"];

        // fill empty sound meters
        for(int i=0; i<SOUND_METER_COUNT; i++) {
            soundMeters[i] = -50;
        }
        
        btnStart.enabled = YES;
        btnStop.enabled = NO;
        btnCancel.enabled = YES;
        
        [self initSetting];
    }
    
    return self;
}

- (id)initWithParentView:(UIView *)view {
    return [self initWithFrame:view.bounds];
}

- (void) initSetting
{
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    recorderFilePath = [docsDir stringByAppendingPathComponent:@"tempsound.caf"];
    
    NSData *audioData = [NSData dataWithContentsOfFile:recorderFilePath options: 0 error:nil];
    if(audioData)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:recorderFilePath error:nil];
    }
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:recorderFilePath];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES error:nil];
    // Define the recorder setting
    NSMutableDictionary *recordSettings =
    [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
     [NSNumber numberWithInt:16],AVEncoderBitRateKey,
     [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
     [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
     nil];
    
    NSError *error = nil;
    
    recorder = [[AVAudioRecorder alloc]
                     initWithURL:soundFileURL
                     settings:recordSettings
                     error:&error];
    recorder.delegate = self;
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
        
    } else {
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES;
    }
    //end audio setting
}

- (void)show
{
    self.alpha = 0.8f;
}

- (void)updateMeters {
    [recorder updateMeters];

    NSLog(@"meter:%5f", [recorder averagePowerForChannel:0]);
    if (([recorder averagePowerForChannel:0] < -60.0) && (recordTime > 3.0)) {
        [self commitRecording];
        return;
    }
    
    recordTime += WAVE_UPDATE_FREQUENCY;
    [self addSoundMeterItem:[recorder averagePowerForChannel:0]];
    
}

- (void)cancelRecording {
    [recorder stop];
    if ([self.delegate respondsToSelector:@selector(voiceRecordCancelledByUser:)]) {
        [self.delegate voiceRecordCancelledByUser:self];
    }
}

- (void)commitRecording {
    [recorder stop];
    [timer invalidate];
    
    self.alpha = 0.0;
    [self setNeedsDisplay];
    
    if ([self.delegate respondsToSelector:@selector(POVoiceHUD:voiceRecorded:length:)]) {
        [self.delegate POVoiceHUD:self voiceRecorded:recorderFilePath length:recordTime];
    }
}

- (void)buttonClick:(id)sender {
    if ([sender isEqual:btnCancel])
    {
        self.alpha = 0.0;
        [self setNeedsDisplay];
        
        if(timer)[timer invalidate];
        [self cancelRecording];
    }
    if ([sender isEqual:btnStart])
    {
        [recorder record];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:WAVE_UPDATE_FREQUENCY target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
        
        btnStart.enabled = NO;
        btnStop.enabled = YES;
        btnCancel.enabled = YES;
    }
    if ([sender isEqual:btnStop])
    {
        [self commitRecording];
    }
}

- (void)setStartButtonTitle:(NSString *)title {
    btnStart.titleLabel.text = title;
}

- (void)setStopButtonTitle:(NSString *)title {
    btnStop.titleLabel.text = title;
}

- (void)setCancelButtonTitle:(NSString *)title {
    btnCancel.titleLabel.text = title;
}

#pragma mark - Sound meter operations

- (void)shiftSoundMeterLeft {
    for(int i=0; i<SOUND_METER_COUNT - 1; i++) {
        soundMeters[i] = soundMeters[i+1];
    }
}

- (void)addSoundMeterItem:(int)lastValue {
    [self shiftSoundMeterLeft];
    [self shiftSoundMeterLeft];
    soundMeters[SOUND_METER_COUNT - 1] = lastValue;
    soundMeters[SOUND_METER_COUNT - 2] = lastValue;
    
    [self setNeedsDisplay];
}

#pragma mark - Drawing operations

- (void)drawRect:(CGRect)rect {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *strokeColor = [UIColor colorWithRed:0.886 green:0.0 blue:0.0 alpha:0.8];
    UIColor *fillColor = [UIColor colorWithRed:0.5827 green:0.5827 blue:0.5827 alpha:1.0];
    UIColor *gradientColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    
    NSArray *gradientColors = [NSArray arrayWithObjects:
                               (id)fillColor.CGColor,
                               (id)gradientColor.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    UIBezierPath *border = [UIBezierPath bezierPathWithRoundedRect:hudRect cornerRadius:10.0];
    CGContextSaveGState(context);
    [border addClip];
    CGContextDrawRadialGradient(context, gradient,
                                CGPointMake(hudRect.origin.x+HUD_SIZE/2, 120), 10,
                                CGPointMake(hudRect.origin.x+HUD_SIZE/2, 195), 215,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    CGContextRestoreGState(context);
    [strokeColor setStroke];
    border.lineWidth = 3.0;
    [border stroke];
    
    // Draw sound meter wave
    [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.4] set];
    
    CGContextSetLineWidth(context, 3.0);
    CGContextSetLineJoin(context, kCGLineJoinRound);

    int baseLine = self.center.y;
    int multiplier = 1;
    int maxLengthOfWave = 50;
    int maxValueOfMeter = 70;
    for(CGFloat x = SOUND_METER_COUNT - 1; x >= 0; x--)
    {
        multiplier = ((int)x % 2) == 0 ? 1 : -1;
        
        CGFloat y = baseLine + ((maxValueOfMeter * (maxLengthOfWave - abs(soundMeters[(int)x]))) / maxLengthOfWave) * multiplier;
        
        if(x == SOUND_METER_COUNT - 1) {
            CGContextMoveToPoint(context, x * (HUD_SIZE / SOUND_METER_COUNT) + hudRect.origin.x + 20, y);
            CGContextAddLineToPoint(context, x * (HUD_SIZE / SOUND_METER_COUNT) + hudRect.origin.x + 17, y);
        }
        else {
            CGContextAddLineToPoint(context, x * (HUD_SIZE / SOUND_METER_COUNT) + hudRect.origin.x + 20, y);
            CGContextAddLineToPoint(context, x * (HUD_SIZE / SOUND_METER_COUNT) + hudRect.origin.x + 17, y);
        }
    }
    
    CGContextStrokePath(context);
    
    // Draw title
    [color setFill];
    UIFont *font = [UIFont systemFontOfSize:42.0];
    
    /// Make a copy of the default paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    /// Set text alignment
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle };

    [self.title drawInRect:CGRectInset(hudRect, 0, 25) withAttributes:attributes];
//    [self.title drawInRect:CGRectInset(hudRect, 0, 25) withFont:[UIFont systemFontOfSize:42.0] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];

    [imgMicrophone drawAtPoint:CGPointMake(hudRect.origin.x + hudRect.size.width/2 - imgMicrophone.size.width/2, hudRect.origin.y + hudRect.size.height/2 - imgMicrophone.size.height/2)];
    
    [[UIColor colorWithWhite:0.8 alpha:1.0] setFill];
    UIBezierPath *line = [UIBezierPath bezierPath];
    [line moveToPoint:CGPointMake(hudRect.origin.x, hudRect.origin.y + HUD_SIZE - CANCEL_BUTTON_HEIGHT)];
    [line addLineToPoint:CGPointMake(hudRect.origin.x + HUD_SIZE, hudRect.origin.y + HUD_SIZE - CANCEL_BUTTON_HEIGHT)];
    [line setLineWidth:3.0];
    [line stroke];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    hudRect = CGRectMake(self.center.x - (HUD_SIZE / 2), self.center.y - (HUD_SIZE / 2), HUD_SIZE, HUD_SIZE);
    int x = (self.frame.size.width - HUD_SIZE) / 2;
    btnStart.frame = CGRectMake(x, hudRect.origin.y + HUD_SIZE - CANCEL_BUTTON_HEIGHT, HUD_SIZE/3, CANCEL_BUTTON_HEIGHT);
    btnStop.frame = CGRectMake(x + HUD_SIZE / 3, hudRect.origin.y + HUD_SIZE - CANCEL_BUTTON_HEIGHT, HUD_SIZE/3, CANCEL_BUTTON_HEIGHT);
    btnCancel.frame = CGRectMake(x + HUD_SIZE / 3 * 2, hudRect.origin.y + HUD_SIZE - CANCEL_BUTTON_HEIGHT, HUD_SIZE/3, CANCEL_BUTTON_HEIGHT);
}
@end
