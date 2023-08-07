//
//  FHBarItemCell.m
//  FunHer
//
//  Created by GLA on 2023/8/7.
//

#import "FHBarItemCell.h"

@implementation FHBarItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configContentView];
    }
    return self;
}

- (void)setEnable:(BOOL)enable {
    _enable = enable;
    self.mask.hidden = enable;
}

#pragma mark -- private methods
- (void)configContentView {
    self.contentView.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.showImg];
    [self.bgView addSubview:self.titleLab];
    [self.contentView addSubview:self.mask];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.mask mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.showImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.bgView);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bgView).offset(2);
        make.trailing.equalTo(self.bgView).offset(-2);
        make.bottom.equalTo(self.bgView);
        make.top.equalTo(self.showImg.mas_bottom).offset(0);
        make.height.mas_equalTo(25);
    }];
}

#pragma mark -- getter and setters
- (UIView *)bgView {
    if (!_bgView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = UIColor.whiteColor;
        view.clipsToBounds = YES;
        _bgView = view;
    }
    return _bgView;
}

- (UIView *)mask {
    if (!_mask) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = RGBA(153, 153, 153, 0.5);
        _mask = view;
    }
    return _mask;
}

- (UIImageView *)showImg {
    if (!_showImg) {
        UIImageView *imgV = [[UIImageView alloc] init];
        imgV.contentMode = UIViewContentModeScaleAspectFit;
        _showImg = imgV;
    }
    return _showImg;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        UILabel *lab = [[UILabel alloc] init];
        lab.textColor = UIColor.blackColor;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = PingFang_M_FONT_(12);
        lab.adjustsFontSizeToFitWidth = YES;
        _titleLab = lab;
    }
    return _titleLab;
}

@end
