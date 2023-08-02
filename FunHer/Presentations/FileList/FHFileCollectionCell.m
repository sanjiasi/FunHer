//
//  FHFileCollectionCell.m
//  FunHer
//
//  Created by GLA on 2023/7/31.
//

#import "FHFileCollectionCell.h"

@implementation FHFileCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configContentView];
    }
    return self;
}


#pragma mark -- private methods
- (void)configContentView {
    [self.contentView addSubview:self.showImg];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.numLab];
    
    [self.showImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.contentView);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.equalTo(self.contentView);
        make.top.equalTo(self.showImg.mas_bottom).offset(0);
        make.height.mas_equalTo(25);
    }];
    
    [self.numLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-10);
        make.centerY.equalTo(self.titleLab.mas_centerY).offset(0);
    }];
}

#pragma mark -- getter and setters
- (UIImageView *)showImg {
    if (!_showImg) {
        UIImageView *imgV = [[UIImageView alloc] init];
        imgV.image = [UIImage imageNamed:@"placeholder"];
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.clipsToBounds = YES;
        _showImg = imgV;
    }
    return _showImg;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        UILabel *lab = [[UILabel alloc] init];
        lab.textColor = UIColor.blackColor;
        lab.textAlignment = NSTextAlignmentNatural;
        lab.font = PingFang_R_FONT_(10);
        lab.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLab = lab;
    }
    return _titleLab;
}

- (UILabel *)numLab {
    if (!_numLab) {
        UILabel *lab = [[UILabel alloc] init];
        lab.textColor = RGBA(199, 199, 199, 1.0);
        lab.textAlignment = NSTextAlignmentNatural;
        lab.font = PingFang_R_FONT_(10);
        lab.lineBreakMode = NSLineBreakByTruncatingTail;
        _numLab = lab;
    }
    return _numLab;
}

@end
