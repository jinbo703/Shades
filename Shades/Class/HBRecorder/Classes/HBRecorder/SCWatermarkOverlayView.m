//
//  SCWatermarkOverlayView.m
//  SCRecorderExamples
//
//  Created by Simon CORSIN on 16/06/15.
//
//

#import "SCWatermarkOverlayView.h"

@interface SCWatermarkOverlayView() {
    UILabel *_watermarkLabel;
    UILabel *_timeLabel;
    UIImageView *_imgWatermarkLogo;
}


@end

@implementation SCWatermarkOverlayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _watermarkLabel = [UILabel new];
        _watermarkLabel.textColor = [UIColor whiteColor];
        _watermarkLabel.font = [UIFont boldSystemFontOfSize:40];
        
        _timeLabel = [UILabel new];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont boldSystemFontOfSize:40];
        
        _imgWatermarkLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"] highlightedImage:nil];
        _imgWatermarkLogo.backgroundColor = [UIColor clearColor];
        _imgWatermarkLogo.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imgWatermarkLogo];
        
        [self addSubview:_watermarkLabel];
        [self addSubview:_timeLabel];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
        
    static const CGFloat inset = 8;
    
    CGSize size = self.bounds.size;
    
    int w = 200, h = 70;
    int positionX = size.width - w - inset;
    int positionY = size.height - h - inset;
    _imgWatermarkLogo.frame = CGRectMake(positionX, positionY, w, h);
    
    [_watermarkLabel sizeToFit];
    CGRect watermarkFrame = _watermarkLabel.frame;
    watermarkFrame.origin.x = size.width - watermarkFrame.size.width - inset - 30;
    watermarkFrame.origin.y = size.height - watermarkFrame.size.height - inset - h - 10;
    _watermarkLabel.frame = watermarkFrame;
    
    [_timeLabel sizeToFit];
    CGRect timeLabelFrame = _timeLabel.frame;
    timeLabelFrame.origin.x = size.width - timeLabelFrame.size.width - w - inset - 30;
    timeLabelFrame.origin.y = size.height - timeLabelFrame.size.height - inset - 10;
    _timeLabel.frame = timeLabelFrame;
}

- (void)updateWithVideoTime:(NSTimeInterval)time {
    _timeLabel.text = _topTitle;
    _watermarkLabel.text = _bottomTitle;
}

@end
