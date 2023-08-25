//
//  FHFilterCollectionCell.m
//  FunHer
//
//  Created by GLA on 2023/8/25.
//

#import "FHFilterCollectionCell.h"

@implementation FHFilterCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configContentView];
    }
    return self;
}


#pragma mark -- private methods
- (void)configContentView {
    self.contentView.backgroundColor = RGBA(0, 0, 0, 0.16);
    [self.contentView addSubview:self.showImg];
    [self.contentView addSubview:self.titleLab];
    
    [self.showImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.equalTo(self.contentView);
    }];
    [self.titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(28);
    }];
}

- (UIImageView *)showImg {
    if (!_showImg) {
        UIImageView *imgV = [[UIImageView alloc] init];
        imgV.image = [UIImage imageNamed:@"placeholder"];
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.clipsToBounds = YES;
        imgV.backgroundColor = RGB(241, 241, 241);
        _showImg = imgV;
    }
    return _showImg;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        UILabel *lab = [[UILabel alloc] init];
        lab.backgroundColor = RGBA(51, 51, 51, 0.3);
        lab.textColor = UIColor.whiteColor;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = PingFang_R_FONT_(11);
        lab.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLab = lab;
    }
    return _titleLab;
}

@end
