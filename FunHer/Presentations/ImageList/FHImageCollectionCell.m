//
//  FHImageCollectionCell.m
//  FunHer
//
//  Created by GLA on 2023/8/4.
//

#import "FHImageCollectionCell.h"

@implementation FHImageCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configContentView];
    }
    return self;
}


#pragma mark -- private methods
- (void)configContentView {
    self.contentView.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.showImg];
    [self.bgView addSubview:self.titleLab];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.showImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.bgView);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.top.equalTo(self.showImg.mas_bottom).offset(0);
        make.bottom.equalTo(self.bgView);
        make.height.mas_equalTo(25);
    }];
}

#pragma mark -- getter and setters
- (UIView *)bgView {
    if (!_bgView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = UIColor.clearColor;
        view.clipsToBounds = YES;
        _bgView = view;
    }
    return _bgView;
}

- (UIImageView *)showImg {
    if (!_showImg) {
        UIImageView *imgV = [[UIImageView alloc] init];
        imgV.image = [UIImage imageNamed:@"placeholder"];
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.layer.cornerRadius = 5;
        imgV.clipsToBounds = YES;
        _showImg = imgV;
    }
    return _showImg;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        UILabel *lab = [[UILabel alloc] init];
        lab.textColor = UIColor.grayColor;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = PingFang_M_FONT_(17);
        lab.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLab = lab;
    }
    return _titleLab;
}

@end
