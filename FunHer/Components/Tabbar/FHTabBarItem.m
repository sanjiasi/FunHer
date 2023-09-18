//
//  FHTabBarItem.m
//  FunHer
//
//  Created by GLA on 2023/9/15.
//

#import "FHTabBarItem.h"

@implementation FHTabBarItem

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
        make.top.equalTo(self.bgView).offset(3);
        make.centerX.equalTo(self.bgView);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bgView).offset(2);
        make.trailing.equalTo(self.bgView).offset(-2);
        make.bottom.equalTo(self.bgView).offset(0);
        make.top.equalTo(self.showImg.mas_bottom).offset(0);
        make.height.mas_equalTo(20);
    }];
}

#pragma mark -- getter and setters
- (UIView *)bgView {
    if (!_bgView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = UIColor.clearColor;
        _bgView = view;
    }
    return _bgView;
}

- (UIView *)mask {
    if (!_mask) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = RGBA(255, 255, 255, 0.5);;
        _mask = view;
    }
    return _mask;
}

- (UIImageView *)showImg {
    if (!_showImg) {
        UIImageView *imgV = [[UIImageView alloc] init];
        imgV.contentMode = UIViewContentModeCenter;
        _showImg = imgV;
    }
    return _showImg;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        UILabel *lab = [[UILabel alloc] init];
        lab.textColor = RGBA(122, 122, 122, 1.0);
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = PingFang_R_FONT_(11);
        lab.adjustsFontSizeToFitWidth = YES;
        _titleLab = lab;
    }
    return _titleLab;
}


@end
