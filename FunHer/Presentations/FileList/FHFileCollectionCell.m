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
    self.contentView.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.showImg];
    [self.bgView addSubview:self.titleLab];
    [self.bgView addSubview:self.numLab];
    [self.bgView addSubview:self.uTimeLab];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.showImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.bgView);
        make.bottom.equalTo(self.bgView).offset(-66);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bgView).offset(5);
        make.trailing.equalTo(self.bgView).offset(-5);
        make.top.equalTo(self.showImg.mas_bottom).offset(0);
        make.height.mas_equalTo(27);
    }];
    
    [self.uTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bgView).offset(5);
        make.top.equalTo(self.titleLab.mas_bottom).offset(0);
        make.trailing.equalTo(self.bgView).offset(-5);
        make.height.mas_equalTo(12);
    }];
    
    [self.numLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bgView).offset(5);
        make.height.mas_equalTo(27);
        make.bottom.equalTo(self.bgView);
    }];
}

#pragma mark -- getter and setters
- (UIView *)bgView {
    if (!_bgView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = UIColor.whiteColor;
        view.layer.cornerRadius = 5;
        view.layer.borderColor = RGBA(241, 241, 241, 1.0).CGColor;
        view.layer.borderWidth = 0.5;
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
        imgV.clipsToBounds = YES;
        imgV.backgroundColor = RGB(241, 241, 241);
        _showImg = imgV;
    }
    return _showImg;
}

- (UIImageView *)folderIcon {
    if (!_folderIcon) {
        UIImageView *imgV = [[UIImageView alloc] init];
        imgV.image = [UIImage imageNamed:@"placeholder"];
        imgV.clipsToBounds = YES;
        _folderIcon = imgV;
    }
    return _folderIcon;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        UILabel *lab = [[UILabel alloc] init];
        lab.textColor = kTextBlackColor;
        lab.textAlignment = NSTextAlignmentNatural;
        lab.font = PingFang_M_FONT_(13);
        lab.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLab = lab;
    }
    return _titleLab;
}

- (UILabel *)uTimeLab {
    if (!_uTimeLab) {
        UILabel *lab = [[UILabel alloc] init];
        lab.textColor = kTextGrayColor;
        lab.textAlignment = NSTextAlignmentNatural;
        lab.font = PingFang_R_FONT_(10);
        lab.lineBreakMode = NSLineBreakByTruncatingTail;
        _uTimeLab = lab;
    }
    return _uTimeLab;
}

- (UILabel *)numLab {
    if (!_numLab) {
        UILabel *lab = [[UILabel alloc] init];
        lab.textColor = kTextGrayColor;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = PingFang_M_FONT_(12);
        lab.lineBreakMode = NSLineBreakByTruncatingTail;
//        lab.layer.cornerRadius = 3;
//        lab.layer.borderColor = RGBA(153, 153, 153, 1.0).CGColor;
//        lab.layer.borderWidth = 0.5;
//        lab.layer.masksToBounds = YES;
//        [lab setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        _numLab = lab;
    }
    return _numLab;
}

@end
